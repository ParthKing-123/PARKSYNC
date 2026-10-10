import { Request, Response } from 'express';
import { prisma } from '../../index';

export const getVehicleModels = async (req: Request, res: Response): Promise<void> => {
  try {
    const models = await prisma.vehicleModel.findMany({
      orderBy: [{ make: 'asc' }, { model: 'asc' }]
    });
    res.json(models);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getUserVehicles = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const vehicles = await prisma.vehicle.findMany({
      where: { userId },
      include: { vehicleModel: true }
    });
    res.json(vehicles);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const addUserVehicle = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { vehicleModelId, registrationNumber, vehicleColor, isPrimary } = req.body;

    if (!vehicleModelId || !registrationNumber) {
      res.status(400).json({ error: 'vehicleModelId and registrationNumber are required' });
      return;
    }

    // If making this primary, unset other primaries
    if (isPrimary) {
      await prisma.vehicle.updateMany({
        where: { userId, isPrimary: true },
        data: { isPrimary: false }
      });
    }

    const vehicle = await prisma.vehicle.create({
      data: {
        userId,
        vehicleModelId,
        registrationNumber,
        vehicleColor,
        isPrimary: isPrimary || false
      },
      include: { vehicleModel: true }
    });

    res.json(vehicle);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const removeUserVehicle = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    const { id } = req.params;

    const vehicle = await prisma.vehicle.findUnique({ where: { id } });

    if (!vehicle || vehicle.userId !== userId) {
      res.status(404).json({ error: 'Vehicle not found' });
      return;
    }

    await prisma.vehicle.delete({ where: { id } });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
