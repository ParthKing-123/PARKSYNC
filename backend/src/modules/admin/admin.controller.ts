import { Request, Response } from 'express';
import { prisma } from '../../index';

// Note: In production, there would be an admin check middleware here.

export const getPendingSpaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const spaces = await prisma.parkingSpace.findMany({
      where: {
        status: 'PENDING'
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
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const verifySpace = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { action } = req.body; // 'APPROVE' or 'REJECT'

    if (!['APPROVE', 'REJECT'].includes(action)) {
      res.status(400).json({ error: 'Invalid action' });
      return;
    }

    const space = await prisma.parkingSpace.update({
      where: { id },
      data: {
        status: action === 'APPROVE' ? 'ACTIVE' : 'REJECTED'
      }
    });

    res.json({ success: true, space });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
