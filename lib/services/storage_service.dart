import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // =================== TOKEN ===================
  static Future<void> saveToken(String token) async =>
      await _prefs?.setString(AppConstants.tokenKey, token);

  static String? getToken() => _prefs?.getString(AppConstants.tokenKey);

  static Future<void> removeToken() async =>
      await _prefs?.remove(AppConstants.tokenKey);

  // =================== USER DATA ===================
  static Future<void> saveUserData({
    required int userId,
    required String userName,
    required String email,
    required String role,
  }) async {
    await _prefs?.setInt(AppConstants.userIdKey, userId);
    await _prefs?.setString(AppConstants.userNameKey, userName);
    await _prefs?.setString(AppConstants.userEmailKey, email);
    await _prefs?.setString(AppConstants.userRoleKey, role);
  }

  static int getUserId() => _prefs?.getInt(AppConstants.userIdKey) ?? 0;

  static String getUserName() =>
      _prefs?.getString(AppConstants.userNameKey) ?? '';

  static String getUserEmail() =>
      _prefs?.getString(AppConstants.userEmailKey) ?? '';

  static String getUserRole() =>
      _prefs?.getString(AppConstants.userRoleKey) ?? '';

  // =================== REQUIRES SELFIE ===================
  // ✅ Login ke time DB ka requiresSelfie value save hoga
  // ✅ AttendanceController isko directly read karega — hardcoded list nahi
  static Future<void> saveRequiresSelfie(bool value) async =>
      await _prefs?.setBool('requires_selfie', value);

  static bool getRequiresSelfie() =>
      _prefs?.getBool('requires_selfie') ?? false;

  // =================== DEVICE ID ===================
  static Future<void> saveDeviceId(String deviceId) async =>
      await _prefs?.setString(AppConstants.deviceIdKey, deviceId);

  static String? getDeviceId() => _prefs?.getString(AppConstants.deviceIdKey);

  // =================== AUTH STATE ===================
  static bool isLoggedIn() => getToken() != null && getToken()!.isNotEmpty;

  static bool isAdmin() =>
      getUserRole().toLowerCase() == AppConstants.roleAdmin;

  // =================== CLEAR ALL ===================
  static Future<void> clearAll() async => await _prefs?.clear();
}