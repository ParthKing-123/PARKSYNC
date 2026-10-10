import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding Vehicle Models...');

  const vehicleModels = [
    {
      make: 'Hyundai',
      model: 'Creta',
      yearStart: 2020,
      yearEnd: 2024,
      vehicleType: 'SUV',
      lengthMm: 4300,
      widthMm: 1790,
      heightMm: 1635
    },
    {
      make: 'Tata',
      model: 'Nexon',
      yearStart: 2020,
      yearEnd: 2024,
      vehicleType: 'SUV',
      lengthMm: 3995,
      widthMm: 1804,
      heightMm: 1620
    },
    {
      make: 'Maruti Suzuki',
      model: 'Swift',
      yearStart: 2018,
      yearEnd: 2024,
      vehicleType: 'Hatchback',
      lengthMm: 3845,
      widthMm: 1735,
      heightMm: 1530
    },
    {
      make: 'Mahindra',
      model: 'Thar',
      yearStart: 2020,
      yearEnd: 2024,
      vehicleType: 'SUV',
      lengthMm: 3985,
      widthMm: 1820,
      heightMm: 1844
    },
    {
      make: 'Honda',
      model: 'City',
      yearStart: 2020,
      yearEnd: 2024,
      vehicleType: 'Sedan',
      lengthMm: 4549,
      widthMm: 1748,
      heightMm: 1489
    }
  ];

  // Seed Provider & Parking Space
  console.log('Seeding Provider and Parking Space...');
  
  // Note: These use raw queries for PostGIS geometry, so we skip them here 
  // and just leave a comment for the developer to use the API directly for seeding locations.
  console.log('Use the POST /api/parking endpoint to seed locations to ensure PostGIS ST_MakePoint fires correctly.');

  for (const vm of vehicleModels) {
    await prisma.vehicleModel.create({
      data: vm
    });
  }
  
  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
