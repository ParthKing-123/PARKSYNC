import { Request, Response } from 'express';
import { prisma } from '../../index';

export const createReview = async (req: Request, res: Response): Promise<void> => {
  try {
    const reviewerId = (req as any).user.userId;
    const { bookingId, rating, comment } = req.body;

    if (!bookingId || !rating) {
      res.status(400).json({ error: 'bookingId and rating are required' });
      return;
    }

    const booking = await prisma.booking.findUnique({
      where: { id: bookingId },
      include: { parkingSpace: true }
    });

    if (!booking) {
      res.status(404).json({ error: 'Booking not found' });
      return;
    }

    if (booking.userId !== reviewerId && booking.parkingSpace.providerId !== reviewerId) {
      res.status(403).json({ error: 'Not authorized to review this booking' });
      return;
    }

    // Determine the reviewee (if seeker is reviewing, reviewee is provider. If provider reviewing, reviewee is seeker)
    const revieweeId = booking.userId === reviewerId ? booking.parkingSpace.providerId : booking.userId;

    const review = await prisma.review.create({
      data: {
        bookingId,
        reviewerId,
        revieweeId,
        rating,
        comment
      }
    });

    res.json(review);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
