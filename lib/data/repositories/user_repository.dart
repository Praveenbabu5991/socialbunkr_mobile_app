
import '../providers/user_api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final UserApiProvider _userApiProvider = UserApiProvider();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final userData = await _userApiProvider.login(email, password);
    await persistToken(userData['token']);
    if (userData['organization_id'] != null) {
      await _secureStorage.write(key: 'organization_id', value: userData['organization_id']);
    }
    await _secureStorage.write(key: 'organization_is_verified', value: userData['organization_is_verified'].toString());
    return userData;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'organization_id');
    await _secureStorage.delete(key: 'organization_is_verified');
  }

  Future<void> persistToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<bool> hasToken() async {
    final String? token = await _secureStorage.read(key: 'token');
    return token != null;
  }

  Future<String?> getOrganizationId() async {
    return await _secureStorage.read(key: 'organization_id');
  }

  Future<bool> isOrganizationVerified() async {
    final String? isVerified = await _secureStorage.read(key: 'organization_is_verified');
    return isVerified == 'true';
  }

  Future<Map<String, dynamic>> signup(String email, String password, String firstName, String lastName, String role) {
    return _userApiProvider.signup(email, password, firstName, lastName, role);
  }
}
