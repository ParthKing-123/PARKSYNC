import { ParkingSpace, VehicleModel } from '@prisma/client';

export interface CompatibilityResult {
  isCompatible: boolean;
  reason?: string;
}

export class CompatibilityService {
  // Configurable safety margins (in mm)
  private static LENGTH_MARGIN = 300; // 30cm total extra length needed
  private static WIDTH_MARGIN = 400;  // 40cm total extra width needed (doors)
  private static HEIGHT_MARGIN = 100; // 10cm extra height clearance

  static checkCompatibility(vehicle: VehicleModel, space: ParkingSpace): CompatibilityResult {
    const requiredLength = vehicle.lengthMm + this.LENGTH_MARGIN;
    const requiredWidth = vehicle.widthMm + this.WIDTH_MARGIN;
    const requiredHeight = vehicle.heightMm + this.HEIGHT_MARGIN;

    if (space.lengthMm < requiredLength) {
      return { isCompatible: false, reason: 'Length clearance insufficient.' };
    }

    if (space.widthMm < requiredWidth) {
      return { isCompatible: false, reason: 'Width clearance insufficient.' };
    }

    if (space.heightClearanceMm && space.heightClearanceMm < requiredHeight) {
      return { isCompatible: false, reason: 'Height clearance insufficient.' };
    }

    return { isCompatible: true };
  }
}
