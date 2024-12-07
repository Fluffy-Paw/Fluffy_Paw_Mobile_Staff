import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConstants {
  static const String baseUrl = 'https://fluffypaw.azurewebsites.net';
  static const String loginUrl = '$baseUrl/api/Authentication/Login';
  static const String dashboardInfo = '$baseUrl/api/Staff/GetAllBookingByStore';
  static const String getAccountDetails = '$baseUrl/api/Staff/GetStoreByStaff';
  static const String acceptBooking = '$baseUrl/api/Staff/AcceptBooking';
  static const String deniedBooking = '$baseUrl/api/Staff/DeniedBooking';
  static const String getStoreServiceForStaffbyStoreId =
      '$baseUrl/api/Service/GetAllServiceByStoreId';
  static const String createStoreService =
      '$baseUrl/api/Staff/CreateStoreService';
  static const String updateStoreService =
      '$baseUrl/api/Staff/UpdateStoreService';
  static const String deleteStoreService =
      '$baseUrl/api/Staff/DeleteStoreService';
  static const String getAllStoreServiceByServiceId =
      '$baseUrl/api/Staff/GetAllStoreServiceByServiceId';
  //Chat
  static const String getAllConversation =
      '$baseUrl/api/Conversation/GetAllConversation';
  static const String createConversation =
      '$baseUrl/api/Conversation/CreateConversation';
  static const String sendMessage = '$baseUrl/api/Conversation/SendMessage';
  static const String getAllConversationMessageByConversationId =
      '$baseUrl/api/Conversation/GetAllConversationMessageByConversationId';

  //Pet

  static const String getPetById = '$baseUrl/api/Pet/GetPet';
  //Service by brand
  
  static const String invalidMST = 'Invalid tax number format';
  static const String requiredDocument = 'This document is required';
  static const String invalidImage = 'Invalid image format';

  // Hive Box Names
  static const String appSettingsBox = 'appSettings';
  static const String authBox = 'fluffyPaw_authBox';
  static const String userBox = 'fluffyPaw_userBox';
  static const String orderStatusBox = 'orderStatusBox';
  static const String notificationBox = 'notificationBox';
  static const String conversationBox = 'conversation_box';

  // Hive Keys
  static const String appLocal = 'appLocal';
  static const String isDarkTheme = 'isDarkTheme';
  static const String authToken = 'token';
  static const String recentSearchesKey = 'recent_searches';

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
