import { Router } from 'express';
import { 
  createBooking, 
  getMyBookings, 
  getProviderBookingRequests, 
  updateBookingStatus 
} from './bookings.controller';
import { uploadEvidence } from './evidence.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.post('/', authenticate, createBooking);
router.get('/my-bookings', authenticate, getMyBookings);
router.get('/provider-requests', authenticate, getProviderBookingRequests);
router.patch('/:id/status', authenticate, updateBookingStatus);
router.post('/:id/approve', authenticate, (req, res) => {
  if (!req.body) req.body = {};
  req.body.status = 'CONFIRMED';
  return updateBookingStatus(req, res);
});
router.post('/:id/reject', authenticate, (req, res) => {
  if (!req.body) req.body = {};
  req.body.status = 'REJECTED';
  return updateBookingStatus(req, res);
});
router.post('/evidence', authenticate, uploadEvidence);

export default router;
