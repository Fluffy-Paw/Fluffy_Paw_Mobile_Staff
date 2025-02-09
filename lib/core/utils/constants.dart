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
  static const String forgotPasswordUrl='$baseUrl/api/Account/ForgotPassword';
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
  static const String getAllServiceByBrandId =
      '$baseUrl/api/Staff/GetAllServiceByBrandId';

  //SM
  static const String getStatisticsUrl =
      '$baseUrl/api/Dashboard/GetAllStaticsSM';
  static const String getAlStoreSM='$baseUrl/api/StoreManager/GetAllStoreBySM';
  static const String getAllBookingByStoreSM='$baseUrl/api/StoreManager/GetAllBookingByStore';
  static const String getAllServiceBySM='$baseUrl/api/Service/GetAllServiceBySM';
  static const String createCertificate='$baseUrl/api/Certificate/CreateCertificate';
  static const String createService='$baseUrl/api/Service/CreateService';
  static const String updateService='$baseUrl/api/Service/UpdateService';
  static const String getCertificatesByServiceId = '$baseUrl/api/Certificate/GetAllCertificateByServiceId';
  static const String deleteCertificate = '$baseUrl/api/Certificate/DeleteCertificate';
  static const String createStore = '$baseUrl/api/StoreManager/CreateStore';
  static const String getStoreManagerInfo = '$baseUrl/api/StoreManager/GetInfo';
  static const String updateStoreManagerProfile = '$baseUrl/api/StoreManager/UpdateProfile';

    //Wallet
  static const String viewWallet = '$baseUrl/api/Wallet/ViewWallet';
  static const String viewBalance = '$baseUrl/api/Wallet/ViewBalance';
  static const String createDepositLink='$baseUrl/api/Payment/CreateDepositLink';
  static const String cancelPayment='$baseUrl/api/Payment/CancelPayment';
  static const String checkDepositResult='$baseUrl/api/Payment/CheckDepositResult';
  static const String getAllTrancsaction='$baseUrl/api/Transaction/GetTransactions';
  static const String getAllBillingRecord='$baseUrl/api/PetOwner/GetAllBillingRecord';
  static const String updateBankInfo = '$baseUrl/api/Wallet/UpdateBankInfomation';
  static const String withdrawMoney = '$baseUrl/api/Wallet/WithdrawMoney';





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
  static const String servicesBox = 'servicesBox';

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
