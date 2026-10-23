import { Request, Response } from 'express';
import { prisma } from '../../index';
import { v4 as uuidv4 } from 'uuid';

export const createBooking = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { 
      parkingSpaceId, 
      vehicleId, 
      vehiclePlate,
      vehicleModel,
      startTime, 
      endTime, 
      paymentMethod = 'CASH_ON_ARRIVAL',
      totalAmount: clientTotalAmount 
    } = req.body;

    if (!parkingSpaceId || !startTime || !endTime) {
      res.status(400).json({ error: 'Missing required booking fields (parkingSpaceId, startTime, endTime)' });
      return;
    }

    const start = new Date(startTime);
    const end = new Date(endTime);

    if (start >= end) {
      res.status(400).json({ error: 'End time must be strictly after start time' });
      return;
    }

    // 1. Transactional booking creation
    const booking = await prisma.$transaction(async (tx) => {
      const space = await tx.parkingSpace.findUnique({
        where: { id: parkingSpaceId }
      });

      if (!space) {
        throw new Error('Parking space not found');
      }

      if (space.availableBays <= 0) {
        throw new Error('No parking bays currently available for this facility');
      }

      // Check if vehicleId is provided or if we should find/create one
      let resolvedVehicleId: string | null = vehicleId || null;
      if (!resolvedVehicleId && vehiclePlate) {
        // Find existing vehicle for user or create one
        let existingVehicle = await tx.vehicle.findFirst({
          where: { userId, registrationNumber: vehiclePlate }
        });
        if (!existingVehicle) {
          // Find or create a default vehicle model
          let defaultModel = await tx.vehicleModel.findFirst();
          if (!defaultModel) {
            defaultModel = await tx.vehicleModel.create({
              data: {
                make: 'Standard',
                model: vehicleModel || 'Sedan',
                vehicleType: 'Car',
                lengthMm: 4500,
                widthMm: 1800,
                heightMm: 1500,
              }
            });
          }
          existingVehicle = await tx.vehicle.create({
            data: {
              userId,
              vehicleModelId: defaultModel.id,
              registrationNumber: vehiclePlate,
            }
          });
        }
        resolvedVehicleId = existingVehicle.id;
      }

      // Calculate Price
      const durationHours = Math.max(0.5, (end.getTime() - start.getTime()) / (1000 * 60 * 60));
      const calculatedPrice = durationHours * space.pricePerHour;
      const platformFee = 10.0; // standard ₹10 platform fee
      const totalAmount = clientTotalAmount ? parseFloat(clientTotalAmount) : (calculatedPrice + platformFee);

      const bookingRef = 'BK-' + uuidv4().split('-')[0].toUpperCase();

      // Create Booking with PENDING status (MUST be approved by Provider)
      const newBooking = await tx.booking.create({
        data: {
          bookingReference: bookingRef,
          userId,
          parkingSpaceId,
          vehicleId: resolvedVehicleId,
          startTime: start,
          endTime: end,
          price: calculatedPrice,
          platformFee,
          totalAmount,
          paymentMethod: paymentMethod === 'UPI' ? 'UPI' : 'CASH_ON_ARRIVAL',
          status: 'PENDING',
        },
        include: {
          parkingSpace: true,
          vehicle: true,
          user: {
            select: {
              id: true,
              name: true,
              phone: true,
              email: true,
            }
          }
        }
      });

      return newBooking;
    });

    res.status(201).json(booking);
  } catch (error: any) {
    console.error('Error in createBooking:', error);
    if (error.message === 'Parking space not found' || error.message.includes('No parking bays')) {
      res.status(400).json({ error: error.message });
      return;
    }
    res.status(500).json({ error: 'Internal server error while creating booking' });
  }
};

