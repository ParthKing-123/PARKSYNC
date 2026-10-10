import { Router } from 'express';
import { getVehicleModels, getUserVehicles, addUserVehicle, removeUserVehicle } from './vehicles.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.get('/models', getVehicleModels);
router.get('/', authenticate, getUserVehicles);
router.post('/', authenticate, addUserVehicle);
router.delete('/:id', authenticate, removeUserVehicle);

export default router;
