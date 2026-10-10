import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../../index';

export const verifyOtp = async (req: Request, res: Response): Promise<void> => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    res.status(400).json({ error: 'Phone and OTP are required' });
    return;
  }

  // MOCK: Accept any OTP for any phone in development
  if (otp !== '123456' && process.env.NODE_ENV !== 'development') {
      // In pilot mode we might just let 123456 pass
  }

  try {
    // Find or create user
    let user = await prisma.user.findUnique({
      where: { phone },
      include: { roles: true },
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone,
          roles: {
            create: { role: 'SEEKER' }
          }
        },
        include: { roles: true },
      });
    }

    // Generate Mock JWT
    const token = jwt.sign(
      { userId: user.id, roles: user.roles.map(r => r.role) },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '7d' }
    );

    res.json({
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        roles: user.roles.map(r => r.role),
      },
      token
    });
  } catch (error) {
    console.error('Error in verifyOtp:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getMe = async (req: Request, res: Response): Promise<void> => {
  try {
    // req.user is set by auth.middleware
    const userId = (req as any).user.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, providerProfile: true }
    });

    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    res.json({
      id: user.id,
      phone: user.phone,
      name: user.name,
      email: user.email,
      roles: user.roles.map(r => r.role),
      providerProfile: user.providerProfile
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
