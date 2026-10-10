import { Request, Response } from 'express';
import { prisma } from '../../index';

export const createParkingSpace = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;

    const profile = await prisma.providerProfile.findUnique({ where: { userId } });
    if (!profile) {
      res.status(403).json({ error: 'You must set up a provider profile first' });
      return;
    }

    const {
      title,
      description,
      address,
      city,
      area,
      latitude,
      longitude,
      spaceType,
      covered,
      cctv,
      security,
      widthMm,
      lengthMm,
      heightClearanceMm,
      pricePerHour,
    } = req.body;

    const space = await prisma.$queryRaw`
      INSERT INTO "ParkingSpace" (
        "id", "providerId", "title", "description", "address", "city", "area", 
        "latitude", "longitude", "location", "spaceType", "covered", "cctv", 
        "security", "widthMm", "lengthMm", "heightClearanceMm", "pricePerHour",
        "createdAt", "updatedAt"
      )
      VALUES (
        gen_random_uuid(), ${profile.id}, ${title}, ${description}, ${address}, ${city}, ${area},
        ${latitude}, ${longitude}, ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326),
        ${spaceType}, ${covered}, ${cctv}, ${security}, ${widthMm}, ${lengthMm}, ${heightClearanceMm}, ${pricePerHour},
        NOW(), NOW()
      )
      RETURNING *;
    `;

    res.json(space);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getMyParkingSpaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;
    
    const profile = await prisma.providerProfile.findUnique({
      where: { userId },
      include: { parkingSpaces: true }
    });

    if (!profile) {
      res.status(404).json({ error: 'Provider not found' });
      return;
    }

    res.json(profile.parkingSpaces);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const searchParking = async (req: Request, res: Response): Promise<void> => {
  try {
    const { lat, lng, radiusKm, vehicleId } = req.query;

    if (!lat || !lng) {
      res.status(400).json({ error: 'lat and lng are required' });
      return;
    }

    const radiusInMeters = (parseFloat(radiusKm as string) || 2.0) * 1000;
    
    // 1. PostGIS Query to find spaces within radius
    const nearbySpaces: any[] = await prisma.$queryRaw`
      SELECT id, "providerId", title, address, "pricePerHour", "spaceType", 
             covered, cctv, security, "widthMm", "lengthMm", "heightClearanceMm",
             ST_DistanceSphere(location, ST_MakePoint(${parseFloat(lng as string)}, ${parseFloat(lat as string)})) as distance_meters
      FROM "ParkingSpace"
      WHERE ST_DWithin(
        location, 
        ST_SetSRID(ST_MakePoint(${parseFloat(lng as string)}, ${parseFloat(lat as string)}), 4326), 
        ${radiusInMeters}
      )
      AND status = 'ACTIVE'
      ORDER BY distance_meters ASC
      LIMIT 50;
    `;

    // 2. Compatibility check (if vehicleId provided)
    let results = nearbySpaces;
    
    if (vehicleId) {
      const vehicle = await prisma.vehicle.findUnique({
        where: { id: vehicleId as string },
        include: { vehicleModel: true }
      });

      if (vehicle) {
        const { CompatibilityService } = require('./compatibility.service');
        
        results = nearbySpaces.map(space => {
          const compat = CompatibilityService.checkCompatibility(vehicle.vehicleModel, space);
          return {
            ...space,
            isCompatible: compat.isCompatible,
            compatibilityReason: compat.reason
          };
        });
      }
    }

    res.json(results);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
