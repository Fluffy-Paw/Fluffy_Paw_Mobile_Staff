import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/models/authentication/settings.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/repositories/auth_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationController extends StateNotifier<bool> {
  late final Ref ref;

  AuthenticationController(this.ref) : super(false);

  late Settings _settings;

  // Future<bool> getSettingsInfo() async {
  //   try {
  //     final response = await ref.read(authServiceProvider).settings();
  //     _settings = Settings.fromMap(response.data['data']);
  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }
  // login
  Future<bool> login(
      {required String contact, required String password}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .login(contact: contact, password: password);
      //final userInfo = User.fromMap(response.data['data']);

      if (response.statusCode != 200) {
        state = false;
        return false;
      }
      final accessToken = response.data['data'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

      // Kiểm tra role nếu là "PetOwner" thì trả về false
      String? role = decodedToken[
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
      if (role == "PetOwner") {
        state = false;
        return false; // Nếu role là "PetOwner", trả về false
      }

      //ref.read(hiveStoreService).saveUserInfo(userInfo: userInfo);
      ref.read(hiveStoreService).saveUserAuthToken(authToken: accessToken);
      ref.read(apiClientProvider).updateToken(token: accessToken);
      await ref.read(profileController.notifier).getAccountDetails();
      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }
}

final authController = StateNotifierProvider<AuthenticationController, bool>(
    (ref) => AuthenticationController(ref));
