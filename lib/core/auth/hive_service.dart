import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/data/models/conversation/conversation_model.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  final Ref ref;

  HiveService(this.ref);

  // save access token
  Future saveUserAuthToken({required String authToken}) async {
    final authBox = await Hive.openBox(AppConstants.authBox);
    authBox.put(AppConstants.authToken, authToken);
  }

  // get user auth token
  Future<String?> getAuthToken() async {
    final authToken = await Hive.openBox(AppConstants.authBox)
        .then((box) => box.get(AppConstants.authToken));

    if (authToken != null) {
      return authToken;
    }
    return null;
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final box = await Hive.openBox('appBox');
    await box.put(AppConstants.recentSearchesKey, searches);
  }

  Future<List<String>?> getRecentSearches() async {
    final box = await Hive.openBox('appBox');
    final searches = box.get(AppConstants.recentSearchesKey);
    if (searches is List) {
      return searches.cast<String>();
    }
    return null;
  }

  // remove access token
  Future removeUserAuthToken() async {
    final authBox = await Hive.openBox(AppConstants.authBox);
    authBox.delete(AppConstants.authToken);
  }

  // save user information
  Future saveUserInfo({required User userInfo}) async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    userBox.put(AppConstants.userData, userInfo.toMap());
  }

  // get user information
  Future<User?> getUserInfo() async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    Map<dynamic, dynamic>? userInfo = userBox.get(AppConstants.userData);
    if (userInfo != null) {
      Map<String, dynamic> userInfoStringKeys =
          userInfo.cast<String, dynamic>();
      User user = User.fromMap(userInfoStringKeys);
      return user;
    }
    return null;
  }

  //remove user data
  Future removeUserData() async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    userBox.clear();
  }

  //
  Future<bool> removeAllData() async {
    try {
      await removeUserAuthToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveOrderStatuses({
    required int acceptedOrders,
    required int pendingOrders,
    required int canceledOrders,
    required int deniedOrders,
    required int overTimeOrders,
    required int endedOrders,
  }) async {
    final orderStatusBox = await Hive.openBox(AppConstants.orderStatusBox);
    orderStatusBox.put(AppConstants.acceptedOrders, acceptedOrders);
    orderStatusBox.put(AppConstants.pendingOrders, pendingOrders);
    orderStatusBox.put(AppConstants.canceledOrders, canceledOrders);
    orderStatusBox.put(AppConstants.deniedOrders, deniedOrders);
    orderStatusBox.put(AppConstants.overTimeOrders, overTimeOrders);
    orderStatusBox.put(AppConstants.endedOrders, endedOrders);
  }

  // Hàm lấy dữ liệu trạng thái đơn hàng
  Future<Map<String, int>> getOrderStatuses() async {
    final orderStatusBox = await Hive.openBox(AppConstants.orderStatusBox);
    return {
      AppConstants.acceptedOrders:
          orderStatusBox.get(AppConstants.acceptedOrders, defaultValue: 0),
      AppConstants.pendingOrders:
          orderStatusBox.get(AppConstants.pendingOrders, defaultValue: 0),
      AppConstants.canceledOrders:
          orderStatusBox.get(AppConstants.canceledOrders, defaultValue: 0),
      AppConstants.deniedOrders:
          orderStatusBox.get(AppConstants.deniedOrders, defaultValue: 0),
      AppConstants.overTimeOrders:
          orderStatusBox.get(AppConstants.overTimeOrders, defaultValue: 0),
      AppConstants.endedOrders:
          orderStatusBox.get(AppConstants.endedOrders, defaultValue: 0),
    };
  }

  // Hàm cập nhật trạng thái đơn hàng khi có thay đổi
  Future<void> updateOrderStatus(String status, int newCount) async {
    final orderStatusBox = await Hive.openBox(AppConstants.orderStatusBox);
    orderStatusBox.put(status, newCount);
  }

  Future<void> saveConversations({
    required List<ConversationModel> conversations,
  }) async {
    final conversationBox =
        await Hive.openBox<dynamic>(AppConstants.conversationBox);

    // Store only essential metadata
    final conversationData = conversations
        .map((conv) => {
              'id': conv.id,
              'poAccountId': conv.poAccountId,
              'lastMessage': conv.lastMessage,
              'timeSinceLastMessage': conv.timeSinceLastMessage,
              'poName': conv.poName,
              'poAvatar': conv.poAvatar,
            })
        .toList();

    await conversationBox.put('conversations', conversationData);
  }

  Future<List<ConversationModel>?> getConversations() async {
    final conversationBox =
        await Hive.openBox<dynamic>(AppConstants.conversationBox);
    final data = conversationBox.get('conversations') as List?;

    if (data == null) return null;

    return data
        .map((item) =>
            ConversationModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}

final hiveStoreService = Provider((ref) => HiveService(ref));

extension ServiceStorage on HiveService {
  static const String _brandIdKey = 'brandId';

  Future<void> saveBrandId(int brandId) async {
    final box = await Hive.openBox(AppConstants.appSettingsBox);
    await box.put(_brandIdKey, brandId);
  }

  Future<int?> getBrandId() async {
    final box = await Hive.openBox(AppConstants.appSettingsBox);
    return box.get(_brandIdKey);
  }

  Future<void> saveServices({required List<ServiceModel> services}) async {
    final box = await Hive.openBox(AppConstants.servicesBox);
    await box.put('services', services.map((s) => s.toMap()).toList());
  }

  Future<List<ServiceModel>?> getServices() async {
    final box = await Hive.openBox(AppConstants.servicesBox);
    final data = box.get('services') as List?;
    if (data == null) return null;
    return data
        .map((item) => ServiceModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
