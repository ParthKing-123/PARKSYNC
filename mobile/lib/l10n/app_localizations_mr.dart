// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'ParkSync';

  @override
  String get tagline => 'स्मार्टपणे पार्क करा, कुठेही.';

  @override
  String get findParking => 'पार्किंग शोधा';

  @override
  String get offerParking => 'पार्किंग द्या';

  @override
  String get continueText => 'पुढे चला';

  @override
  String get verifyAndContinue => 'सत्यापित करा आणि पुढे चला';

  @override
  String get letsGetStarted => 'चला सुरुवात\nकरूया.';

  @override
  String get enterPhoneDesc =>
      'पडताळणी कोड मिळविण्यासाठी आपला फोन नंबर प्रविष्ट करा.';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get verifyYourNumber => 'आपला नंबर\nसत्यापित करा.';

  @override
  String enterOtpDesc(String phone) {
    return '$phone वर पाठवलेला 6-अंकी कोड प्रविष्ट करा';
  }

  @override
  String get searchDestination => 'तुम्ही कुठे जात आहात?';

  @override
  String get nearbySpots => 'जवळचे पार्किंग';

  @override
  String get scanningForSpots => 'पार्किंग शोधत आहे...';

  @override
  String get findParkingNear => 'तुमच्या जवळचे\nपार्किंग शोधा.';

  @override
  String get howItWorks => 'हे कसे कार्य करते';

  @override
  String get forDrivers => 'चालकांसाठी';

  @override
  String get forDriversDesc =>
      'भारतभर हजारो पार्किंग स्पॉट ब्राउझ करा. सेकंदात बुक करा, तणावमुक्त पार्क करा.';

  @override
  String get forProviders => 'प्रदात्यांसाठी';

  @override
  String get forProvidersDesc =>
      'रिकामी जागा आहे का? ParkSync वर सूचीबद्ध करा आणि प्रत्येक तास कमवा.';

  @override
  String get exploreParking => 'पार्किंग एक्सप्लोर करा';

  @override
  String get listYourSpace => 'तुमची जागा सूचीबद्ध करा';

  @override
  String get loginToContinue => 'पुढे जाण्यासाठी लॉगिन करा';

  @override
  String get loginToContinueDesc =>
      'हे स्पॉट बुक करण्यासाठी आणि बुकिंग व्यवस्थापित करण्यासाठी विनामूल्य खाते तयार करा.';

  @override
  String get activeBooking => 'सक्रिय बुकिंग';

  @override
  String get captureBeforePhoto => 'आधीचा फोटो काढण्यासाठी टॅप करा';

  @override
  String get selectedVehicle => 'निवडलेले वाहन';

  @override
  String get changeVehicle => 'बदला';

  @override
  String get explore => 'एक्सप्लोर';

  @override
  String get saved => 'जतन केलेले';

  @override
  String get bookings => 'बुकिंग';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get filters => 'फिल्टर';

  @override
  String get compatibleWithMyVehicle => 'माझ्या वाहनाशी सुसंगत';

  @override
  String get coveredParking => 'आच्छादित पार्किंग';

  @override
  String get cctvSurveillance => 'सीसीटीव्ही पाळत';

  @override
  String get applyFilters => 'फिल्टर लागू करा';

  @override
  String get features => 'वैशिष्ट्ये';

  @override
  String get providerInfo => 'प्रदाता माहिती';

  @override
  String get selectTimeAndBook => 'वेळ निवडा आणि बुक करा';

  @override
  String get verifiedOfficeBldg => 'सत्यापित कार्यालय इमारत';

  @override
  String get businessVerified => 'व्यवसाय सत्यापित • पार्किंग सत्यापित';

  @override
  String get fitsYourVehicle => 'हे पार्किंग स्पेसमध्ये बसते ✓';

  @override
  String get loadingMap => 'नकाशा लोड होत आहे...';

  @override
  String get offerParkingTitle => 'पार्किंग द्या';

  @override
  String get whatTypeOfProvider =>
      'तुम्ही कोणत्या प्रकारचे पार्किंग प्रदाता आहात?';

  @override
  String get providerTypeDesc =>
      'हे आम्हाला तुमच्या लिस्टिंगसाठी योग्य सत्यापन सेट करण्यात मदत करते.';

  @override
  String get restaurantCafe => 'रेस्टॉरंट / कॅफे';

  @override
  String get restaurantCafeDesc =>
      'न वापरलेल्या ग्राहक पार्किंग स्लॉट्स ऑफर करा.';

  @override
  String get officeCorporate => 'कार्यालय / कॉर्पोरेट';

  @override
  String get officeCorporateDesc =>
      'शनिवार-रविवार किंवा रात्री रिकामे पार्किंग मुद्रीकृत करा.';

  @override
  String get personalPrivate => 'वैयक्तिक / खाजगी';

  @override
  String get personalPrivateDesc =>
      'तुमचा खाजगी ड्राईव्हवे किंवा वाटप केलेला स्लॉट सूचीबद्ध करा.';

  @override
  String get otherBusiness => 'इतर व्यवसाय';

  @override
  String get otherBusinessDesc =>
      'हॉटेल, मॉल, रुग्णालय, किंवा शैक्षणिक संस्था.';

  @override
  String get english => 'English';

  @override
  String get marathi => 'मराठी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get language => 'भाषा';

  @override
  String get searchPlaceholder => 'गंतव्य किंवा क्षेत्र शोधा...';

  @override
  String kmAway(String distance) {
    return '$distance किमी दूर';
  }

  @override
  String perHour(String rate) {
    return '₹$rate/तास';
  }

  @override
  String get compatible => 'सुसंगत';

  @override
  String get covered => 'आच्छादित';

  @override
  String get cctv => 'सीसीटीव्ही';

  @override
  String get verified => 'सत्यापित';
}
