import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setThemeMode(bool value) async {
    return await _prefs.setBool('isDarkMode', value);
  }

  static bool getThemeMode() {
    return _prefs.getBool('isDarkMode') ?? false;
  }

  static Future<bool> setOnBoardScreenWatched() async {
    return _prefs.setBool('onBoard', true);
  }

  static bool getOnBoardScreenStatus() {
    return _prefs.getBool('onBoard') ?? false;
  }

  static Future<bool> saveUserId(String uid) async {
    return _prefs.setString('uid', uid);
  }

  static String? getUserId() {
    return _prefs.getString('uid');
  }

  static Future<bool> removeData(String key) {
    return _prefs.remove(key);
  }
}
