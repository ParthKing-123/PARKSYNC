# ParkSync

A production-quality V1 mobile-first parking marketplace for India, focusing on vehicle-space compatibility.

## Project Structure
- `/mobile`: Flutter app for Seekers and Providers.
- `/backend`: Node.js, TypeScript, Express API, Prisma ORM with PostGIS.
- `/admin`: React, TypeScript, TailwindCSS internal dashboard.
- `/website`: React, TypeScript informational landing page.
- `/database`: Migrations and seed data configurations.

## Tech Stack
- **Mobile**: Flutter, Dart, GoRouter, Google Maps Flutter.
- **Backend**: Node.js, Express, Prisma ORM, PostgreSQL (with PostGIS), TypeScript.
- **Frontend (Admin/Website)**: React, Vite, TailwindCSS v4.

## Setup Instructions

### Backend Setup
1. Navigate to `/backend`.
2. Copy `.env.example` to `.env` and fill in your DB credentials and (later) your Firebase/Google Maps API keys. (Currently defaults to mock values for pilot development).
3. Ensure PostgreSQL with PostGIS is running.
4. Run `npm install`.
5. Run `npx prisma db push` (or `migrate dev`) to sync the schema.
6. Run `npm run dev` to start the Express server.

### Mobile Setup
1. Navigate to `/mobile`.
2. Run `flutter pub get`.
3. Run `flutter run` on an emulator or physical device.

### Admin Dashboard Setup
1. Navigate to `/admin`.
2. Run `npm install`.
3. Run `npm run dev`.

### Website Setup
1. Navigate to `/website`.
2. Run `npm install`.
3. Run `npm run dev`.

## Current State
Phase 1 (Foundation) setup is complete.
- Monorepo folder structure created.
- Backend Prisma schema with `PostGIS` support initialized.
- Admin and Website React projects scaffolded with Tailwind v4.
- Mobile Flutter project base created with Matiks-inspired dark premium theme.

Next phases will implement Seeker onboarding, Vehicle Compatibility Engine, and Provider flows.
