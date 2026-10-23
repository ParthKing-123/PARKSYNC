import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../../index';
import { messageCentralService } from './messagecentral.service';

/**
 * Send OTP via MessageCentral VerifyNow
 * POST /api/auth/send-otp
 */
export const sendOtp = async (req: Request, res: Response): Promise<void> => {
  try {
    const { phone } = req.body;

    if (!phone) {
      res.status(400).json({ error: 'Phone number is required' });
      return;
    }

    const result = await messageCentralService.sendOtp(phone);
    res.json(result);
  } catch (error: any) {
    console.error('Error in sendOtp:', error);
    res.status(500).json({ error: error.message || 'Failed to dispatch verification code' });
  }
};

/**
 * Verify OTP code via MessageCentral and issue authentication session
 * POST /api/auth/verify
 */
export const verifyOtp = async (req: Request, res: Response): Promise<void> => {
  const { phone, otp, verificationId, role } = req.body;

  if (!phone || !otp) {
    res.status(400).json({ error: 'Phone and OTP are required' });
    return;
  }

  try {
    // 1. Verify OTP with MessageCentral (or dev mock)
    const verification = await messageCentralService.verifyOtp(phone, otp, verificationId);
    if (!verification.verified) {
      res.status(400).json({ error: verification.error || 'Invalid or expired verification code' });
      return;
    }

    const targetRole = role?.toString().toUpperCase() === 'PROVIDER' ? 'PROVIDER' : 'SEEKER';

    // 2. Find or create user in PostgreSQL via Prisma
    let user: any = null;
    try {
      user = await prisma.user.findUnique({
        where: { phone },
        include: { roles: true },
      });

      if (!user) {
        user = await prisma.user.create({
          data: {
            phone,
            roles: {
              create: { role: targetRole as any },
            },
          },
          include: { roles: true },
        });
      } else {
        const hasRole = user.roles.some((r: any) => r.role === targetRole);
        if (!hasRole) {
          await prisma.userRole.create({
            data: {
              userId: user.id,
              role: targetRole as any,
            },
          });
          user = await prisma.user.findUnique({
            where: { phone },
            include: { roles: true },
          });
        }
      }
    } catch (dbError) {
      console.warn('[Database Notice] PostgreSQL is offline, using mock user session:', dbError);
      user = {
        id: `usr_${Date.now()}`,
        phone,
        name: targetRole === 'PROVIDER' ? 'Verified Host' : 'Verified Driver',
        roles: [{ role: targetRole }],
      };
    }

    // 3. Generate signed JWT token
    const token = jwt.sign(
      { userId: user.id, roles: user.roles?.map((r: any) => r.role) || [targetRole] },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: 'Phone verified successfully',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        roles: user.roles?.map((r: any) => r.role) || [targetRole],
      },
      token,
    });
  } catch (error) {
    console.error('Error in verifyOtp:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get current authenticated user profile
 * GET /api/auth/me
 */
export const getMe = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, providerProfile: true },
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
      roles: user.roles.map((r) => r.role),
      providerProfile: user.providerProfile,
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
