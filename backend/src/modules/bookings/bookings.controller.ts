import { Request, Response } from 'express';
import { prisma } from '../../index';
import { v4 as uuidv4 } from 'uuid';

export const createBooking = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { parkingSpaceId, vehicleId, startTime, endTime } = req.body;

    if (!parkingSpaceId || !vehicleId || !startTime || !endTime) {
      res.status(400).json({ error: 'Missing required fields' });
      return;
    }

    const start = new Date(startTime);
    const end = new Date(endTime);

    if (start >= end) {
      res.status(400).json({ error: 'End time must be after start time' });
      return;
    }

    // 1. Transactional booking creation to prevent double-booking
    const booking = await prisma.$transaction(async (tx) => {
      // Find space to get price and ensure it exists
      const space = await tx.parkingSpace.findUnique({
        where: { id: parkingSpaceId }
      });

      if (!space) {
        throw new Error('Parking space not found');
      }

      // Check for overlapping bookings
      const overlapping = await tx.booking.findFirst({
        where: {
          parkingSpaceId,
          status: { in: ['PENDING', 'CONFIRMED', 'ACTIVE'] },
          OR: [
            { startTime: { lte: start }, endTime: { gt: start } }, // Overlaps start
            { startTime: { lt: end }, endTime: { gte: end } },     // Overlaps end
            { startTime: { gte: start }, endTime: { lte: end } }   // Fully inside
          ]
        }
      });

      if (overlapping) {
        throw new Error('This time slot is already booked');
      }

      // Calculate Price
      const durationHours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
      const price = durationHours * space.pricePerHour;
      const platformFee = price * 0.10; // 10% fee
      const totalAmount = price + platformFee;

      const bookingRef = 'BK-' + uuidv4().split('-')[0].toUpperCase();

      // Create Booking
      const newBooking = await tx.booking.create({
        data: {
          bookingReference: bookingRef,
          userId,
          parkingSpaceId,
          vehicleId,
          startTime: start,
          endTime: end,
          price,
          platformFee,
          totalAmount,
          status: 'PENDING',
        }
      });

      return newBooking;
    });

    res.json(booking);
  } catch (error: any) {
    if (error.message === 'This time slot is already booked' || error.message === 'Parking space not found') {
      res.status(400).json({ error: error.message });
      return;
    }
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getMyBookings = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const bookings = await prisma.booking.findMany({
      where: { userId },
      include: {
        parkingSpace: true,
        vehicle: true,
        payment: true
      },
      orderBy: { createdAt: 'desc' }
    });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
