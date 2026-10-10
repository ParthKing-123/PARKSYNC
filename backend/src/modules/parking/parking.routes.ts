import { Router } from 'express';
import { createParkingSpace, getMyParkingSpaces, searchParking } from './parking.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.get('/search', authenticate, searchParking); // Explicitly passing authenticate if required, but search might be public? Let's keep authenticate for Pilot.
router.post('/', authenticate, createParkingSpace);
router.get('/my-spaces', authenticate, getMyParkingSpaces);

export default router;
