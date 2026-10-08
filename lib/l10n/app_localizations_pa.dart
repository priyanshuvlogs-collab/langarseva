// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'ਲੰਗਰ ਸੇਵਾ';

  @override
  String get nearYou => 'ਤੁਹਾਡੇ ਨੇੜੇ ਦੇ ਲੰਗਰ';

  @override
  String get searchCityHint => 'ਸ਼ਹਿਰ ਜਾਂ ਇਲਾਕਾ ਖੋਜੋ';

  @override
  String get openNow => 'ਹੁਣ ਖੁੱਲ੍ਹਾ';

  @override
  String get within5km => '5 ਕਿਮੀ ਅੰਦਰ';

  @override
  String get within25km => '25 ਕਿਮੀ ਅੰਦਰ';

  @override
  String get within100km => '100 ਕਿਮੀ ਅੰਦਰ';

  @override
  String get noLangarsFound =>
      'ਇੱਥੇ ਹਾਲੇ ਕੋਈ ਲੰਗਰ ਨਹੀਂ ਮਿਲਿਆ। ਕੋਈ ਜਾਣਦੇ ਹੋ? ਜੋੜੋ!';

  @override
  String get locationPermissionDenied =>
      'ਲੋਕੇਸ਼ਨ ਬੰਦ ਹੈ। ਦਿੱਲੀ ਦੇ ਨਤੀਜੇ ਦਿਖਾ ਰਹੇ ਹਾਂ। ਸ਼ਹਿਰ ਖੋਜੋ ਜਾਂ ਲੋਕੇਸ਼ਨ ਚਾਲੂ ਕਰੋ।';

  @override
  String get enableLocation => 'ਲੋਕੇਸ਼ਨ ਚਾਲੂ ਕਰੋ';

  @override
  String get useMyLocation => 'ਮੇਰੀ ਲੋਕੇਸ਼ਨ ਵਰਤੋ';

  @override
  String kmAway(String km) {
    return '$km ਕਿਮੀ ਦੂਰ';
  }

  @override
  String mAway(int m) {
    return '$m ਮੀਟਰ ਦੂਰ';
  }

  @override
  String get open => 'ਖੁੱਲ੍ਹਾ';

  @override
  String get closed => 'ਬੰਦ';

  @override
  String get open24h => '24 ਘੰਟੇ ਖੁੱਲ੍ਹਾ';

  @override
  String get timings => 'ਸਮਾਂ';

  @override
  String get today => 'ਅੱਜ';

  @override
  String get noTimings => 'ਸਮਾਂ ਹਾਲੇ ਨਹੀਂ ਜੋੜਿਆ';

  @override
  String get directions => 'ਰਾਹ';

  @override
  String get call => 'ਕਾਲ';

  @override
  String get share => 'ਸਾਂਝਾ ਕਰੋ';

  @override
  String get donate => 'ਦਾਨ ਕਰੋ';

  @override
  String get donateTitle => 'ਇਸ ਲੰਗਰ ਦਾ ਸਹਿਯੋਗ ਕਰੋ';

  @override
  String get donateUpiId => 'UPI ID';

  @override
  String get copyUpi => 'UPI ID ਕਾਪੀ ਕਰੋ';

  @override
  String get copied => 'ਕਾਪੀ ਹੋ ਗਿਆ';

  @override
  String get openUpiApp => 'UPI ਐਪ ਨਾਲ ਭੁਗਤਾਨ';

  @override
  String get noUpiApp => 'ਕੋਈ UPI ਐਪ ਨਹੀਂ ਮਿਲੀ। UPI ID ਕਾਪੀ ਕਰੋ।';

  @override
  String get donateWebsite => 'ਵੈੱਬਸਾਈਟ \'ਤੇ ਦਾਨ ਕਰੋ';

  @override
  String get noDonateInfo =>
      'ਇਸ ਲੰਗਰ ਨੇ ਦਾਨ ਦੀ ਜਾਣਕਾਰੀ ਨਹੀਂ ਦਿੱਤੀ। ਸੇਵਾ ਜਾਂ ਦਸਵੰਧ ਲਈ ਸਿੱਧੇ ਪਹੁੰਚੋ।';

  @override
  String get sevaTitle => 'ਸੇਵਾ';

  @override
  String get sevaJoin => 'ਜੁੜੋ';

  @override
  String get sevaLeave => 'ਛੱਡੋ';

  @override
  String get sevaJoined => 'ਤੁਸੀਂ ਜੁੜ ਗਏ! ਤੁਹਾਡੀ ਸੇਵਾ ਲਈ ਧੰਨਵਾਦ।';

  @override
  String get sevaFull => 'ਭਰ ਗਿਆ';

  @override
  String get sevaNoSlots =>
      'ਕੋਈ ਆਉਣ ਵਾਲਾ ਸੇਵਾ ਸਲਾਟ ਨਹੀਂ। ਲੰਗਰ ਪ੍ਰਬੰਧਕ ਸਲਾਟ ਜੋੜ ਸਕਦੇ ਹਨ।';

  @override
  String sevaSpots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਜਗ੍ਹਾਂ ਬਚੀਆਂ',
      one: '1 ਜਗ੍ਹਾ ਬਚੀ',
      zero: 'ਕੋਈ ਜਗ੍ਹਾ ਨਹੀਂ ਬਚੀ',
    );
    return '$_temp0';
  }

  @override
  String volunteersJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਸੇਵਾਦਾਰ',
      one: '1 ਸੇਵਾਦਾਰ',
      zero: 'ਹਾਲੇ ਕੋਈ ਸੇਵਾਦਾਰ ਨਹੀਂ',
    );
    return '$_temp0';
  }

  @override
  String get sevaCreateSlot => 'ਸੇਵਾ ਸਲਾਟ ਜੋੜੋ';

  @override
  String get slotTitle => 'ਕਿਹੜੀ ਸੇਵਾ ਚਾਹੀਦੀ ਹੈ? (ਜਿਵੇਂ ਰੋਟੀ ਬਣਾਉਣਾ)';

  @override
  String get startsAt => 'ਸ਼ੁਰੂ';

  @override
  String get endsAt => 'ਸਮਾਪਤ';

  @override
  String get capacity => 'ਕਿੰਨੇ ਸੇਵਾਦਾਰ ਚਾਹੀਦੇ';

  @override
  String get createdSlot => 'ਸੇਵਾ ਸਲਾਟ ਜੋੜਿਆ ਗਿਆ';

  @override
  String get report => 'ਸਮੱਸਿਆ ਦੱਸੋ';

  @override
  String get reportReasonHint =>
      'ਕੀ ਗਲਤ ਹੈ? (ਪੱਕੇ ਤੌਰ \'ਤੇ ਬੰਦ, ਗਲਤ ਲੋਕੇਸ਼ਨ, ਸਪੈਮ...)';

  @override
  String get reportSent => 'ਧੰਨਵਾਦ, ਅਸੀਂ ਜਾਂਚ ਕਰਾਂਗੇ।';

  @override
  String get addLangar => 'ਲੰਗਰ ਜੋੜੋ';

  @override
  String get langarName => 'ਲੰਗਰ / ਗੁਰਦੁਆਰੇ ਦਾ ਨਾਮ';

  @override
  String get description => 'ਵੇਰਵਾ (ਵਿਕਲਪਿਕ)';

  @override
  String get address => 'ਪਤਾ';

  @override
  String get city => 'ਸ਼ਹਿਰ';

  @override
  String get state => 'ਰਾਜ';

  @override
  String get contactPhone => 'ਸੰਪਰਕ ਫ਼ੋਨ (ਵਿਕਲਪਿਕ)';

  @override
  String get donateUpiOptional => 'ਦਾਨ ਲਈ UPI ID (ਵਿਕਲਪਿਕ)';

  @override
  String get donateUrlOptional => 'ਦਾਨ ਦੀ ਵੈੱਬਸਾਈਟ (ਵਿਕਲਪਿਕ)';

  @override
  String get pickLocation => 'ਨਕਸ਼ੇ \'ਤੇ ਲੋਕੇਸ਼ਨ ਚੁਣੋ';

  @override
  String get tapMapToPick => 'ਪਿੰਨ ਲਗਾਉਣ ਲਈ ਨਕਸ਼ੇ \'ਤੇ ਟੈਪ ਕਰੋ';

  @override
  String get locationPicked => 'ਲੋਕੇਸ਼ਨ ਸੈੱਟ ਹੋ ਗਈ';

  @override
  String get photos => 'ਫੋਟੋਆਂ';

  @override
  String get addPhotos => 'ਫੋਟੋਆਂ ਜੋੜੋ';

  @override
  String get submit => 'ਸਮੀਖਿਆ ਲਈ ਭੇਜੋ';

  @override
  String get submittedTitle => 'ਭੇਜ ਦਿੱਤਾ ਗਿਆ!';

  @override
  String get submittedInfo =>
      'ਧੰਨਵਾਦ। ਸਾਡੀ ਟੀਮ ਇਸ ਲੰਗਰ ਦੀ ਜਾਂਚ ਕਰੇਗੀ ਅਤੇ ਮਨਜ਼ੂਰੀ ਤੋਂ ਬਾਅਦ ਇਹ ਨਕਸ਼ੇ \'ਤੇ ਦਿਖੇਗਾ।';

  @override
  String get required => 'ਲੋੜੀਂਦਾ';

  @override
  String get loginRequired => 'ਅੱਗੇ ਵਧਣ ਲਈ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get login => 'ਸਾਈਨ ਇਨ';

  @override
  String get loginSubtitle =>
      'ਲੰਗਰ ਜੋੜਨ, ਸੇਵਾ ਵਿੱਚ ਜੁੜਨ ਅਤੇ ਪਸੰਦੀਦਾ ਸੇਵ ਕਰਨ ਲਈ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get phoneNumber => 'ਫ਼ੋਨ ਨੰਬਰ';

  @override
  String get phoneHint => '+91 98765 43210';

  @override
  String get sendOtp => 'OTP ਭੇਜੋ';

  @override
  String otpSent(String phone) {
    return '$phone \'ਤੇ OTP ਭੇਜਿਆ ਗਿਆ';
  }

  @override
  String get enterOtp => '6 ਅੰਕਾਂ ਦਾ ਕੋਡ ਭਰੋ';

  @override
  String get verify => 'ਤਸਦੀਕ ਕਰੋ';

  @override
  String get invalidPhone => 'ਦੇਸ਼ ਕੋਡ ਨਾਲ ਸਹੀ ਫ਼ੋਨ ਨੰਬਰ ਭਰੋ';

  @override
  String get continueWithGoogle => 'Google ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get continueWithApple => 'Apple ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get or => 'ਜਾਂ';

  @override
  String get profile => 'ਪ੍ਰੋਫ਼ਾਈਲ';

  @override
  String get language => 'ਭਾਸ਼ਾ';

  @override
  String get mySubmissions => 'ਮੇਰੇ ਜੋੜੇ ਲੰਗਰ';

  @override
  String get mySeva => 'ਮੇਰੀ ਸੇਵਾ';

  @override
  String get favourites => 'ਪਸੰਦੀਦਾ';

  @override
  String get admin => 'ਐਡਮਿਨ';

  @override
  String get pendingApprovals => 'ਮਨਜ਼ੂਰੀ ਬਾਕੀ';

  @override
  String get noPending => 'ਸਮੀਖਿਆ ਲਈ ਕੁਝ ਨਹੀਂ';

  @override
  String get approve => 'ਮਨਜ਼ੂਰ ਕਰੋ';

  @override
  String get reject => 'ਰੱਦ ਕਰੋ';

  @override
  String get rejectReason => 'ਰੱਦ ਕਰਨ ਦਾ ਕਾਰਨ';

  @override
  String get statusApproved => 'ਮਨਜ਼ੂਰ';

  @override
  String get statusRejected => 'ਰੱਦ';

  @override
  String get statusPending => 'ਸਮੀਖਿਆ ਵਿੱਚ';

  @override
  String get privacyPolicy => 'ਪਰਦੇਦਾਰੀ ਨੀਤੀ';

  @override
  String get terms => 'ਵਰਤੋਂ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String get signOut => 'ਸਾਈਨ ਆਉਟ';

  @override
  String get deleteAccount => 'ਖਾਤਾ ਮਿਟਾਓ';

  @override
  String get deleteAccountConfirm =>
      'ਇਸ ਨਾਲ ਤੁਹਾਡਾ ਖਾਤਾ, ਸੇਵਾ ਸਾਈਨਅਪ ਅਤੇ ਪਸੰਦੀਦਾ ਪੱਕੇ ਤੌਰ \'ਤੇ ਮਿਟ ਜਾਣਗੇ। ਤੁਹਾਡੇ ਜੋੜੇ ਲੰਗਰ ਨਕਸ਼ੇ \'ਤੇ ਰਹਿਣਗੇ। ਜਾਰੀ ਰੱਖੋ?';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get delete => 'ਮਿਟਾਓ';

  @override
  String get save => 'ਸੇਵ ਕਰੋ';

  @override
  String get retry => 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get errorGeneric => 'ਕੁਝ ਗਲਤ ਹੋ ਗਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get offline => 'ਤੁਸੀਂ ਆਫ਼ਲਾਈਨ ਹੋ। ਜੋ ਹੈ ਉਹੀ ਦਿਖਾ ਰਹੇ ਹਾਂ।';

  @override
  String get notConfigured => 'ਐਪ ਕੌਂਫਿਗਰ ਨਹੀਂ ਹੈ';

  @override
  String get notConfiguredHint =>
      '--dart-define SUPABASE_URL ਅਤੇ SUPABASE_ANON_KEY ਨਾਲ ਬਿਲਡ ਕਰੋ। README ਦੇਖੋ।';

  @override
  String get applyToAllDays => 'ਸਾਰੇ ਦਿਨਾਂ \'ਤੇ ਲਾਗੂ ਕਰੋ';

  @override
  String get closedToday => 'ਬੰਦ';

  @override
  String get from => 'ਤੋਂ';

  @override
  String get to => 'ਤੱਕ';

  @override
  String get favouriteAdded => 'ਪਸੰਦੀਦਾ ਵਿੱਚ ਸੇਵ ਕੀਤਾ';

  @override
  String get favouriteRemoved => 'ਪਸੰਦੀਦਾ ਤੋਂ ਹਟਾਇਆ';

  @override
  String get noFavourites =>
      'ਹਾਲੇ ਕੋਈ ਪਸੰਦੀਦਾ ਨਹੀਂ। ਕਿਸੇ ਲੰਗਰ \'ਤੇ ਦਿਲ ਟੈਪ ਕਰੋ।';

  @override
  String get noSubmissions => 'ਤੁਸੀਂ ਹਾਲੇ ਕੋਈ ਲੰਗਰ ਨਹੀਂ ਜੋੜਿਆ।';

  @override
  String get noSeva => 'ਤੁਸੀਂ ਹਾਲੇ ਕਿਸੇ ਸੇਵਾ ਵਿੱਚ ਨਹੀਂ ਜੁੜੇ।';

  @override
  String shareText(String name, String url) {
    return '$name ਵਿੱਚ ਮੁਫ਼ਤ ਲੰਗਰ ਮਿਲਦਾ ਹੈ। ਲੰਗਰ ਸੇਵਾ \'ਤੇ ਦੇਖੋ: $url';
  }

  @override
  String get guest => 'ਮਹਿਮਾਨ';

  @override
  String get viewList => 'ਸੂਚੀ';

  @override
  String get viewMap => 'ਨਕਸ਼ਾ';

  @override
  String get searchingCity => 'ਖੋਜ ਰਹੇ ਹਾਂ...';

  @override
  String get cityNotFound => 'ਇਹ ਜਗ੍ਹਾ ਨਹੀਂ ਮਿਲੀ';

  @override
  String get nearby => 'ਨੇੜੇ';

  @override
  String get distanceLabel => 'ਦੂਰੀ';

  @override
  String get weekday1 => 'ਸੋਮ';

  @override
  String get weekday2 => 'ਮੰਗਲ';

  @override
  String get weekday3 => 'ਬੁੱਧ';

  @override
  String get weekday4 => 'ਵੀਰ';

  @override
  String get weekday5 => 'ਸ਼ੁੱਕਰ';

  @override
  String get weekday6 => 'ਸ਼ਨੀ';

  @override
  String get weekday7 => 'ਐਤ';

  @override
  String get submittedBy => 'ਸੰਗਤ ਵੱਲੋਂ ਜੋੜਿਆ';

  @override
  String get editTimings => 'ਸਮਾਂ ਸੈੱਟ ਕਰੋ';

  @override
  String get done => 'ਹੋ ਗਿਆ';

  @override
  String get manageSeva => 'ਸੇਵਾ ਸਲਾਟ ਪ੍ਰਬੰਧਿਤ ਕਰੋ';

  @override
  String get accountDeleted => 'ਤੁਹਾਡਾ ਖਾਤਾ ਮਿਟਾ ਦਿੱਤਾ ਗਿਆ ਹੈ।';

  @override
  String get locationServiceOff =>
      'ਲੋਕੇਸ਼ਨ ਸਰਵਿਸ ਬੰਦ ਹੈ। ਦਿੱਲੀ ਦੇ ਨਤੀਜੇ ਦਿਖਾ ਰਹੇ ਹਾਂ।';

  @override
  String get locationTimeout =>
      'ਤੁਹਾਡੀ ਲੋਕੇਸ਼ਨ ਨਹੀਂ ਮਿਲ ਸਕੀ। ਦਿੱਲੀ ਦੇ ਨਤੀਜੇ ਦਿਖਾ ਰਹੇ ਹਾਂ।';
}