export const getMyBookings = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const bookings = await prisma.booking.findMany({
      where: { userId },
      include: {
        parkingSpace: {
          include: {
            provider: {
              include: {
                user: {
                  select: {
                    name: true,
                    phone: true,
                  }
                }
              }
            }
          }
        },
        vehicle: true,
        payment: true
      },
      orderBy: { createdAt: 'desc' }
    });

    // PRIVACY ENFORCEMENT:
    // Only reveal host contact phone number if booking is CONFIRMED or ACTIVE.
    // If PENDING, REJECTED, or CANCELLED, mask the host's phone number!
    const sanitizedBookings = bookings.map(b => {
      const isConfirmed = b.status === 'CONFIRMED' || b.status === 'ACTIVE';
      const hostUser = b.parkingSpace?.provider?.user;
      
      let hostPhone = 'Host Contact upon Confirmation';
      if (isConfirmed && hostUser?.phone) {
        hostPhone = hostUser.phone;
      }

      return {
        ...b,
        hostName: hostUser?.name || b.parkingSpace?.provider?.displayName || 'Authorized Host',
        hostPhone: hostPhone,
      };
    });

    res.json(sanitizedBookings);
  } catch (error) {
    console.error('Error in getMyBookings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getProviderBookingRequests = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;

    const profile = await prisma.providerProfile.findUnique({
      where: { userId }
    });

    if (!profile) {
      res.json([]);
      return;
    }

    const bookings = await prisma.booking.findMany({
      where: {
        parkingSpace: {
          providerId: profile.id
        }
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
          }
        },
        vehicle: {
          include: { vehicleModel: true }
        },
        parkingSpace: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(bookings);
  } catch (error) {
    console.error('Error in getProviderBookingRequests:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const updateBookingStatus = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { id } = req.params;
    const { status } = req.body; // 'CONFIRMED' | 'REJECTED' | 'COMPLETED' | 'CANCELLED'

    if (!['CONFIRMED', 'REJECTED', 'COMPLETED', 'CANCELLED'].includes(status)) {
      res.status(400).json({ error: 'Invalid booking status' });
      return;
    }

    // Verify ownership: booking must belong to a parking space of this provider
    const profile = await prisma.providerProfile.findUnique({
      where: { userId }
    });

    if (!profile) {
      res.status(403).json({ error: 'Provider profile required' });
      return;
    }

    const booking = await prisma.booking.findUnique({
      where: { id },
      include: { parkingSpace: true }
    });

    if (!booking) {
      res.status(404).json({ error: 'Booking not found' });
      return;
    }

    if (booking.parkingSpace.providerId !== profile.id) {
      res.status(403).json({ error: 'You are not authorized to update this booking' });
      return;
    }

    const oldStatus = booking.status;

    // Update status and adjust available bays atomically
    const updatedBooking = await prisma.$transaction(async (tx) => {
      const updated = await tx.booking.update({
        where: { id },
        data: { status: status as any },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              phone: true,
              email: true,
            }
          },
          parkingSpace: true,
          vehicle: true,
        }
      });

      // If approved now (and wasn't confirmed before): decrement available bays
      if (status === 'CONFIRMED' && oldStatus !== 'CONFIRMED') {
        const currentSpace = await tx.parkingSpace.findUnique({ where: { id: booking.parkingSpaceId } });
        if (currentSpace && currentSpace.availableBays > 0) {
          await tx.parkingSpace.update({
            where: { id: booking.parkingSpaceId },
            data: { availableBays: currentSpace.availableBays - 1 }
          });
        }
      }

      // If rejected now (and was previously confirmed): restore available bay
      if (status === 'REJECTED' && oldStatus === 'CONFIRMED') {
        const currentSpace = await tx.parkingSpace.findUnique({ where: { id: booking.parkingSpaceId } });
        if (currentSpace && currentSpace.availableBays < currentSpace.totalBays) {
          await tx.parkingSpace.update({
            where: { id: booking.parkingSpaceId },
            data: { availableBays: currentSpace.availableBays + 1 }
          });
        }
      }

      return updated;
    });

    res.json(updatedBooking);
  } catch (error) {
    console.error('Error in updateBookingStatus:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
