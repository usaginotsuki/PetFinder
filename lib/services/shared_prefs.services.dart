//write a shared prefs dart file
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<bool> setUserID(String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString("userID", value);
  }

  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<String?> getUserID() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString("userID");
  }

  Future<bool> setPhoneVerified(bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool("phoneVerified", value);
  }

  Future<bool?> getPhoneVerified() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool("phoneVerified");
  }
}
