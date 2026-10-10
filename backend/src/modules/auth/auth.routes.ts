import { Router } from 'express';
import { verifyOtp, getMe } from './auth.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

// In a real app, you'd have /request-otp first, but we are simplifying for the pilot
router.post('/verify', verifyOtp);
router.get('/me', authenticate, getMe);

export default router;
