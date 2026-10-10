import { Router } from 'express';
import { getPendingSpaces, verifySpace } from './admin.controller';

const router = Router();

// Skipping authenticate middleware for local dev admin panel ease, 
// in prod this must require role = ADMIN
router.get('/spaces/pending', getPendingSpaces);
router.post('/spaces/:id/verify', verifySpace);

export default router;
