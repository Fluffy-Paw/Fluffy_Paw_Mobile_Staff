class AppConstants {
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net';
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String dashboardInfo = '$baseUrl/api/Staff/GetAllBookingByStore';
  static const String getAccountDetails = '$baseUrl/api/Staff/GetStoreByStaff';
  static const String acceptBooking = '$baseUrl/api/Staff/AcceptBooking';
  static const String deniedBooking = '$baseUrl/api/Staff/DeniedBooking';

  // Hive Box Names
  static const String appSettingsBox = 'appSettings';
  static const String authBox = 'fluffyPaw_authBox';
  static const String userBox = 'fluffyPaw_userBox';
  static const String orderStatusBox = 'orderStatusBox';

  // Hive Keys
  static const String appLocal = 'appLocal';
  static const String isDarkTheme = 'isDarkTheme';
  static const String authToken = 'token';

  // User Variable Names
  static const String userData = 'userData';
  static const String storeData = 'storeData';

  // Order Status Keys for Hive Storage
  static const String acceptedOrders = 'Accepted';
  static const String pendingOrders = 'Pending';
  static const String canceledOrders = 'Canceled';
  static const String deniedOrders = 'Denied';
  static const String overTimeOrders = 'OverTime';
  static const String endedOrders = 'Ended';

  // Currency
  static const String appCurrency = "\$";
}
