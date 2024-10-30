class AppConstants{
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net/';
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String dashboardInfo = '$baseUrl/api/Staff/GetAllBookingByStore';
  static const String getAccountDetails = '$baseUrl/api/Staff/GetStoreByStaff';
  
  

  static const String appSettingsBox = 'appSettings';

  static const String appLocal = 'appLocal';

  static const String isDarkTheme = 'isDarkTheme';

  static const String authBox = 'fluffyPaw_authBox';
  static const String userBox = 'fluffyPaw_userBox';
  static const String authToken = 'token';


  // User Variable Names
  static const String userData = 'userData';
  static const String storeData = 'storeData';

  static String appCurrency = "\$";
}