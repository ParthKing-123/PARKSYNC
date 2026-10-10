import { Router } from 'express';
import { createReview } from './reviews.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.post('/', authenticate, createReview);

export default router;
