// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `field cannot be empty`
  String get validationMessage {
    return Intl.message(
      'field cannot be empty',
      name: 'validationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Login to Fluffy Paw Staff Portal`
  String get loginTitle {
    return Intl.message(
      'Login to Fluffy Paw Staff Portal',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Email Or Phone`
  String get emailOrPhone {
    return Intl.message(
      'Email Or Phone',
      name: 'emailOrPhone',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get login {
    return Intl.message(
      'Log in',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Min Order Amount`
  String get minOrderAmount {
    return Intl.message(
      'Min Order Amount',
      name: 'minOrderAmount',
      desc: '',
      args: [],
    );
  }

  /// `Shop Owner`
  String get shopOwner {
    return Intl.message(
      'Shop Owner',
      name: 'shopOwner',
      desc: '',
      args: [],
    );
  }

  /// `Shop Details`
  String get shopDetails {
    return Intl.message(
      'Shop Details',
      name: 'shopDetails',
      desc: '',
      args: [],
    );
  }

  /// `Add a profile photo`
  String get addProfile {
    return Intl.message(
      'Add a profile photo',
      name: 'addProfile',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Date Of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date Of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Create Password`
  String get createPassword {
    return Intl.message(
      'Create Password',
      name: 'createPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPass {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPass',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enterCode {
    return Intl.message(
      'Enter Code',
      name: 'enterCode',
      desc: '',
      args: [],
    );
  }

  /// `We have send OTP code to`
  String get otpDes {
    return Intl.message(
      'We have send OTP code to',
      name: 'otpDes',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Code`
  String get confirm {
    return Intl.message(
      'Confirm Code',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Shop Name`
  String get shopName {
    return Intl.message(
      'Shop Name',
      name: 'shopName',
      desc: '',
      args: [],
    );
  }

  /// `Order Prefix Code`
  String get orderPrefixCode {
    return Intl.message(
      'Order Prefix Code',
      name: 'orderPrefixCode',
      desc: '',
      args: [],
    );
  }

  /// `Shop Logo`
  String get shopLogo {
    return Intl.message(
      'Shop Logo',
      name: 'shopLogo',
      desc: '',
      args: [],
    );
  }

  /// `Upload Logo`
  String get uploadLogo {
    return Intl.message(
      'Upload Logo',
      name: 'uploadLogo',
      desc: '',
      args: [],
    );
  }

  /// `Upload Banner`
  String get uploadBanner {
    return Intl.message(
      'Upload Banner',
      name: 'uploadBanner',
      desc: '',
      args: [],
    );
  }

  /// `Banner Image`
  String get bannerImage {
    return Intl.message(
      'Banner Image',
      name: 'bannerImage',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Procced Next`
  String get proccedNext {
    return Intl.message(
      'Procced Next',
      name: 'proccedNext',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message(
      'Orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `Riders`
  String get riders {
    return Intl.message(
      'Riders',
      name: 'riders',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Well Done!`
  String get wellDone {
    return Intl.message(
      'Well Done!',
      name: 'wellDone',
      desc: '',
      args: [],
    );
  }

  /// `Your registration has been completed successfully.Please wait for approval.`
  String get underReviewDes {
    return Intl.message(
      'Your registration has been completed successfully.Please wait for approval.',
      name: 'underReviewDes',
      desc: '',
      args: [],
    );
  }

  /// `Your profile is under review`
  String get underReviewText {
    return Intl.message(
      'Your profile is under review',
      name: 'underReviewText',
      desc: '',
      args: [],
    );
  }

  /// `Create New Rider`
  String get createNewRider {
    return Intl.message(
      'Create New Rider',
      name: 'createNewRider',
      desc: '',
      args: [],
    );
  }

  /// `Create Rider`
  String get createRider {
    return Intl.message(
      'Create Rider',
      name: 'createRider',
      desc: '',
      args: [],
    );
  }

  /// `Driving Licence`
  String get drivingLicence {
    return Intl.message(
      'Driving Licence',
      name: 'drivingLicence',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Type`
  String get vehicleType {
    return Intl.message(
      'Vehicle Type',
      name: 'vehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Today's Order`
  String get todaysOrder {
    return Intl.message(
      'Today\'s Order',
      name: 'todaysOrder',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing Order`
  String get ongoingOrder {
    return Intl.message(
      'Ongoing Order',
      name: 'ongoingOrder',
      desc: '',
      args: [],
    );
  }

  /// `Today's Earnings`
  String get todaysEarnings {
    return Intl.message(
      'Today\'s Earnings',
      name: 'todaysEarnings',
      desc: '',
      args: [],
    );
  }

  /// `Earned this month`
  String get earndThisMonth {
    return Intl.message(
      'Earned this month',
      name: 'earndThisMonth',
      desc: '',
      args: [],
    );
  }

  /// `New Order`
  String get newOrder {
    return Intl.message(
      'New Order',
      name: 'newOrder',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message(
      'See All',
      name: 'seeAll',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirmOrder {
    return Intl.message(
      'Confirm',
      name: 'confirmOrder',
      desc: '',
      args: [],
    );
  }

  /// `Pickup`
  String get toPickup {
    return Intl.message(
      'Pickup',
      name: 'toPickup',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get processing {
    return Intl.message(
      'Processing',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `On Going`
  String get onGoing {
    return Intl.message(
      'On Going',
      name: 'onGoing',
      desc: '',
      args: [],
    );
  }

  /// `Deliverd`
  String get deliverd {
    return Intl.message(
      'Deliverd',
      name: 'deliverd',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `No order found!`
  String get orderNotFound {
    return Intl.message(
      'No order found!',
      name: 'orderNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Downloaded Successfully`
  String get invoiceDownloaded {
    return Intl.message(
      'Invoice Downloaded Successfully',
      name: 'invoiceDownloaded',
      desc: '',
      args: [],
    );
  }

  /// `Shipping Info`
  String get shippingInfo {
    return Intl.message(
      'Shipping Info',
      name: 'shippingInfo',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Pickup Date`
  String get pickUpDate {
    return Intl.message(
      'Pickup Date',
      name: 'pickUpDate',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Date`
  String get deliveryDate {
    return Intl.message(
      'Delivery Date',
      name: 'deliveryDate',
      desc: '',
      args: [],
    );
  }

  /// `Customer Info`
  String get customerInfo {
    return Intl.message(
      'Customer Info',
      name: 'customerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get items {
    return Intl.message(
      'Items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `Accept & assign for Pickup`
  String get accepAndAssignRider {
    return Intl.message(
      'Accept & assign for Pickup',
      name: 'accepAndAssignRider',
      desc: '',
      args: [],
    );
  }

  /// `Received Order`
  String get receivedOrder {
    return Intl.message(
      'Received Order',
      name: 'receivedOrder',
      desc: '',
      args: [],
    );
  }

  /// `'Assign for Delivery`
  String get assignForDelivery {
    return Intl.message(
      '\'Assign for Delivery',
      name: 'assignForDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Search by name/phone`
  String get searchByName {
    return Intl.message(
      'Search by name/phone',
      name: 'searchByName',
      desc: '',
      args: [],
    );
  }

  /// `Complete Job in`
  String get completeJobIn {
    return Intl.message(
      'Complete Job in',
      name: 'completeJobIn',
      desc: '',
      args: [],
    );
  }

  /// `Cash Collected in`
  String get cashCollectedIn {
    return Intl.message(
      'Cash Collected in',
      name: 'cashCollectedIn',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inActive {
    return Intl.message(
      'Inactive',
      name: 'inActive',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Personal Info`
  String get personalInfo {
    return Intl.message(
      'Personal Info',
      name: 'personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `Driving licences`
  String get drivigLicence {
    return Intl.message(
      'Driving licences',
      name: 'drivigLicence',
      desc: '',
      args: [],
    );
  }

  /// `Select a Rider`
  String get selectRider {
    return Intl.message(
      'Select a Rider',
      name: 'selectRider',
      desc: '',
      args: [],
    );
  }

  /// `Assign to Rider`
  String get assignToRider {
    return Intl.message(
      'Assign to Rider',
      name: 'assignToRider',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Earned this month`
  String get earnThisMonth {
    return Intl.message(
      'Earned this month',
      name: 'earnThisMonth',
      desc: '',
      args: [],
    );
  }

  /// `Earning History`
  String get earningHistory {
    return Intl.message(
      'Earning History',
      name: 'earningHistory',
      desc: '',
      args: [],
    );
  }

  /// `Seller Profile`
  String get sellerProfile {
    return Intl.message(
      'Seller Profile',
      name: 'sellerProfile',
      desc: '',
      args: [],
    );
  }

  /// `Store Account`
  String get storeAccount {
    return Intl.message(
      'Store Account',
      name: 'storeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Seller Support`
  String get sellerSupport {
    return Intl.message(
      'Seller Support',
      name: 'sellerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get termsconditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsconditions',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `COD`
  String get cod {
    return Intl.message(
      'COD',
      name: 'cod',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get toDay {
    return Intl.message(
      'Today',
      name: 'toDay',
      desc: '',
      args: [],
    );
  }

  /// `This Week`
  String get thisWeek {
    return Intl.message(
      'This Week',
      name: 'thisWeek',
      desc: '',
      args: [],
    );
  }

  /// `Last Week`
  String get lastWeek {
    return Intl.message(
      'Last Week',
      name: 'lastWeek',
      desc: '',
      args: [],
    );
  }

  /// `This Month`
  String get thisMonth {
    return Intl.message(
      'This Month',
      name: 'thisMonth',
      desc: '',
      args: [],
    );
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message(
      'Last Month',
      name: 'lastMonth',
      desc: '',
      args: [],
    );
  }

  /// `This Year`
  String get thisYear {
    return Intl.message(
      'This Year',
      name: 'thisYear',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message(
      'Last Year',
      name: 'lastYear',
      desc: '',
      args: [],
    );
  }

  /// `Online Payment`
  String get onlinePayment {
    return Intl.message(
      'Online Payment',
      name: 'onlinePayment',
      desc: '',
      args: [],
    );
  }

  /// `The profile image is required!`
  String get profileImageIsReq {
    return Intl.message(
      'The profile image is required!',
      name: 'profileImageIsReq',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure, you want to cancel this order?`
  String get orderCancelDes {
    return Intl.message(
      'Are you sure, you want to cancel this order?',
      name: 'orderCancelDes',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure, you want to log out of your account?`
  String get logoutDes {
    return Intl.message(
      'Are you sure, you want to log out of your account?',
      name: 'logoutDes',
      desc: '',
      args: [],
    );
  }

  /// `Staff`
  String get header {
    return Intl.message(
      'Staff',
      name: 'header',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message(
      'Accepted',
      name: 'accepted',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get canceled {
    return Intl.message(
      'Canceled',
      name: 'canceled',
      desc: '',
      args: [],
    );
  }

  /// `Denied`
  String get denied {
    return Intl.message(
      'Denied',
      name: 'denied',
      desc: '',
      args: [],
    );
  }

  /// `OverTime`
  String get overTime {
    return Intl.message(
      'OverTime',
      name: 'overTime',
      desc: '',
      args: [],
    );
  }

  /// `Ended`
  String get ended {
    return Intl.message(
      'Ended',
      name: 'ended',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
