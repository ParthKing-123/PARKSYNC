import 'package:go_router/go_router.dart';

import '../features/home/presentation/guest_home_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/role_selection_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/verify_otp_screen.dart';
import '../features/vehicles/presentation/add_vehicle_screen.dart';
import '../features/provider/presentation/provider_onboarding_screen.dart';
import '../features/parking/presentation/add_parking_screen.dart';
import '../features/provider/presentation/provider_home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/parking/presentation/parking_detail_screen.dart';
import '../features/bookings/presentation/booking_checkout_screen.dart';
import '../features/bookings/presentation/booking_confirmation_screen.dart';
import '../features/bookings/presentation/capture_evidence_screen.dart';
import '../features/reviews/presentation/add_review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // ── Guest entry point (no auth required) ──────────────────────────
    GoRoute(
      path: '/guest-home',
      builder: (context, state) => const GuestHomeScreen(),
    ),
    // ── Auth flow ─────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) =>
          VerifyOtpScreen(phoneNumber: state.extra as String? ?? ''),
    ),
    // ── Logged-in home ────────────────────────────────────────────────
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    // ── Onboarding / role info (informational only) ───────────────────
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    // ── Provider flow ─────────────────────────────────────────────────
    GoRoute(
      path: '/provider-onboarding',
      builder: (context, state) => const ProviderOnboardingScreen(),
    ),
    GoRoute(
      path: '/add-parking',
      builder: (context, state) =>
          AddParkingScreen(providerType: state.extra as String? ?? 'OTHER'),
    ),
    GoRoute(
      path: '/provider-home',
      builder: (context, state) => const ProviderHomeScreen(),
    ),
    // ── Core driver flow ──────────────────────────────────────────────
    GoRoute(
      path: '/add-vehicle',
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          SearchScreen(destination: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/parking-detail',
      builder: (context, state) =>
          ParkingDetailScreen(parkingId: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/booking-checkout',
      builder: (context, state) =>
          BookingCheckoutScreen(bookingData: state.extra),
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (context, state) =>
          BookingConfirmationScreen(bookingData: state.extra),
    ),
    GoRoute(
      path: '/capture-evidence',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return CaptureEvidenceScreen(
          bookingId: args['bookingId'] ?? '',
          type: args['type'] ?? 'BEFORE',
        );
      },
    ),
    GoRoute(
      path: '/add-review',
      builder: (context, state) =>
          AddReviewScreen(bookingId: state.extra as String? ?? ''),
    ),
  ],
);
