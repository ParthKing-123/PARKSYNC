import { Request, Response } from 'express';
import { prisma } from '../../index';

export const uploadEvidence = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { bookingId, type, imageUrl } = req.body; // type: 'BEFORE' | 'AFTER'

    if (!bookingId || !type || !imageUrl) {
      res.status(400).json({ error: 'bookingId, type, and imageUrl are required' });
      return;
    }

    const booking = await prisma.booking.findUnique({
      where: { id: bookingId }
    });

    if (!booking || booking.userId !== userId) {
      res.status(403).json({ error: 'Unauthorized to upload evidence for this booking' });
      return;
    }

    const evidence = await prisma.bookingEvidence.create({
      data: {
        bookingId,
        type,
        imageUrl,
        capturedBy: userId
      }
    });

    res.json(evidence);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
