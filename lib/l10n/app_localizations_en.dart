// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LangarSeva';

  @override
  String get nearYou => 'Langars near you';

  @override
  String get searchCityHint => 'Search a city or area';

  @override
  String get openNow => 'Open now';

  @override
  String get within5km => 'Within 5 km';

  @override
  String get within25km => 'Within 25 km';

  @override
  String get within100km => 'Within 100 km';

  @override
  String get noLangarsFound => 'No langars found here yet. Know one? Add it!';

  @override
  String get locationPermissionDenied =>
      'Location is off. Showing results for Delhi. Search a city or enable location.';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String mAway(int m) {
    return '$m m away';
  }

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get open24h => 'Open 24 hours';

  @override
  String get timings => 'Timings';

  @override
  String get today => 'Today';

  @override
  String get noTimings => 'Timings not added yet';

  @override
  String get directions => 'Directions';

  @override
  String get call => 'Call';

  @override
  String get share => 'Share';

  @override
  String get donate => 'Donate';

  @override
  String get donateTitle => 'Support this langar';

  @override
  String get donateUpiId => 'UPI ID';

  @override
  String get copyUpi => 'Copy UPI ID';

  @override
  String get copied => 'Copied';

  @override
  String get openUpiApp => 'Pay with UPI app';

  @override
  String get noUpiApp => 'No UPI app found. Copy the UPI ID instead.';

  @override
  String get donateWebsite => 'Donate on website';

  @override
  String get noDonateInfo =>
      'This langar has not shared donation details. Visit in person to offer seva or dasvandh.';

  @override
  String get sevaTitle => 'Seva (volunteer)';

  @override
  String get sevaJoin => 'Join';

  @override
  String get sevaLeave => 'Leave';

  @override
  String get sevaJoined => 'You\'re in! Thank you for your seva.';

  @override
  String get sevaFull => 'Full';

  @override
  String get sevaNoSlots =>
      'No upcoming seva slots. Langar organisers can add slots.';

  @override
  String sevaSpots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
      zero: 'No spots left',
    );
    return '$_temp0';
  }

  @override
  String volunteersJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volunteers',
      one: '1 volunteer',
      zero: 'No volunteers yet',
    );
    return '$_temp0';
  }

  @override
  String get sevaCreateSlot => 'Add seva slot';

  @override
  String get slotTitle => 'What seva is needed? (e.g. Roti making)';

  @override
  String get startsAt => 'Starts';

  @override
  String get endsAt => 'Ends';

  @override
  String get capacity => 'Volunteers needed';

  @override
  String get createdSlot => 'Seva slot added';

  @override
  String get report => 'Report a problem';

  @override
  String get reportReasonHint =>
      'What\'s wrong? (closed permanently, wrong location, spam...)';

  @override
  String get reportSent => 'Thanks, we\'ll review it.';

  @override
  String get addLangar => 'Add a langar';

  @override
  String get langarName => 'Langar / Gurudwara name';

  @override
  String get description => 'Description (optional)';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get contactPhone => 'Contact phone (optional)';

  @override
  String get donateUpiOptional => 'Donation UPI ID (optional)';

  @override
  String get donateUrlOptional => 'Donation website (optional)';

  @override
  String get pickLocation => 'Pick location on map';

  @override
  String get tapMapToPick => 'Tap on the map to place the pin';

  @override
  String get locationPicked => 'Location set';

  @override
  String get photos => 'Photos';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get submit => 'Submit for review';

  @override
  String get submittedTitle => 'Submitted!';

  @override
  String get submittedInfo =>
      'Thank you. Our team will review this langar and it will appear on the map once approved.';

  @override
  String get required => 'Required';

  @override
  String get loginRequired => 'Please sign in to continue';

  @override
  String get login => 'Sign in';

  @override
  String get loginSubtitle =>
      'Sign in to add langars, join seva and save favourites';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '+91 98765 43210';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String otpSent(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String get enterOtp => 'Enter the 6-digit code';

  @override
  String get verify => 'Verify';

  @override
  String get invalidPhone => 'Enter a valid phone number with country code';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get or => 'or';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get mySubmissions => 'My submissions';

  @override
  String get mySeva => 'My seva';

  @override
  String get favourites => 'Favourites';

  @override
  String get admin => 'Admin';

  @override
  String get pendingApprovals => 'Pending approvals';

  @override
  String get noPending => 'Nothing to review';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReason => 'Reason for rejection';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPending => 'Under review';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get terms => 'Terms of use';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This permanently deletes your account, seva signups and favourites. Langars you added stay on the map. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get offline => 'You\'re offline. Showing what we have.';

  @override
  String get notConfigured => 'App not configured';

  @override
  String get notConfiguredHint =>
      'Build with --dart-define SUPABASE_URL and SUPABASE_ANON_KEY. See README.';

  @override
  String get applyToAllDays => 'Apply to all days';

  @override
  String get closedToday => 'Closed';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get favouriteAdded => 'Saved to favourites';

  @override
  String get favouriteRemoved => 'Removed from favourites';

  @override
  String get noFavourites => 'No favourites yet. Tap the heart on any langar.';

  @override
  String get noSubmissions => 'You haven\'t added any langars yet.';

  @override
  String get noSeva => 'You haven\'t joined any seva yet.';

  @override
  String shareText(String name, String url) {
    return '$name serves free langar. Find it on LangarSeva: $url';
  }

  @override
  String get guest => 'Guest';

  @override
  String get viewList => 'List';

  @override
  String get viewMap => 'Map';

  @override
  String get searchingCity => 'Searching...';

  @override
  String get cityNotFound => 'Couldn\'t find that place';

  @override
  String get nearby => 'Nearby';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get weekday1 => 'Mon';

  @override
  String get weekday2 => 'Tue';

  @override
  String get weekday3 => 'Wed';

  @override
  String get weekday4 => 'Thu';

  @override
  String get weekday5 => 'Fri';

  @override
  String get weekday6 => 'Sat';

  @override
  String get weekday7 => 'Sun';

  @override
  String get submittedBy => 'Added by community';

  @override
  String get editTimings => 'Set timings';

  @override
  String get done => 'Done';

  @override
  String get manageSeva => 'Manage seva slots';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get locationServiceOff =>
      'Location services are turned off. Showing results for Delhi.';

  @override
  String get locationTimeout =>
      'Couldn\'t get your location. Showing results for Delhi.';
}
