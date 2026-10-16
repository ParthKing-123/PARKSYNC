// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ParkSync';

  @override
  String get tagline => 'Park smarter, anywhere.';

  @override
  String get findParking => 'Find Parking';

  @override
  String get offerParking => 'Offer Parking';

  @override
  String get continueText => 'Continue';

  @override
  String get verifyAndContinue => 'Verify & Continue';

  @override
  String get letsGetStarted => 'Let\'s get\nstarted.';

  @override
  String get enterPhoneDesc =>
      'Enter your phone number to receive a verification code.';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get verifyYourNumber => 'Verify your\nnumber.';

  @override
  String enterOtpDesc(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get searchDestination => 'Where are you going?';

  @override
  String get nearbySpots => 'Nearby spots';

  @override
  String get scanningForSpots => 'Scanning for spots...';

  @override
  String get findParkingNear => 'Find parking\nnear you.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get forDrivers => 'For Drivers';

  @override
  String get forDriversDesc =>
      'Browse thousands of parking spots across India. Book in seconds, park stress-free.';

  @override
  String get forProviders => 'For Providers';

  @override
  String get forProvidersDesc =>
      'Have an empty bay or driveway? List it on ParkSync and earn every hour it\'s used.';

  @override
  String get exploreParking => 'Explore Parking';

  @override
  String get listYourSpace => 'List Your Space';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get loginToContinueDesc =>
      'Create a free account to book this spot and manage your bookings.';

  @override
  String get activeBooking => 'Active Booking';

  @override
  String get captureBeforePhoto => 'Tap to capture BEFORE photo';

  @override
  String get selectedVehicle => 'Selected Vehicle';

  @override
  String get changeVehicle => 'Change';

  @override
  String get explore => 'Explore';

  @override
  String get saved => 'Saved';

  @override
  String get bookings => 'Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get filters => 'Filters';

  @override
  String get compatibleWithMyVehicle => 'Compatible with my vehicle';

  @override
  String get coveredParking => 'Covered Parking';

  @override
  String get cctvSurveillance => 'CCTV Surveillance';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get features => 'Features';

  @override
  String get providerInfo => 'Provider Info';

  @override
  String get selectTimeAndBook => 'Select Time & Book';

  @override
  String get verifiedOfficeBldg => 'Verified Office Building';

  @override
  String get businessVerified => 'Business Verified • Parking Verified';

  @override
  String get fitsYourVehicle => 'Fits this parking space ✓';

  @override
  String get loadingMap => 'Loading Map...';

  @override
  String get offerParkingTitle => 'Offer Parking';

  @override
  String get whatTypeOfProvider => 'What type of parking provider are you?';

  @override
  String get providerTypeDesc =>
      'This helps us set up the right verification and rules for your listing.';

  @override
  String get restaurantCafe => 'Restaurant / Café';

  @override
  String get restaurantCafeDesc => 'Offer unused customer parking slots.';

  @override
  String get officeCorporate => 'Office / Corporate';

  @override
  String get officeCorporateDesc =>
      'Monetize empty employee parking during weekends or nights.';

  @override
  String get personalPrivate => 'Personal / Private';

  @override
  String get personalPrivateDesc =>
      'List your private driveway or allotted slot.';

  @override
  String get otherBusiness => 'Other Business';

  @override
  String get otherBusinessDesc =>
      'Hotel, Mall, Hospital, or Educational Institution.';

  @override
  String get english => 'English';

  @override
  String get marathi => 'मराठी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get language => 'Language';

  @override
  String get searchPlaceholder => 'Search destination or area...';

  @override
  String kmAway(String distance) {
    return '$distance km away';
  }

  @override
  String perHour(String rate) {
    return '₹$rate/hr';
  }

  @override
  String get compatible => 'Compatible';

  @override
  String get covered => 'Covered';

  @override
  String get cctv => 'CCTV';

  @override
  String get verified => 'Verified';
}
