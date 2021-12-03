import 'languages.dart';

class LanguageEn extends Languages {
  @override
  String get footyBusiness => "Footy Business";
  @override
  String get labelSelectLanguage => "English";
  @override
  String get loginScreen1head => "Online bookings";
  @override
  String get loginScreen1text =>
      "Make bookings online without problems. No more need to contact administrators and have time-consuming talks";
  @override
  String get loginScreen2head => "2 minutes";
  @override
  String get loginScreen2text =>
      "You will need only 2 minutes to make booking anywhere";
  @override
  String get loginScreen3head => "Timetable";
  @override
  String get loginScreen3text =>
      "Convenient timetable that organizes your bookings and regulates them";
  @override
  String get getStarted => "Get started";
  @override
  String get loginScreenYourPhone => "Your Phone";
  @override
  String get loginScreen6Digits => "Code should contain 6 digits";
  @override
  String get loginScreenEnterCode => "Enter code";
  @override
  String get loginScreenReenterPhone => "Re-enter the phone";
  @override
  String get loginScreenPolicy =>
      "By continuing, you accept all terms of use of the app and the Privacy Policy";
  @override
  String get loginScreenCodeIsNotValid => "Code is not valid anymore";

  @override
  String get instructions => "Instructions";
  @override
  String get instText1 =>
      'Congratulations on becoming part of Footy family. Here we have some instructions. First you have to do is to create a company. Every company has its own balance in Footy system. As an example we can take "Bowling club" company. You can see your companies in profile.\n\nEvery company has different offices at different locations. Later you can add them. Examples: "Bowling club Tashkent" , "Bowling club Moscow". \n\nAt different offices you can offer different services. There can be several services at one location. Example: "1-hour game" service at "Bowling club Tashkent".';
  @override
  String get instText2 =>
      'When clients will order one of your services, you will be notified and given an offer. You should either accept or reject this offer at least 3 hours before the start of the order. After deadline order will be cancelled. You can tap on the card to get more info.';
  @override
  String get instText3 => "Balance of your company can be regulated at profile screen. Whenever you want you can top up balance. However when your balance goes below -100 000 UZS, your company will be deactivated and you will not be able to receive orders unless you pay your debt.";
  @override
  String get instText4 => "Once you accepted an offer, you can regulate it by tapping on the card of the order. When time of order comes, you can start the order. When it finishes, you get payment from client. Once payment is done, you can end the order. There 3 statuses for orders. \n- Unfinished - order that has not yet been started. \n- In process - order that is happening right now. \n- Unpaid - booking that has finished and client has not paid.";

  @override
  String get homeScreenBook => "Book";
  @override
  String get homeScreenFail => "Fail";
  @override
  String get homeScreenFailedToUpdate => "Failed to update";
  @override
  String get homeScreenSaved => "Saved";

  @override
  String get managementScreenToday => "Today";
  @override
  String get managementScreenNoBooksToday => "No bookings today";
  @override
  String get managementScreenLocations => "Locations";
  @override
  String get managementScreenNoLocations => "You have 0 locations for this company. Please add them or your company might be banned.";
  @override
  String get managementScreenCreateLocation => "Create location";


  @override
  String get searchScreenName => "Place name";

  @override
  String get historyScreenSchedule => "Schedule";
  @override
  String get historyScreenHistory => "History";
  @override
  String get historyScreenUnpaid => "Unpaid";
  @override
  String get historyScreenInProcess => "In Process";
  @override
  String get historyScreenUpcoming => "Upcoming";
  @override
  String get historyScreenUnrated => "Unrated";
  @override
  String get historyScreenCustom => "Custom";
  @override
  String get historyScreenVerificationNeeded => "Verification needed";
  @override
  String get historyScreenCreateCustomBook => "Create custom booking";
  @override
  String get historyScreenSelectService => "Select service";
  @override
  String get historyScreenAcceptOffer => "Accept an offer";
  @override
  String get historyScreenRejectOffer => "Reject an offer";

  @override
  String get profileScreenFavs => "Favourites";
  @override
  String get profileScreenNotifs => "Notifications";
  @override
  String get profileScreenSignOut => "Sign Out?";
  @override
  String get profileScreenWantToLeave => "Do you want to leave?";

  @override
  String get settingsSettings => "Settings";
  @override
  String get settingsLocalPassword => "Local password";
  @override
  String get settingsLocalPasswordTurnedOff => "Local password is turned off";
  @override
  String get settingsLocalPasswordTurnedOn => "Local password is turned on";
  @override
  String get settingsDigitPassword => "4-digit password";

  @override
  String get serviceScreenNoInternet => "No Internet";
}
