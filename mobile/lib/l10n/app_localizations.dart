import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ParkSync'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Park smarter, anywhere.'**
  String get tagline;

  /// No description provided for @findParking.
  ///
  /// In en, this message translates to:
  /// **'Find Parking'**
  String get findParking;

  /// No description provided for @offerParking.
  ///
  /// In en, this message translates to:
  /// **'Offer Parking'**
  String get offerParking;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get\nstarted.'**
  String get letsGetStarted;

  /// No description provided for @enterPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a verification code.'**
  String get enterPhoneDesc;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your\nnumber.'**
  String get verifyYourNumber;

  /// No description provided for @enterOtpDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String enterOtpDesc(String phone);

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get searchDestination;

  /// No description provided for @nearbySpots.
  ///
  /// In en, this message translates to:
  /// **'Nearby spots'**
  String get nearbySpots;

  /// No description provided for @scanningForSpots.
  ///
  /// In en, this message translates to:
  /// **'Scanning for spots...'**
  String get scanningForSpots;

  /// No description provided for @findParkingNear.
  ///
  /// In en, this message translates to:
  /// **'Find parking\nnear you.'**
  String get findParkingNear;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @forDrivers.
  ///
  /// In en, this message translates to:
  /// **'For Drivers'**
  String get forDrivers;

  /// No description provided for @forDriversDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of parking spots across India. Book in seconds, park stress-free.'**
  String get forDriversDesc;

  /// No description provided for @forProviders.
  ///
  /// In en, this message translates to:
  /// **'For Providers'**
  String get forProviders;

  /// No description provided for @forProvidersDesc.
  ///
  /// In en, this message translates to:
  /// **'Have an empty bay or driveway? List it on ParkSync and earn every hour it\'s used.'**
  String get forProvidersDesc;

  /// No description provided for @exploreParking.
  ///
  /// In en, this message translates to:
  /// **'Explore Parking'**
  String get exploreParking;

  /// No description provided for @listYourSpace.
  ///
  /// In en, this message translates to:
  /// **'List Your Space'**
  String get listYourSpace;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @loginToContinueDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a free account to book this spot and manage your bookings.'**
  String get loginToContinueDesc;

  /// No description provided for @activeBooking.
  ///
  /// In en, this message translates to:
  /// **'Active Booking'**
  String get activeBooking;

  /// No description provided for @captureBeforePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture BEFORE photo'**
  String get captureBeforePhoto;

  /// No description provided for @selectedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Selected Vehicle'**
  String get selectedVehicle;

  /// No description provided for @changeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeVehicle;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @compatibleWithMyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Compatible with my vehicle'**
  String get compatibleWithMyVehicle;

  /// No description provided for @coveredParking.
  ///
  /// In en, this message translates to:
  /// **'Covered Parking'**
  String get coveredParking;

  /// No description provided for @cctvSurveillance.
  ///
  /// In en, this message translates to:
  /// **'CCTV Surveillance'**
  String get cctvSurveillance;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @providerInfo.
  ///
  /// In en, this message translates to:
  /// **'Provider Info'**
  String get providerInfo;

  /// No description provided for @selectTimeAndBook.
  ///
  /// In en, this message translates to:
  /// **'Select Time & Book'**
  String get selectTimeAndBook;

  /// No description provided for @verifiedOfficeBldg.
  ///
  /// In en, this message translates to:
  /// **'Verified Office Building'**
  String get verifiedOfficeBldg;

  /// No description provided for @businessVerified.
  ///
  /// In en, this message translates to:
  /// **'Business Verified • Parking Verified'**
  String get businessVerified;

  /// No description provided for @fitsYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Fits this parking space ✓'**
  String get fitsYourVehicle;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading Map...'**
  String get loadingMap;

  /// No description provided for @offerParkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer Parking'**
  String get offerParkingTitle;

  /// No description provided for @whatTypeOfProvider.
  ///
  /// In en, this message translates to:
  /// **'What type of parking provider are you?'**
  String get whatTypeOfProvider;

  /// No description provided for @providerTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'This helps us set up the right verification and rules for your listing.'**
  String get providerTypeDesc;

  /// No description provided for @restaurantCafe.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / Café'**
  String get restaurantCafe;

  /// No description provided for @restaurantCafeDesc.
  ///
  /// In en, this message translates to:
  /// **'Offer unused customer parking slots.'**
  String get restaurantCafeDesc;

  /// No description provided for @officeCorporate.
  ///
  /// In en, this message translates to:
  /// **'Office / Corporate'**
  String get officeCorporate;

  /// No description provided for @officeCorporateDesc.
  ///
  /// In en, this message translates to:
  /// **'Monetize empty employee parking during weekends or nights.'**
  String get officeCorporateDesc;

  /// No description provided for @personalPrivate.
  ///
  /// In en, this message translates to:
  /// **'Personal / Private'**
  String get personalPrivate;

  /// No description provided for @personalPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'List your private driveway or allotted slot.'**
  String get personalPrivateDesc;

  /// No description provided for @otherBusiness.
  ///
  /// In en, this message translates to:
  /// **'Other Business'**
  String get otherBusiness;

  /// No description provided for @otherBusinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Hotel, Mall, Hospital, or Educational Institution.'**
  String get otherBusinessDesc;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search destination or area...'**
  String get searchPlaceholder;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'₹{rate}/hr'**
  String perHour(String rate);

  /// No description provided for @compatible.
  ///
  /// In en, this message translates to:
  /// **'Compatible'**
  String get compatible;

  /// No description provided for @covered.
  ///
  /// In en, this message translates to:
  /// **'Covered'**
  String get covered;

  /// No description provided for @cctv.
  ///
  /// In en, this message translates to:
  /// **'CCTV'**
  String get cctv;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
