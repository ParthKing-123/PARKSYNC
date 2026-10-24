import { Router } from 'express';
import { getPendingSpaces, getAllSpaces, getAdminStats, verifySpace } from './admin.controller';

const router = Router();

// Skipping authenticate middleware for local dev admin panel ease, 
// in prod this must require role = ADMIN
router.get('/spaces/pending', getPendingSpaces);
router.get('/spaces/all', getAllSpaces);
router.get('/stats', getAdminStats);
router.post('/spaces/:id/verify', verifySpace);

export default router;
