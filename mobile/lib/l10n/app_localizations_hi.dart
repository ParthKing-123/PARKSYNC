// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ParkSync';

  @override
  String get tagline => 'स्मार्ट तरीके से पार्क करें, कहीं भी।';

  @override
  String get findParking => 'पार्किंग खोजें';

  @override
  String get offerParking => 'पार्किंग दें';

  @override
  String get continueText => 'आगे बढ़ें';

  @override
  String get verifyAndContinue => 'सत्यापित करें और आगे बढ़ें';

  @override
  String get letsGetStarted => 'चलिए शुरू\nकरते हैं।';

  @override
  String get enterPhoneDesc =>
      'सत्यापन कोड प्राप्त करने के लिए अपना फ़ोन नंबर दर्ज करें।';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get verifyYourNumber => 'अपना नंबर\nसत्यापित करें।';

  @override
  String enterOtpDesc(String phone) {
    return '$phone पर भेजा गया 6-अंकीय कोड दर्ज करें';
  }

  @override
  String get searchDestination => 'आप कहाँ जा रहे हैं?';

  @override
  String get nearbySpots => 'पास के पार्किंग';

  @override
  String get scanningForSpots => 'पार्किंग खोज रहे हैं...';

  @override
  String get findParkingNear => 'अपने पास\nपार्किंग खोजें।';

  @override
  String get howItWorks => 'यह कैसे काम करता है';

  @override
  String get forDrivers => 'ड्राइवरों के लिए';

  @override
  String get forDriversDesc =>
      'पूरे भारत में हजारों पार्किंग स्पॉट ब्राउज़ करें। सेकंड में बुक करें, तनावमुक्त पार्क करें।';

  @override
  String get forProviders => 'प्रदाताओं के लिए';

  @override
  String get forProvidersDesc =>
      'खाली जगह है? ParkSync पर लिस्ट करें और हर घंटे कमाएं।';

  @override
  String get exploreParking => 'पार्किंग एक्सप्लोर करें';

  @override
  String get listYourSpace => 'अपनी जगह सूचीबद्ध करें';

  @override
  String get loginToContinue => 'जारी रखने के लिए लॉगिन करें';

  @override
  String get loginToContinueDesc =>
      'इस स्पॉट को बुक करने और अपनी बुकिंग प्रबंधित करने के लिए निःशुल्क खाता बनाएं।';

  @override
  String get activeBooking => 'सक्रिय बुकिंग';

  @override
  String get captureBeforePhoto => 'पहले की फ़ोटो लेने के लिए टैप करें';

  @override
  String get selectedVehicle => 'चयनित वाहन';

  @override
  String get changeVehicle => 'बदलें';

  @override
  String get explore => 'एक्सप्लोर';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get bookings => 'बुकिंग';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get compatibleWithMyVehicle => 'मेरे वाहन के साथ संगत';

  @override
  String get coveredParking => 'ढका हुआ पार्किंग';

  @override
  String get cctvSurveillance => 'सीसीटीवी निगरानी';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get features => 'विशेषताएं';

  @override
  String get providerInfo => 'प्रदाता जानकारी';

  @override
  String get selectTimeAndBook => 'समय चुनें और बुक करें';

  @override
  String get verifiedOfficeBldg => 'सत्यापित कार्यालय भवन';

  @override
  String get businessVerified => 'व्यवसाय सत्यापित • पार्किंग सत्यापित';

  @override
  String get fitsYourVehicle => 'यह पार्किंग स्थान में फिट है ✓';

  @override
  String get loadingMap => 'मानचित्र लोड हो रहा है...';

  @override
  String get offerParkingTitle => 'पार्किंग दें';

  @override
  String get whatTypeOfProvider => 'आप किस प्रकार के पार्किंग प्रदाता हैं?';

  @override
  String get providerTypeDesc =>
      'यह हमें आपकी लिस्टिंग के लिए सही सत्यापन सेट करने में मदद करता है।';

  @override
  String get restaurantCafe => 'रेस्तरां / कैफे';

  @override
  String get restaurantCafeDesc =>
      'अप्रयुक्त ग्राहक पार्किंग स्लॉट प्रदान करें।';

  @override
  String get officeCorporate => 'कार्यालय / कॉर्पोरेट';

  @override
  String get officeCorporateDesc =>
      'सप्ताहांत या रात के दौरान खाली पार्किंग का मुद्रीकरण करें।';

  @override
  String get personalPrivate => 'व्यक्तिगत / निजी';

  @override
  String get personalPrivateDesc =>
      'अपना निजी ड्राइववे या आवंटित स्लॉट सूचीबद्ध करें।';

  @override
  String get otherBusiness => 'अन्य व्यवसाय';

  @override
  String get otherBusinessDesc => 'होटल, मॉल, अस्पताल, या शैक्षणिक संस्था।';

  @override
  String get english => 'English';

  @override
  String get marathi => 'मराठी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get language => 'भाषा';

  @override
  String get searchPlaceholder => 'गंतव्य या क्षेत्र खोजें...';

  @override
  String kmAway(String distance) {
    return '$distance किमी दूर';
  }

  @override
  String perHour(String rate) {
    return '₹$rate/घंटा';
  }

  @override
  String get compatible => 'संगत';

  @override
  String get covered => 'ढका हुआ';

  @override
  String get cctv => 'सीसीटीवी';

  @override
  String get verified => 'सत्यापित';
}
