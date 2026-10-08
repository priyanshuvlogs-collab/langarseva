import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('pa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LangarSeva'**
  String get appTitle;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Langars near you'**
  String get nearYou;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Search a city or area'**
  String get searchCityHint;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @within5km.
  ///
  /// In en, this message translates to:
  /// **'Within 5 km'**
  String get within5km;

  /// No description provided for @within25km.
  ///
  /// In en, this message translates to:
  /// **'Within 25 km'**
  String get within25km;

  /// No description provided for @within100km.
  ///
  /// In en, this message translates to:
  /// **'Within 100 km'**
  String get within100km;

  /// No description provided for @noLangarsFound.
  ///
  /// In en, this message translates to:
  /// **'No langars found here yet. Know one? Add it!'**
  String get noLangarsFound;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location is off. Showing results for Delhi. Search a city or enable location.'**
  String get locationPermissionDenied;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @mAway.
  ///
  /// In en, this message translates to:
  /// **'{m} m away'**
  String mAway(int m);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open24h.
  ///
  /// In en, this message translates to:
  /// **'Open 24 hours'**
  String get open24h;

  /// No description provided for @timings.
  ///
  /// In en, this message translates to:
  /// **'Timings'**
  String get timings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noTimings.
  ///
  /// In en, this message translates to:
  /// **'Timings not added yet'**
  String get noTimings;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donateTitle.
  ///
  /// In en, this message translates to:
  /// **'Support this langar'**
  String get donateTitle;

  /// No description provided for @donateUpiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get donateUpiId;

  /// No description provided for @copyUpi.
  ///
  /// In en, this message translates to:
  /// **'Copy UPI ID'**
  String get copyUpi;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @openUpiApp.
  ///
  /// In en, this message translates to:
  /// **'Pay with UPI app'**
  String get openUpiApp;

  /// No description provided for @noUpiApp.
  ///
  /// In en, this message translates to:
  /// **'No UPI app found. Copy the UPI ID instead.'**
  String get noUpiApp;

  /// No description provided for @donateWebsite.
  ///
  /// In en, this message translates to:
  /// **'Donate on website'**
  String get donateWebsite;

  /// No description provided for @noDonateInfo.
  ///
  /// In en, this message translates to:
  /// **'This langar has not shared donation details. Visit in person to offer seva or dasvandh.'**
  String get noDonateInfo;

  /// No description provided for @sevaTitle.
  ///
  /// In en, this message translates to:
  /// **'Seva (volunteer)'**
  String get sevaTitle;

  /// No description provided for @sevaJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get sevaJoin;

  /// No description provided for @sevaLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sevaLeave;

  /// No description provided for @sevaJoined.
  ///
  /// In en, this message translates to:
  /// **'You\'re in! Thank you for your seva.'**
  String get sevaJoined;

  /// No description provided for @sevaFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get sevaFull;

  /// No description provided for @sevaNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No upcoming seva slots. Langar organisers can add slots.'**
  String get sevaNoSlots;

  /// No description provided for @sevaSpots.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No spots left} =1{1 spot left} other{{count} spots left}}'**
  String sevaSpots(int count);

  /// No description provided for @volunteersJoined.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No volunteers yet} =1{1 volunteer} other{{count} volunteers}}'**
  String volunteersJoined(int count);

  /// No description provided for @sevaCreateSlot.
  ///
  /// In en, this message translates to:
  /// **'Add seva slot'**
  String get sevaCreateSlot;

  /// No description provided for @slotTitle.
  ///
  /// In en, this message translates to:
  /// **'What seva is needed? (e.g. Roti making)'**
  String get slotTitle;

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsAt;

  /// No description provided for @endsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsAt;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Volunteers needed'**
  String get capacity;

  /// No description provided for @createdSlot.
  ///
  /// In en, this message translates to:
  /// **'Seva slot added'**
  String get createdSlot;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get report;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong? (closed permanently, wrong location, spam...)'**
  String get reportReasonHint;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we\'ll review it.'**
  String get reportSent;

  /// No description provided for @addLangar.
  ///
  /// In en, this message translates to:
  /// **'Add a langar'**
  String get addLangar;

  /// No description provided for @langarName.
  ///
  /// In en, this message translates to:
  /// **'Langar / Gurudwara name'**
  String get langarName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get description;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone (optional)'**
  String get contactPhone;

  /// No description provided for @donateUpiOptional.
  ///
  /// In en, this message translates to:
  /// **'Donation UPI ID (optional)'**
  String get donateUpiOptional;

  /// No description provided for @donateUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Donation website (optional)'**
  String get donateUrlOptional;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick location on map'**
  String get pickLocation;

  /// No description provided for @tapMapToPick.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to place the pin'**
  String get tapMapToPick;

  /// No description provided for @locationPicked.
  ///
  /// In en, this message translates to:
  /// **'Location set'**
  String get locationPicked;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submit;

  /// No description provided for @submittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted!'**
  String get submittedTitle;

  /// No description provided for @submittedInfo.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our team will review this langar and it will appear on the map once approved.'**
  String get submittedInfo;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get loginRequired;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to add langars, join seva and save favourites'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String otpSent(String phone);

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterOtp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number with country code'**
  String get invalidPhone;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @mySubmissions.
  ///
  /// In en, this message translates to:
  /// **'My submissions'**
  String get mySubmissions;

  /// No description provided for @mySeva.
  ///
  /// In en, this message translates to:
  /// **'My seva'**
  String get mySeva;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get pendingApprovals;

  /// No description provided for @noPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get noPending;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get rejectReason;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusPending;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, seva signups and favourites. Langars you added stay on the map. Continue?'**
  String get deleteAccountConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing what we have.'**
  String get offline;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'App not configured'**
  String get notConfigured;

  /// No description provided for @notConfiguredHint.
  ///
  /// In en, this message translates to:
  /// **'Build with --dart-define SUPABASE_URL and SUPABASE_ANON_KEY. See README.'**
  String get notConfiguredHint;

  /// No description provided for @applyToAllDays.
  ///
  /// In en, this message translates to:
  /// **'Apply to all days'**
  String get applyToAllDays;

  /// No description provided for @closedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedToday;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @favouriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Saved to favourites'**
  String get favouriteAdded;

  /// No description provided for @favouriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get favouriteRemoved;

  /// No description provided for @noFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet. Tap the heart on any langar.'**
  String get noFavourites;

  /// No description provided for @noSubmissions.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any langars yet.'**
  String get noSubmissions;

  /// No description provided for @noSeva.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined any seva yet.'**
  String get noSeva;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'{name} serves free langar. Find it on LangarSeva: {url}'**
  String shareText(String name, String url);

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get viewMap;

  /// No description provided for @searchingCity.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchingCity;

  /// No description provided for @cityNotFound.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find that place'**
  String get cityNotFound;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @weekday1.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekday7;

  /// No description provided for @submittedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by community'**
  String get submittedBy;

  /// No description provided for @editTimings.
  ///
  /// In en, this message translates to:
  /// **'Set timings'**
  String get editTimings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @manageSeva.
  ///
  /// In en, this message translates to:
  /// **'Manage seva slots'**
  String get manageSeva;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Showing results for Delhi.'**
  String get locationServiceOff;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Showing results for Delhi.'**
  String get locationTimeout;

  /// No description provided for @sevaSlotFullMsg.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this seva slot just filled up.'**
  String get sevaSlotFullMsg;

  /// No description provided for @sevaSlotEndedMsg.
  ///
  /// In en, this message translates to:
  /// **'This seva slot has already ended.'**
  String get sevaSlotEndedMsg;

  /// No description provided for @invalidUpi.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid UPI ID, like name@bank'**
  String get invalidUpi;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a full link starting with https://'**
  String get invalidUrl;

  /// No description provided for @invalidPhoto.
  ///
  /// In en, this message translates to:
  /// **'A photo could not be attached. Please pick it again.'**
  String get invalidPhoto;
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
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

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
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
