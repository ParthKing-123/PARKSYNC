import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/guest_home_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/role_selection_screen.dart';
import '../features/onboarding/presentation/seeker_profile_screen.dart';
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
import '../features/guide/presentation/user_guide_screen.dart';
import '../features/legal/presentation/privacy_policy_screen.dart';

/// Smooth fade and slide page transition for a premium application feel.
CustomTransitionPage<T> _buildPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    // ── Guest entry point (no auth required) ──────────────────────────
    GoRoute(
      path: '/guest-home',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const GuestHomeScreen(),
      ),
    ),
    // ── Auth flow ─────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/verify-otp',
      pageBuilder: (context, state) {
        String phone = '';
        String role = 'seeker';
        String? verificationId;
        if (state.extra is Map<String, dynamic>) {
          final m = state.extra as Map<String, dynamic>;
          phone = m['phone']?.toString() ?? '';
          role = m['role']?.toString() ?? 'seeker';
          verificationId = m['verificationId']?.toString();
        } else if (state.extra is String) {
          phone = state.extra as String;
        }
        return _buildPage(
          state: state,
          child: VerifyOtpScreen(
            phoneNumber: phone,
            role: role,
            verificationId: verificationId,
          ),
        );
      },
    ),
    // ── Seeker Onboarding Flow ───────────────────────────────────────
    GoRoute(
      path: '/seeker-profile-setup',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const SeekerProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/seeker-vehicle-setup',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const AddVehicleScreen(isFromOnboarding: true),
      ),
    ),
    // ── Knowledge & Legal Pages ──────────────────────────────────────
    GoRoute(
      path: '/user-guide',
      pageBuilder: (context, state) {
        final tab = state.extra is int ? (state.extra as int) : 0;
        return _buildPage(
          state: state,
          child: UserGuideScreen(initialTab: tab),
        );
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) {
        final tab = state.extra is int ? (state.extra as int) : 0;
        return _buildPage(
          state: state,
          child: PrivacyPolicyScreen(initialTab: tab),
        );
      },
    ),
    // ── Logged-in home ────────────────────────────────────────────────
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    // ── Onboarding / role info (informational only) ───────────────────
    GoRoute(
      path: '/role-selection',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const RoleSelectionScreen(),
      ),
    ),
    // ── Provider flow ─────────────────────────────────────────────────
    GoRoute(
      path: '/provider-onboarding',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const ProviderOnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/add-parking',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: AddParkingScreen(providerType: state.extra as String? ?? 'OTHER'),
      ),
    ),
    GoRoute(
      path: '/provider-home',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const ProviderHomeScreen(),
      ),
    ),
    // ── Core driver flow ──────────────────────────────────────────────
    GoRoute(
      path: '/add-vehicle',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const AddVehicleScreen(),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: SearchScreen(destination: state.extra as String? ?? ''),
      ),
    ),
    GoRoute(
      path: '/parking-detail',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: ParkingDetailScreen(parkingId: state.extra as String? ?? ''),
      ),
    ),
    GoRoute(
      path: '/booking-checkout',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: BookingCheckoutScreen(bookingData: state.extra),
      ),
    ),
    GoRoute(
      path: '/booking-confirmation',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: BookingConfirmationScreen(bookingData: state.extra),
      ),
    ),
    GoRoute(
      path: '/capture-evidence',
      pageBuilder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return _buildPage(
          state: state,
          child: CaptureEvidenceScreen(
            bookingId: args['bookingId'] ?? '',
            type: args['type'] ?? 'BEFORE',
          ),
        );
      },
    ),
    GoRoute(
      path: '/add-review',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: AddReviewScreen(bookingId: state.extra as String? ?? ''),
      ),
    ),
  ],
);
