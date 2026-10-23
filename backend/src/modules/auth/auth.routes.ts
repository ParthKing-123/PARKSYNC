import { Router } from 'express';
import { sendOtp, verifyOtp, getMe } from './auth.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

// OTP Endpoints powered by MessageCentral
router.post('/send-otp', sendOtp);
router.post('/verify', verifyOtp);
router.get('/me', authenticate, getMe);

export default router;
