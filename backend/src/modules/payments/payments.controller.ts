import { Request, Response } from 'express';
import { prisma } from '../../index';

export const mockPaymentSuccess = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { bookingId } = req.body;

    const booking = await prisma.booking.findUnique({ where: { id: bookingId } });

    if (!booking || booking.userId !== userId) {
      res.status(404).json({ error: 'Booking not found' });
      return;
    }

    if (booking.status !== 'PENDING') {
      res.status(400).json({ error: 'Booking is not in pending state' });
      return;
    }

    const payment = await prisma.payment.create({
      data: {
        bookingId,
        amount: booking.totalAmount,
        status: 'SUCCESS',
        gateway: 'MOCK',
        gatewayPaymentId: 'mock_tx_' + Date.now(),
        paidAt: new Date()
      }
    });

    // Update booking status and generate mock QR code string
    const updatedBooking = await prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: 'CONFIRMED',
        qrCode: `PARKSYNC-${booking.bookingReference}-${userId.substring(0, 5)}`
      },
      include: {
        parkingSpace: true
      }
    });

    res.json({ success: true, booking: updatedBooking, payment });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
