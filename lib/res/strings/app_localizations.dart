import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'strings/app_localizations.dart';
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
    Locale('th'),
    Locale('zh'),
  ];

  /// No description provided for @signUpWith.
  ///
  /// In en, this message translates to:
  /// **'Sign up with'**
  String get signUpWith;

  /// No description provided for @signUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Become a member with Browny and enjoy many exclusive privileges.'**
  String get signUpDescription;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Browny ID account'**
  String get signUpTitle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email / Phone number'**
  String get emailOrPhone;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @coin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coin;

  /// No description provided for @brownyClub.
  ///
  /// In en, this message translates to:
  /// **'Browny Club'**
  String get brownyClub;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @evouchersAndPromotions.
  ///
  /// In en, this message translates to:
  /// **'E-vouchers and Promotions'**
  String get evouchersAndPromotions;

  /// No description provided for @laundryInProgress.
  ///
  /// In en, this message translates to:
  /// **'Laundry in Progress'**
  String get laundryInProgress;

  /// No description provided for @startWashing.
  ///
  /// In en, this message translates to:
  /// **'Start Washing'**
  String get startWashing;

  /// No description provided for @startDrying.
  ///
  /// In en, this message translates to:
  /// **'Start Drying'**
  String get startDrying;

  /// No description provided for @enterDiscountCodeOrPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a discount code or promo code.'**
  String get enterDiscountCodeOrPromoCode;

  /// No description provided for @displayExpiredOrFullyRedeemedCoupons.
  ///
  /// In en, this message translates to:
  /// **'Display expired or fully redeemed coupons.'**
  String get displayExpiredOrFullyRedeemedCoupons;

  /// No description provided for @redemptionCoupons.
  ///
  /// In en, this message translates to:
  /// **'Redemption Coupons'**
  String get redemptionCoupons;

  /// No description provided for @discountCoupons.
  ///
  /// In en, this message translates to:
  /// **'Discount Coupons'**
  String get discountCoupons;

  /// No description provided for @pleaseScanQR.
  ///
  /// In en, this message translates to:
  /// **'Please scan QR code on the machines.'**
  String get pleaseScanQR;

  /// No description provided for @typeStoreName.
  ///
  /// In en, this message translates to:
  /// **'Type store name'**
  String get typeStoreName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @washerAvai.
  ///
  /// In en, this message translates to:
  /// **'Washer'**
  String get washerAvai;

  /// No description provided for @dryerAvai.
  ///
  /// In en, this message translates to:
  /// **'Dryer'**
  String get dryerAvai;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @washer.
  ///
  /// In en, this message translates to:
  /// **'Washer'**
  String get washer;

  /// No description provided for @dryer.
  ///
  /// In en, this message translates to:
  /// **'Dryer'**
  String get dryer;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get remainingTime;

  /// No description provided for @estimatedFinishTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated finish time'**
  String get estimatedFinishTime;

  /// No description provided for @thb.
  ///
  /// In en, this message translates to:
  /// **'THB'**
  String get thb;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @availableCoupons.
  ///
  /// In en, this message translates to:
  /// **'Available coupons'**
  String get availableCoupons;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportAnIssue;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changePasswordHam.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get changePasswordHam;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @referralRewards.
  ///
  /// In en, this message translates to:
  /// **'Referral rewards'**
  String get referralRewards;

  /// No description provided for @getReward.
  ///
  /// In en, this message translates to:
  /// **'Get reward'**
  String get getReward;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @termsOfUseAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use and Privacy Policy'**
  String get termsOfUseAndPrivacy;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @youHaveToInputTheSamePass.
  ///
  /// In en, this message translates to:
  /// **'You have to input the same password twice to confirm the new password.'**
  String get youHaveToInputTheSamePass;

  /// No description provided for @passwordMatches.
  ///
  /// In en, this message translates to:
  /// **'The new password matches.'**
  String get passwordMatches;

  /// No description provided for @atleast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atleast8Characters;

  /// No description provided for @continued.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continued;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @becomeFriendsWithBrowny.
  ///
  /// In en, this message translates to:
  /// **'Become Friends with Browny'**
  String get becomeFriendsWithBrowny;

  /// No description provided for @yourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get yourPhoneNumber;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @numberOfSuccessfulReferrals.
  ///
  /// In en, this message translates to:
  /// **'Number of successful referrals'**
  String get numberOfSuccessfulReferrals;

  /// No description provided for @numberOfCouponsReceived.
  ///
  /// In en, this message translates to:
  /// **'Number of coupons received'**
  String get numberOfCouponsReceived;

  /// No description provided for @termsOfUseCap.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUseCap;

  /// No description provided for @updateYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Your Profile'**
  String get updateYourProfile;

  /// No description provided for @nameSurname.
  ///
  /// In en, this message translates to:
  /// **'Name - Surname'**
  String get nameSurname;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get genderNotSpecified;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @enterTheCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter the current PIN'**
  String get enterTheCurrentPin;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN'**
  String get forgotPin;

  /// No description provided for @createNewPin.
  ///
  /// In en, this message translates to:
  /// **'Create new 6-digit PIN'**
  String get createNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Authentication'**
  String get enableBiometric;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @eVouchers.
  ///
  /// In en, this message translates to:
  /// **'E-vouchers'**
  String get eVouchers;

  /// No description provided for @chooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose store'**
  String get chooseStore;

  /// No description provided for @typeStoreNameOrScanQR.
  ///
  /// In en, this message translates to:
  /// **'Type store name or scan QR'**
  String get typeStoreNameOrScanQR;

  /// No description provided for @choosePackage.
  ///
  /// In en, this message translates to:
  /// **'Choose package'**
  String get choosePackage;

  /// No description provided for @pleaseChooseStoreFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose store first'**
  String get pleaseChooseStoreFirst;

  /// No description provided for @iHaveReadAndAcceptedThe.
  ///
  /// In en, this message translates to:
  /// **'I have read and accepted the'**
  String get iHaveReadAndAcceptedThe;

  /// No description provided for @termsOfUseSmall.
  ///
  /// In en, this message translates to:
  /// **'terms of use.'**
  String get termsOfUseSmall;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @normalPrice.
  ///
  /// In en, this message translates to:
  /// **'Normal price'**
  String get normalPrice;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @washingCount.
  ///
  /// In en, this message translates to:
  /// **'#Washing'**
  String get washingCount;

  /// No description provided for @dryingCount.
  ///
  /// In en, this message translates to:
  /// **'#Drying'**
  String get dryingCount;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total payment'**
  String get totalPayment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number.'**
  String get enterYourPhoneNumber;

  /// No description provided for @iHaveAccepted.
  ///
  /// In en, this message translates to:
  /// **'I have accepted'**
  String get iHaveAccepted;

  /// No description provided for @termsOfUseAndPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'term of use and privacy policy'**
  String get termsOfUseAndPrivacyPolicy;

  /// No description provided for @ofBrowny24hrWashAndDry.
  ///
  /// In en, this message translates to:
  /// **'of Browny 24hr Wash & Dry'**
  String get ofBrowny24hrWashAndDry;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @pleaseEnterThe6DigitsOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP code sent to the number'**
  String get pleaseEnterThe6DigitsOtp;

  /// No description provided for @requestOtpAgain.
  ///
  /// In en, this message translates to:
  /// **'Request OTP again'**
  String get requestOtpAgain;

  /// No description provided for @setYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set your new password'**
  String get setYourNewPassword;

  /// No description provided for @inputPassword.
  ///
  /// In en, this message translates to:
  /// **'Input password'**
  String get inputPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @enterPhoneNumberOfaReferrer.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number of a referrer.'**
  String get enterPhoneNumberOfaReferrer;

  /// No description provided for @thisNumberDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'This number does not exist.'**
  String get thisNumberDoesNotExist;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @set6digitPin.
  ///
  /// In en, this message translates to:
  /// **'Set a 6-digit PIN'**
  String get set6digitPin;

  /// No description provided for @chooseProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile picture'**
  String get chooseProfilePicture;

  /// No description provided for @estFinishTime.
  ///
  /// In en, this message translates to:
  /// **'Est. finish time'**
  String get estFinishTime;

  /// No description provided for @addDryingTime.
  ///
  /// In en, this message translates to:
  /// **'Add drying time'**
  String get addDryingTime;

  /// No description provided for @machineNo.
  ///
  /// In en, this message translates to:
  /// **'Machine No.'**
  String get machineNo;

  /// No description provided for @theMachineIsWorking.
  ///
  /// In en, this message translates to:
  /// **'The machine is working.'**
  String get theMachineIsWorking;

  /// No description provided for @chooseWashProgram.
  ///
  /// In en, this message translates to:
  /// **'Choose wash program'**
  String get chooseWashProgram;

  /// No description provided for @chooseCoupon.
  ///
  /// In en, this message translates to:
  /// **'Choose coupon'**
  String get chooseCoupon;

  /// No description provided for @viewAllCoupons.
  ///
  /// In en, this message translates to:
  /// **'View all coupons'**
  String get viewAllCoupons;

  /// No description provided for @selectTheAppropriateTemp.
  ///
  /// In en, this message translates to:
  /// **'Select the appropriate temperature setting for your laundry.'**
  String get selectTheAppropriateTemp;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @washingPrice.
  ///
  /// In en, this message translates to:
  /// **'Washing'**
  String get washingPrice;

  /// No description provided for @dryingPrice.
  ///
  /// In en, this message translates to:
  /// **'Drying'**
  String get dryingPrice;

  /// No description provided for @storePromotion.
  ///
  /// In en, this message translates to:
  /// **'Store promotion'**
  String get storePromotion;

  /// No description provided for @discountCoupon.
  ///
  /// In en, this message translates to:
  /// **'Discount coupon'**
  String get discountCoupon;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @payByDebitOrCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Pay by debit or credit card'**
  String get payByDebitOrCreditCard;

  /// No description provided for @yourFinancialInformation.
  ///
  /// In en, this message translates to:
  /// **'Your financial information will always remain confidential and will not be shared with any third parties.'**
  String get yourFinancialInformation;

  /// No description provided for @storeTheCard.
  ///
  /// In en, this message translates to:
  /// **'Store the card information for future payments.'**
  String get storeTheCard;

  /// No description provided for @iConfirmThatMyCard.
  ///
  /// In en, this message translates to:
  /// **'I confirm that my card information has been stored in my Browny account for future transactions.'**
  String get iConfirmThatMyCard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @extraDrying.
  ///
  /// In en, this message translates to:
  /// **'Extra drying'**
  String get extraDrying;

  /// No description provided for @remainingDay.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingDay;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @useCoupon.
  ///
  /// In en, this message translates to:
  /// **'Use Coupon'**
  String get useCoupon;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @fullyRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Fully redeemed'**
  String get fullyRedeemed;

  /// No description provided for @doNotShowThisDialogAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not show this dialog again.'**
  String get doNotShowThisDialogAgain;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @numberOfCoupon.
  ///
  /// In en, this message translates to:
  /// **'Number of coupon'**
  String get numberOfCoupon;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get dateTime;

  /// No description provided for @saveTheReceipt.
  ///
  /// In en, this message translates to:
  /// **'Save the receipt'**
  String get saveTheReceipt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @collectGift.
  ///
  /// In en, this message translates to:
  /// **'Collect gift'**
  String get collectGift;

  /// No description provided for @termsOfReceivingPrizes.
  ///
  /// In en, this message translates to:
  /// **'Terms of receiving prizes.'**
  String get termsOfReceivingPrizes;

  /// No description provided for @alwaysFun.
  ///
  /// In en, this message translates to:
  /// **'Always fun'**
  String get alwaysFun;

  /// No description provided for @withBrowny.
  ///
  /// In en, this message translates to:
  /// **'with Browny!'**
  String get withBrowny;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @machineType.
  ///
  /// In en, this message translates to:
  /// **'Machine type'**
  String get machineType;

  /// No description provided for @machineNumber.
  ///
  /// In en, this message translates to:
  /// **'Machine number'**
  String get machineNumber;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @backToMainPage.
  ///
  /// In en, this message translates to:
  /// **'Back to main page'**
  String get backToMainPage;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @tel.
  ///
  /// In en, this message translates to:
  /// **'Tel'**
  String get tel;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressInfo;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// No description provided for @readyToUse.
  ///
  /// In en, this message translates to:
  /// **'Ready to use'**
  String get readyToUse;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @addDryingTimeHead.
  ///
  /// In en, this message translates to:
  /// **'Add drying time'**
  String get addDryingTimeHead;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No Content.'**
  String get noContent;

  /// No description provided for @myAddress.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get myAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addNewAddress;

  /// No description provided for @manageAddress.
  ///
  /// In en, this message translates to:
  /// **'Manage Address'**
  String get manageAddress;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @creditAndDebit.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit'**
  String get creditAndDebit;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Error, Something went wrong.'**
  String get somethingWrong;

  /// No description provided for @pleaseEnterCorrectPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct phone number format'**
  String get pleaseEnterCorrectPhoneFormat;

  /// No description provided for @requestOtpAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Request OTP again in'**
  String get requestOtpAgainIn;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @notSpecifiedNameSurname.
  ///
  /// In en, this message translates to:
  /// **'Not specified Name-Surname'**
  String get notSpecifiedNameSurname;

  /// No description provided for @notSpecifiedDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Not specified date of birth'**
  String get notSpecifiedDateOfBirth;

  /// No description provided for @notSpecifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Not specified email'**
  String get notSpecifiedEmail;

  /// No description provided for @skipNow.
  ///
  /// In en, this message translates to:
  /// **'Skip now'**
  String get skipNow;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startNow;

  /// No description provided for @everyTimeOfUse.
  ///
  /// In en, this message translates to:
  /// **'Every spend'**
  String get everyTimeOfUse;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @seeAllPrize.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllPrize;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get deliveryDetails;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get recipientName;

  /// No description provided for @recipientTel.
  ///
  /// In en, this message translates to:
  /// **'Recipient tel'**
  String get recipientTel;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @specialPrice.
  ///
  /// In en, this message translates to:
  /// **'Special price'**
  String get specialPrice;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @editDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Delivery Address'**
  String get editDeliveryAddress;

  /// No description provided for @recipientDetails.
  ///
  /// In en, this message translates to:
  /// **'Recipient Details'**
  String get recipientDetails;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @nameS.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameS;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @telS.
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get telS;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @subDistrict.
  ///
  /// In en, this message translates to:
  /// **'Sub-district'**
  String get subDistrict;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddress;

  /// No description provided for @messageToDeliveryPerson.
  ///
  /// In en, this message translates to:
  /// **'Message to a delivery person.'**
  String get messageToDeliveryPerson;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromPrice;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @pleaseEnterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get pleaseEnterEmailOrPhone;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @pleaseEnterValidEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone number'**
  String get pleaseEnterValidEmailOrPhone;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @passwordMustContainUppercase.
  ///
  /// In en, this message translates to:
  /// **'Contain at least one uppercase letter'**
  String get passwordMustContainUppercase;

  /// No description provided for @passwordMustContainLowercase.
  ///
  /// In en, this message translates to:
  /// **'Contain at least one lowercase letter'**
  String get passwordMustContainLowercase;

  /// No description provided for @passwordMustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Contain at least one number'**
  String get passwordMustContainNumber;

  /// No description provided for @loginWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Browny welcomes you, let\'s do laundry together'**
  String get loginWelcomeDescription;

  /// No description provided for @loginWith.
  ///
  /// In en, this message translates to:
  /// **'Login with'**
  String get loginWith;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email/phone number'**
  String get forgotPasswordDescription;

  /// No description provided for @dontHaveAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get dontHaveAccountYet;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign up now!'**
  String get signUpNow;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @errorUi.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorUi;

  /// No description provided for @topup.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topup;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User account not found for this information.'**
  String get userNotFound;

  /// No description provided for @userUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get userUnauthorized;

  /// No description provided for @userDuplicated.
  ///
  /// In en, this message translates to:
  /// **'This user already exists.'**
  String get userDuplicated;

  /// No description provided for @confirmOTP.
  ///
  /// In en, this message translates to:
  /// **'Confirm One-Time Password (OTP)'**
  String get confirmOTP;

  /// No description provided for @confirmOTPDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit one-time password to verify your account'**
  String get confirmOTPDescription;

  /// No description provided for @otpUnauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect OTP code. Please request a new password.'**
  String get otpUnauthorizedError;

  /// No description provided for @otpExpiredError.
  ///
  /// In en, this message translates to:
  /// **'OTP has expired'**
  String get otpExpiredError;

  /// No description provided for @ddMMyy.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YY'**
  String get ddMMyy;

  /// No description provided for @addPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get addPhoneNumber;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @balanceRemaining.
  ///
  /// In en, this message translates to:
  /// **'Balance Remaining'**
  String get balanceRemaining;

  /// No description provided for @reportIssueOrRefundMessage.
  ///
  /// In en, this message translates to:
  /// **'*If you encounter any usage problems or wish to request a refund, please click here'**
  String get reportIssueOrRefundMessage;

  /// No description provided for @specifyAmount.
  ///
  /// In en, this message translates to:
  /// **'Specify Amount'**
  String get specifyAmount;

  /// No description provided for @minimumTopUp.
  ///
  /// In en, this message translates to:
  /// **'Minimum top-up 100 THB'**
  String get minimumTopUp;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @promptPayQRCode.
  ///
  /// In en, this message translates to:
  /// **'PromptPay QR Code'**
  String get promptPayQRCode;

  /// No description provided for @minimumTopUpValidation.
  ///
  /// In en, this message translates to:
  /// **'Minimum top-up 100 THB'**
  String get minimumTopUpValidation;

  /// No description provided for @maximumTopUpValidation.
  ///
  /// In en, this message translates to:
  /// **'Maximum top-up 2,000 THB'**
  String get maximumTopUpValidation;

  /// No description provided for @qrCodeSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'QR Code saved successfully'**
  String get qrCodeSavedSuccessfully;

  /// No description provided for @cannotSaveQRCode.
  ///
  /// In en, this message translates to:
  /// **'Cannot save QR Code'**
  String get cannotSaveQRCode;

  /// No description provided for @pleaseAllowPhotoLibraryAccess.
  ///
  /// In en, this message translates to:
  /// **'Please allow photo library access in settings'**
  String get pleaseAllowPhotoLibraryAccess;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @cancelTransaction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Transaction'**
  String get cancelTransaction;

  /// No description provided for @confirmCancelTransaction.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the transaction?'**
  String get confirmCancelTransaction;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @transactionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction Receipt'**
  String get transactionReceipt;

  /// No description provided for @backToTopUpPage.
  ///
  /// In en, this message translates to:
  /// **'Back to Top-up Page'**
  String get backToTopUpPage;

  /// No description provided for @transactionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful'**
  String get transactionSuccessful;

  /// No description provided for @youReceivedBonus.
  ///
  /// In en, this message translates to:
  /// **'You received a bonus'**
  String get youReceivedBonus;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction Number'**
  String get transactionNumber;

  /// No description provided for @topUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top-up Failed'**
  String get topUpFailed;

  /// No description provided for @topUpFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Due to a problem with the destination bank or insufficient account balance. Please check the transaction again.'**
  String get topUpFailedMessage;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanning;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQR;

  /// No description provided for @brownyID.
  ///
  /// In en, this message translates to:
  /// **'Browny ID'**
  String get brownyID;
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
      <String>['en', 'th', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
