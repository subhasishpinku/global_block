import 'package:shared_preferences/shared_preferences.dart';

class Preferances {
  save(key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print('saved $value');
  }

  Future<String> read(key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = await prefs.getString(key) ?? '';
    return value;
  }
}
