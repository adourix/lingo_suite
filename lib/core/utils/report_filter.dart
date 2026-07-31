import 'package:shared_preferences/shared_preferences.dart';

class ReportFilter {
  static const key = "last_report_clear";

  static Future<DateTime?> getLastClear() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(key);

    if (value == null) return null;

    return DateTime.parse(value);
  }

  static Future<void> clearNow() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, DateTime.now().toIso8601String());
  }
}
