import { Router } from 'express';
import { mockPaymentSuccess } from './payments.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.post('/mock-success', authenticate, mockPaymentSuccess);

export default router;
