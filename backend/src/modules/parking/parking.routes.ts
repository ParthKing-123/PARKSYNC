import { Router } from 'express';
import { 
  createParkingSpace, 
  getAllParkingSpaces, 
  getParkingSpaceById, 
  getMyParkingSpaces, 
  searchParking 
} from './parking.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

// Public routes for seekers to explore spots
router.get('/', getAllParkingSpaces);
router.get('/search', searchParking);
router.get('/single/:id', getParkingSpaceById);

// Authenticated provider routes
router.post('/', authenticate, createParkingSpace);
router.get('/my-spaces', authenticate, getMyParkingSpaces);

export default router;
