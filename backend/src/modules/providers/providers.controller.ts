import { Request, Response } from 'express';
import { prisma } from '../../index';

export const setupProviderProfile = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { 
      providerType = 'INDIVIDUAL', 
      displayName, 
      description,
      documentType,
      documentName,
      documentSize,
      documentUrl 
    } = req.body;

    let profile = await prisma.providerProfile.findUnique({
      where: { userId }
    });

    if (profile) {
      // Update existing
      profile = await prisma.providerProfile.update({
        where: { userId },
        data: { 
          providerType, 
          displayName: displayName || profile.displayName, 
          description: description || profile.description,
          documentType: documentType || profile.documentType,
          documentName: documentName || profile.documentName,
          documentSize: documentSize !== undefined ? parseInt(documentSize) : profile.documentSize,
          documentUrl: documentUrl || profile.documentUrl,
          verificationStatus: 'VERIFIED'
        }
      });
    } else {
      // Create new
      profile = await prisma.providerProfile.create({
        data: {
          userId,
          providerType,
          displayName: displayName || 'Parking Host',
          description,
          documentType,
          documentName,
          documentSize: documentSize !== undefined ? parseInt(documentSize) : null,
          documentUrl,
          verificationStatus: 'VERIFIED'
        }
      });
    }

    // Make sure user has PROVIDER role
    const hasRole = await prisma.userRole.findUnique({
      where: { userId_role: { userId, role: 'PROVIDER' } }
    });

    if (!hasRole) {
      await prisma.userRole.create({
        data: { userId, role: 'PROVIDER' }
      });
    }

    res.json(profile);
  } catch (error) {
    console.error('Error in setupProviderProfile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getProviderDashboard = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;

    const profile = await prisma.providerProfile.findUnique({
      where: { userId },
      include: { parkingSpaces: true }
    });

    if (!profile) {
      res.status(404).json({ error: 'Provider profile not found' });
      return;
    }

    // Normally we'd aggregate earnings here, but for now mock it
    res.json({
      profile,
      stats: {
        totalEarnings: 0,
        activeBookings: 0,
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getProviderBookings = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;

    const profile = await prisma.providerProfile.findUnique({
      where: { userId }
    });

    if (!profile) {
      res.status(404).json({ error: 'Provider profile not found' });
      return;
    }

    const bookings = await prisma.booking.findMany({
      where: {
        parkingSpace: {
          providerId: profile.id
        }
      },
      include: {
        vehicle: {
          include: { vehicleModel: true }
        },
        parkingSpace: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
