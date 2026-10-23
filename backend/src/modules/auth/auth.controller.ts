import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { prisma } from '../../index';
import { messageCentralService } from './messagecentral.service';

function hashPassword(password: string, salt: string): string {
  return crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
}

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
    let isNewUser = false;
    try {
      user = await prisma.user.findUnique({
        where: { phone },
        include: { roles: true },
      });

      if (!user) {
        isNewUser = true;
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
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Phone verified successfully',
      isNewUser,
      hasPassword: Boolean(user?.passwordHash),
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
 * Standard Password Login for Existing Returning Users
 * POST /api/auth/login-password
 */
export const loginWithPassword = async (req: Request, res: Response): Promise<void> => {
  const { identifier, password, role } = req.body;

  if (!identifier || !password) {
    res.status(400).json({ error: 'Mobile number or username and password are required' });
    return;
  }

  const targetRole = role?.toString().toUpperCase() === 'PROVIDER' ? 'PROVIDER' : 'SEEKER';

  try {
    const rawIdentifier = identifier.trim();
    // Normalize phone format if numeric
    let cleanPhone = rawIdentifier.replace(/[\s\-\(\)]/g, '');
    if (cleanPhone.startsWith('+')) cleanPhone = cleanPhone.substring(1);

    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: rawIdentifier },
          { phone: cleanPhone },
          { phone: `+${cleanPhone}` },
          { phone: cleanPhone.startsWith('91') ? `+${cleanPhone}` : `+91${cleanPhone}` },
          { email: rawIdentifier },
          { name: rawIdentifier },
        ],
      },
      include: { roles: true },
    });

    if (!user) {
      res.status(404).json({
        error: 'No account found with this mobile number or username. Please click Sign Up.',
      });
      return;
    }

    if (!user.passwordHash || !user.salt) {
      res.status(400).json({
        error: 'Password not set for this account yet. Please sign in via OTP once to set your password.',
      });
      return;
    }

    const calculatedHash = hashPassword(password, user.salt);
    if (calculatedHash !== user.passwordHash) {
      res.status(401).json({ error: 'Incorrect password. Please verify and try again.' });
      return;
    }

    // Ensure role is assigned
    const hasRole = user.roles.some((r: any) => r.role === targetRole);
    if (!hasRole) {
      await prisma.userRole.create({
        data: {
          userId: user.id,
          role: targetRole as any,
        },
      });
    }

    const token = jwt.sign(
      { userId: user.id, roles: user.roles?.map((r: any) => r.role) || [targetRole] },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Signed in successfully',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email,
        roles: user.roles?.map((r: any) => r.role) || [targetRole],
      },
      token,
    });
  } catch (error: any) {
    console.error('Error in loginWithPassword:', error);
    res.status(500).json({ error: 'Database connection failed. Please ensure PostgreSQL is running.' });
  }
};

/**
 * Register Name, Email, and Password after OTP Verification
 * POST /api/auth/register-profile
 */
export const registerProfile = async (req: Request, res: Response): Promise<void> => {
  const { phone, name, email, password, role } = req.body;

  if (!phone || !name || !password) {
    res.status(400).json({ error: 'Phone, name, and password are required' });
    return;
  }

  if (password.length < 6) {
    res.status(400).json({ error: 'Password must be at least 6 characters long' });
    return;
  }

  const salt = crypto.randomBytes(16).toString('hex');
  const passwordHash = hashPassword(password, salt);
  const targetRole = role?.toString().toUpperCase() === 'PROVIDER' ? 'PROVIDER' : 'SEEKER';

  try {
    let user = await prisma.user.findUnique({
      where: { phone },
      include: { roles: true },
    });

    if (user) {
      user = await prisma.user.update({
        where: { phone },
        data: {
          name,
          email: email || user.email,
          passwordHash,
          salt,
        },
        include: { roles: true },
      });
    } else {
      user = await prisma.user.create({
        data: {
          phone,
          name,
          email,
          passwordHash,
          salt,
          roles: {
            create: { role: targetRole as any },
          },
        },
        include: { roles: true },
      });
    }

    const token = jwt.sign(
      { userId: user.id, roles: user.roles?.map((r: any) => r.role) || [targetRole] },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Account profile and password saved successfully',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email,
        roles: user.roles?.map((r: any) => r.role) || [targetRole],
      },
      token,
    });
  } catch (error: any) {
    console.error('Error in registerProfile:', error);
    // Offline database fallback
    const mockUser = {
      id: `usr_${Date.now()}`,
      phone,
      name,
      email,
      roles: [{ role: targetRole }],
    };
    const token = jwt.sign(
      { userId: mockUser.id, roles: [targetRole] },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '30d' }
    );
    res.json({
      success: true,
      message: 'Profile saved (Offline mode)',
      user: mockUser,
      token,
    });
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
