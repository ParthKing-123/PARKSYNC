import { Request, Response } from 'express';
import { prisma } from '../../index';
import { v4 as uuidv4 } from 'uuid';

export const createParkingSpace = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user.userId;

    let profile = await prisma.providerProfile.findUnique({ where: { userId } });
    if (!profile) {
      // Auto-create individual provider profile if not yet created
      profile = await prisma.providerProfile.create({
        data: {
          userId,
          providerType: 'INDIVIDUAL',
          displayName: req.body.hostName || 'Parking Host',
          verificationStatus: 'VERIFIED'
        }
      });
      // Ensure PROVIDER role
      await prisma.userRole.upsert({
        where: { userId_role: { userId, role: 'PROVIDER' } },
        update: {},
        create: { userId, role: 'PROVIDER' }
      });
    }

    const {
      title,
      description,
      address,
      city,
      area,
      latitude,
      longitude,
      spaceType = 'DRIVEWAY',
      covered = false,
      cctv = false,
      security = false,
      widthMm = 2500,
      lengthMm = 5000,
      heightClearanceMm = null,
      pricePerHour = 40,
      totalBays = 1,
      availableBays,
    } = req.body;

    const lat = parseFloat(latitude) || 18.5204;
    const lng = parseFloat(longitude) || 73.8567;
    const baysTotal = parseInt(totalBays) || 1;
    const baysAvail = availableBays !== undefined ? parseInt(availableBays) : baysTotal;
    const spaceId = uuidv4();

    await prisma.$executeRaw`
      INSERT INTO "ParkingSpace" (
        "id", "providerId", "title", "description", "address", "city", "area", 
        "latitude", "longitude", "location", "spaceType", "covered", "cctv", 
        "security", "widthMm", "lengthMm", "heightClearanceMm", "pricePerHour",
        "totalBays", "availableBays", "status", "verificationStatus",
        "createdAt", "updatedAt"
      )
      VALUES (
        ${spaceId}, ${profile.id}, ${title}, ${description || null}, ${address}, ${city}, ${area || city},
        ${lat}, ${lng}, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326),
        ${spaceType}, ${Boolean(covered)}, ${Boolean(cctv)}, ${Boolean(security)}, 
        ${widthMm}, ${lengthMm}, ${heightClearanceMm}, ${parseFloat(pricePerHour)},
        ${baysTotal}, ${baysAvail}, 'ACTIVE'::"ListingStatus", 'VERIFIED'::"VerificationStatus",
        NOW(), NOW()
      );
    `;

    const space = await prisma.parkingSpace.findUnique({
      where: { id: spaceId },
      include: {
        provider: {
          select: {
            id: true,
            displayName: true,
            user: { select: { name: true } }
          }
        }
      }
    });

    res.status(201).json(space);
  } catch (error) {
    console.error('Error creating parking space:', error);
    res.status(500).json({ error: 'Failed to create parking space' });
  }
};

export const getAllParkingSpaces = async (req: Request, res: Response): Promise<void> => {
  try {
    const spaces = await prisma.parkingSpace.findMany({
      where: { status: 'ACTIVE' },
      include: {
        provider: {
          select: {
            id: true,
            displayName: true,
            providerType: true,
            verificationStatus: true,
            user: {
              select: {
                name: true,
                // Notice: Provider phone number is deliberately NOT exposed to public seekers for privacy
              }
            }
          }
        },
        images: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(spaces);
  } catch (error) {
    console.error('Error fetching parking spaces:', error);
    res.status(500).json({ error: 'Failed to fetch parking spaces' });
  }
};

export const getParkingSpaceById = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const space = await prisma.parkingSpace.findUnique({
      where: { id },
      include: {
        provider: {
          select: {
            id: true,
            displayName: true,
            providerType: true,
            verificationStatus: true,
            user: {
              select: {
                name: true,
              }
            }
          }
        },
        images: true
      }
    });

    if (!space) {
      res.status(404).json({ error: 'Parking space not found' });
      return;
    }

    res.json(space);
  } catch (error) {
    console.error('Error fetching parking space details:', error);
    res.status(500).json({ error: 'Failed to fetch space details' });
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
      res.json([]);
      return;
    }

    res.json(profile.parkingSpaces);
  } catch (error) {
    console.error('Error getting my spaces:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const searchParking = async (req: Request, res: Response): Promise<void> => {
  try {
    const { lat, lng, radiusKm, q } = req.query;

    if (!lat || !lng) {
      // Fallback: search by query string or return all active spaces
      const whereClause: any = { status: 'ACTIVE' };
      if (q && typeof q === 'string' && q.trim().length > 0) {
        whereClause.OR = [
          { title: { contains: q, mode: 'insensitive' } },
          { address: { contains: q, mode: 'insensitive' } },
          { city: { contains: q, mode: 'insensitive' } },
          { area: { contains: q, mode: 'insensitive' } },
        ];
      }
      const spaces = await prisma.parkingSpace.findMany({
        where: whereClause,
        include: {
          provider: {
            select: {
              id: true,
              displayName: true,
              user: { select: { name: true } }
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });
      res.json(spaces);
      return;
    }

    const radiusInMeters = (parseFloat(radiusKm as string) || 10.0) * 1000;
    
    const nearbySpaces: any[] = await prisma.$queryRaw`
      SELECT s.id, s."providerId", s.title, s.description, s.address, s.city, s.area,
             s.latitude, s.longitude, s."pricePerHour", s."spaceType", s.covered, s.cctv, 
             s.security, s."totalBays", s."availableBays", s.status,
             p."displayName" as "hostDisplayName", u.name as "hostName",
             ST_DistanceSphere(s.location, ST_MakePoint(${parseFloat(lng as string)}, ${parseFloat(lat as string)})) as distance_meters
      FROM "ParkingSpace" s
      JOIN "ProviderProfile" p ON s."providerId" = p.id
      JOIN "User" u ON p."userId" = u.id
      WHERE ST_DWithin(
        s.location, 
        ST_SetSRID(ST_MakePoint(${parseFloat(lng as string)}, ${parseFloat(lat as string)}), 4326), 
        ${radiusInMeters}
      )
      AND s.status = 'ACTIVE'
      ORDER BY distance_meters ASC
      LIMIT 50;
    `;

    res.json(nearbySpaces);
  } catch (error) {
    console.error('Error in searchParking:', error);
    // Graceful fallback to all active spaces
    try {
      const fallback = await prisma.parkingSpace.findMany({
        where: { status: 'ACTIVE' },
        include: {
          provider: {
            select: {
              id: true,
              displayName: true,
              user: { select: { name: true } }
            }
          }
        }
      });
      res.json(fallback);
    } catch {
      res.status(500).json({ error: 'Search failed' });
    }
  }
};
