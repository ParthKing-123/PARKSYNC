import { Router } from 'express';
import { createBooking, getMyBookings } from './bookings.controller';
import { uploadEvidence } from './evidence.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.post('/', authenticate, createBooking);
router.get('/my-bookings', authenticate, getMyBookings);
router.post('/evidence', authenticate, uploadEvidence);

export default router;
