import { Router } from 'express';
import { setupProviderProfile, getProviderDashboard, getProviderBookings } from './providers.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.post('/setup', authenticate, setupProviderProfile);
router.get('/dashboard', authenticate, getProviderDashboard);
router.get('/bookings', authenticate, getProviderBookings);

export default router;
