import { Router } from 'express';
import { sendOtp, verifyOtp, loginWithPassword, registerProfile, getMe } from './auth.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

// OTP Endpoints powered by MessageCentral
router.post('/send-otp', sendOtp);
router.post('/verify', verifyOtp);

// Standard Password Authentication & Profile Registration
router.post('/login-password', loginWithPassword);
router.post('/register-profile', registerProfile);

router.get('/me', authenticate, getMe);

export default router;
