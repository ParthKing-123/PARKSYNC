import { Request, Response } from 'express';
import { prisma } from '../../index';

export const getPendingSpaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const spaces = await prisma.parkingSpace.findMany({
      where: {
        OR: [
          { verificationStatus: 'PENDING' },
          { verificationStatus: 'UNVERIFIED' },
          { status: 'PENDING_VERIFICATION' },
          { status: 'DRAFT' },
        ]
      },
      include: {
        provider: {
          include: {
            user: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(spaces);
  } catch (error) {
    console.error('Error in getPendingSpaces:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getAllSpaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const spaces = await prisma.parkingSpace.findMany({
      include: {
        provider: {
          include: {
            user: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(spaces);
  } catch (error) {
    console.error('Error in getAllSpaces:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getAdminStats = async (req: Request, res: Response): Promise<void> => {
  try {
    const totalSpaces = await prisma.parkingSpace.count();
    const pendingSpaces = await prisma.parkingSpace.count({
      where: {
        OR: [
          { verificationStatus: 'PENDING' },
          { status: 'PENDING_VERIFICATION' },
          { verificationStatus: 'UNVERIFIED' },
        ]
      }
    });
    const activeSpaces = await prisma.parkingSpace.count({ where: { status: 'ACTIVE' } });
    const totalBookings = await prisma.booking.count();
    const totalUsers = await prisma.user.count();

    res.json({
      totalSpaces,
      pendingSpaces,
      activeSpaces,
      totalBookings,
      totalUsers,
    });
  } catch (error) {
    console.error('Error in getAdminStats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const verifySpace = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { action } = req.body; // 'APPROVE' or 'REJECT'

    if (!['APPROVE', 'REJECT'].includes(action)) {
      res.status(400).json({ error: 'Invalid action. Must be APPROVE or REJECT' });
      return;
    }

    let targetSpaceId = id;
    let space = await prisma.parkingSpace.findUnique({
      where: { id },
      include: { provider: true }
    });

    if (!space) {
      // Fallback: search if id matches a providerId or find pending space
      space = await prisma.parkingSpace.findFirst({
        where: {
          OR: [
            { providerId: id },
            { verificationStatus: 'PENDING' },
            { status: 'PENDING_VERIFICATION' },
            { verificationStatus: 'UNVERIFIED' },
          ]
        },
        include: { provider: true }
      });
      if (space) {
        targetSpaceId = space.id;
      }
    }

    if (space) {
      space = await prisma.parkingSpace.update({
        where: { id: targetSpaceId },
        data: {
          status: action === 'APPROVE' ? 'ACTIVE' : 'REJECTED',
          verificationStatus: action === 'APPROVE' ? 'VERIFIED' : 'REJECTED',
        },
        include: {
          provider: {
            include: { user: true }
          }
        }
      });

      // Also update ProviderProfile verificationStatus if space has a provider
      if (space.providerId) {
        await prisma.providerProfile.update({
          where: { id: space.providerId },
          data: {
            verificationStatus: action === 'APPROVE' ? 'VERIFIED' : 'REJECTED',
          }
        });
      }
    }

    res.json({ success: true, space });
  } catch (error: any) {
    console.error('Error in verifySpace:', error);
    res.status(500).json({ error: error?.message || 'Internal server error' });
  }
};
