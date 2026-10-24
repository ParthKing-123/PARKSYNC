import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Connecting to database...');
  
  // Count records before deletion
  const usersBefore = await prisma.user.count();
  const providersBefore = await prisma.providerProfile.count();
  const spacesBefore = await prisma.parkingSpace.count();
  const bookingsBefore = await prisma.booking.count();

  console.log(`Current records:`);
  console.log(`- Users: ${usersBefore}`);
  console.log(`- Provider Profiles: ${providersBefore}`);
  console.log(`- Parking Spaces: ${spacesBefore}`);
  console.log(`- Bookings: ${bookingsBefore}`);

  console.log('\nTruncating all user and provider data tables (preserving table schema and structure)...');

  // Truncate tables with CASCADE to preserve structure, enums, triggers, and PostGIS columns
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE 
      "Review", 
      "Payment", 
      "BookingEvidence", 
      "Booking", 
      "Availability", 
      "ParkingImage", 
      "ParkingSpace", 
      "Vehicle", 
      "OrganizationMember", 
      "Organization", 
      "ProviderProfile", 
      "UserRole", 
      "User" 
    CASCADE;
  `);

  console.log('Truncation complete!');

  // Verify counts
  const usersAfter = await prisma.user.count();
  const providersAfter = await prisma.providerProfile.count();
  const spacesAfter = await prisma.parkingSpace.count();
  const bookingsAfter = await prisma.booking.count();

  console.log(`\nRemaining records:`);
  console.log(`- Users: ${usersAfter}`);
  console.log(`- Provider Profiles: ${providersAfter}`);
  console.log(`- Parking Spaces: ${spacesAfter}`);
  console.log(`- Bookings: ${bookingsAfter}`);
  console.log('\nAll user and provider data has been safely cleared! Table structures are intact.');
}

main()
  .catch((e) => {
    console.error('Error clearing data:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
