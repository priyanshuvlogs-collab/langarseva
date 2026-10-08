// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'लंगर सेवा';

  @override
  String get nearYou => 'आपके पास के लंगर';

  @override
  String get searchCityHint => 'शहर या इलाका खोजें';

  @override
  String get openNow => 'अभी खुला है';

  @override
  String get within5km => '5 किमी के अंदर';

  @override
  String get within25km => '25 किमी के अंदर';

  @override
  String get within100km => '100 किमी के अंदर';

  @override
  String get noLangarsFound =>
      'यहाँ अभी कोई लंगर नहीं मिला। कोई जानते हैं? जोड़ें!';

  @override
  String get locationPermissionDenied =>
      'लोकेशन बंद है। दिल्ली के नतीजे दिखा रहे हैं। शहर खोजें या लोकेशन चालू करें।';

  @override
  String get enableLocation => 'लोकेशन चालू करें';

  @override
  String get useMyLocation => 'मेरी लोकेशन इस्तेमाल करें';

  @override
  String kmAway(String km) {
    return '$km किमी दूर';
  }

  @override
  String mAway(int m) {
    return '$m मीटर दूर';
  }

  @override
  String get open => 'खुला';

  @override
  String get closed => 'बंद';

  @override
  String get open24h => '24 घंटे खुला';

  @override
  String get timings => 'समय';

  @override
  String get today => 'आज';

  @override
  String get noTimings => 'समय अभी नहीं जोड़ा गया';

  @override
  String get directions => 'रास्ता';

  @override
  String get call => 'कॉल';

  @override
  String get share => 'शेयर';

  @override
  String get donate => 'दान करें';

  @override
  String get donateTitle => 'इस लंगर का सहयोग करें';

  @override
  String get donateUpiId => 'UPI ID';

  @override
  String get copyUpi => 'UPI ID कॉपी करें';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String get openUpiApp => 'UPI ऐप से भुगतान';

  @override
  String get noUpiApp => 'कोई UPI ऐप नहीं मिला। UPI ID कॉपी करें।';

  @override
  String get donateWebsite => 'वेबसाइट पर दान करें';

  @override
  String get noDonateInfo =>
      'इस लंगर ने दान की जानकारी नहीं दी है। सेवा या दसवंध के लिए सीधे पहुँचें।';

  @override
  String get sevaTitle => 'सेवा (स्वयंसेवा)';

  @override
  String get sevaJoin => 'जुड़ें';

  @override
  String get sevaLeave => 'छोड़ें';

  @override
  String get sevaJoined => 'आप जुड़ गए! आपकी सेवा के लिए धन्यवाद।';

  @override
  String get sevaFull => 'भर गया';

  @override
  String get sevaNoSlots =>
      'कोई आने वाला सेवा स्लॉट नहीं। लंगर प्रबंधक स्लॉट जोड़ सकते हैं।';

  @override
  String sevaSpots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जगहें बची',
      one: '1 जगह बची',
      zero: 'कोई जगह नहीं बची',
    );
    return '$_temp0';
  }

  @override
  String volunteersJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेवादार',
      one: '1 सेवादार',
      zero: 'अभी कोई सेवादार नहीं',
    );
    return '$_temp0';
  }

  @override
  String get sevaCreateSlot => 'सेवा स्लॉट जोड़ें';

  @override
  String get slotTitle => 'कौन सी सेवा चाहिए? (जैसे रोटी बनाना)';

  @override
  String get startsAt => 'शुरू';

  @override
  String get endsAt => 'समाप्त';

  @override
  String get capacity => 'कितने सेवादार चाहिए';

  @override
  String get createdSlot => 'सेवा स्लॉट जोड़ा गया';

  @override
  String get report => 'समस्या बताएं';

  @override
  String get reportReasonHint =>
      'क्या गलत है? (स्थायी रूप से बंद, गलत लोकेशन, स्पैम...)';

  @override
  String get reportSent => 'धन्यवाद, हम जाँच करेंगे।';

  @override
  String get addLangar => 'लंगर जोड़ें';

  @override
  String get langarName => 'लंगर / गुरुद्वारे का नाम';

  @override
  String get description => 'विवरण (वैकल्पिक)';

  @override
  String get address => 'पता';

  @override
  String get city => 'शहर';

  @override
  String get state => 'राज्य';

  @override
  String get contactPhone => 'संपर्क फ़ोन (वैकल्पिक)';

  @override
  String get donateUpiOptional => 'दान के लिए UPI ID (वैकल्पिक)';

  @override
  String get donateUrlOptional => 'दान की वेबसाइट (वैकल्पिक)';

  @override
  String get pickLocation => 'मैप पर लोकेशन चुनें';

  @override
  String get tapMapToPick => 'पिन लगाने के लिए मैप पर टैप करें';

  @override
  String get locationPicked => 'लोकेशन सेट हो गई';

  @override
  String get photos => 'फ़ोटो';

  @override
  String get addPhotos => 'फ़ोटो जोड़ें';

  @override
  String get submit => 'समीक्षा के लिए भेजें';

  @override
  String get submittedTitle => 'भेज दिया गया!';

  @override
  String get submittedInfo =>
      'धन्यवाद। हमारी टीम इस लंगर की जाँच करेगी और मंज़ूरी के बाद यह मैप पर दिखेगा।';

  @override
  String get required => 'आवश्यक';

  @override
  String get loginRequired => 'आगे बढ़ने के लिए साइन इन करें';

  @override
  String get login => 'साइन इन';

  @override
  String get loginSubtitle =>
      'लंगर जोड़ने, सेवा में जुड़ने और पसंदीदा सेव करने के लिए साइन इन करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get phoneHint => '+91 98765 43210';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String otpSent(String phone) {
    return '$phone पर OTP भेजा गया';
  }

  @override
  String get enterOtp => '6 अंकों का कोड डालें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get invalidPhone => 'देश कोड के साथ सही फ़ोन नंबर डालें';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get continueWithApple => 'Apple से जारी रखें';

  @override
  String get or => 'या';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get language => 'भाषा';

  @override
  String get mySubmissions => 'मेरे जोड़े लंगर';

  @override
  String get mySeva => 'मेरी सेवा';

  @override
  String get favourites => 'पसंदीदा';

  @override
  String get admin => 'एडमिन';

  @override
  String get pendingApprovals => 'मंज़ूरी बाकी';

  @override
  String get noPending => 'समीक्षा के लिए कुछ नहीं';

  @override
  String get approve => 'मंज़ूर करें';

  @override
  String get reject => 'अस्वीकार करें';

  @override
  String get rejectReason => 'अस्वीकार करने का कारण';

  @override
  String get statusApproved => 'मंज़ूर';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusPending => 'समीक्षा में';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get terms => 'उपयोग की शर्तें';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountConfirm =>
      'इससे आपका खाता, सेवा साइनअप और पसंदीदा हमेशा के लिए हट जाएंगे। आपके जोड़े लंगर मैप पर रहेंगे। जारी रखें?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get save => 'सेव करें';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया फिर कोशिश करें।';

  @override
  String get offline => 'आप ऑफ़लाइन हैं। जो है वही दिखा रहे हैं।';

  @override
  String get notConfigured => 'ऐप कॉन्फ़िगर नहीं है';

  @override
  String get notConfiguredHint =>
      '--dart-define SUPABASE_URL और SUPABASE_ANON_KEY के साथ बिल्ड करें। README देखें।';

  @override
  String get applyToAllDays => 'सभी दिनों पर लागू करें';

  @override
  String get closedToday => 'बंद';

  @override
  String get from => 'से';

  @override
  String get to => 'तक';

  @override
  String get favouriteAdded => 'पसंदीदा में सेव किया';

  @override
  String get favouriteRemoved => 'पसंदीदा से हटाया';

  @override
  String get noFavourites => 'अभी कोई पसंदीदा नहीं। किसी लंगर पर दिल टैप करें।';

  @override
  String get noSubmissions => 'आपने अभी कोई लंगर नहीं जोड़ा।';

  @override
  String get noSeva => 'आप अभी किसी सेवा में नहीं जुड़े।';

  @override
  String shareText(String name, String url) {
    return '$name में मुफ़्त लंगर मिलता है। लंगर सेवा पर देखें: $url';
  }

  @override
  String get guest => 'अतिथि';

  @override
  String get viewList => 'सूची';

  @override
  String get viewMap => 'मैप';

  @override
  String get searchingCity => 'खोज रहे हैं...';

  @override
  String get cityNotFound => 'यह जगह नहीं मिली';

  @override
  String get nearby => 'पास में';

  @override
  String get distanceLabel => 'दूरी';

  @override
  String get weekday1 => 'सोम';

  @override
  String get weekday2 => 'मंगल';

  @override
  String get weekday3 => 'बुध';

  @override
  String get weekday4 => 'गुरु';

  @override
  String get weekday5 => 'शुक्र';

  @override
  String get weekday6 => 'शनि';

  @override
  String get weekday7 => 'रवि';

  @override
  String get submittedBy => 'समुदाय द्वारा जोड़ा गया';

  @override
  String get editTimings => 'समय सेट करें';

  @override
  String get done => 'हो गया';

  @override
  String get manageSeva => 'सेवा स्लॉट प्रबंधित करें';

  @override
  String get accountDeleted => 'आपका खाता हटा दिया गया है।';
}
