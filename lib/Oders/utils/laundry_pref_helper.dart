import 'dart:convert';
import 'package:my_flutter_mapwash/Oders/models/laundry_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaundryPrefHelper {
  // =========================
  // Preference Keys
  // =========================
  static const String laundryType = 'laundry_type';

  static const String machineSize = 'machine_size';
  static const String dryerSize = 'dryer_size';
  static const String temperature = 'temperature';

  static const String detergent = 'detergent';
  static const String softener = 'softener';

  static const String note = 'laundry_note';
  static const String imagePath = 'laundry_image';

  // =========================
  // Save Laundry Item
  // =========================
  static Future<void> saveItem({
    required String key,
    required LaundryItem item,
    int quantity = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'id': item.id,
      'name': item.name,
      'detail': item.detail,
      'image': item.image,
      'price': item.price,
      'quantity': quantity,
    };

    await prefs.setString(key, jsonEncode(data));
  }

  // =========================
  // Load Laundry Item
  // =========================
  static Future<Map<String, dynamic>?> loadItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // =========================
  // Remove Laundry Item
  // =========================
  static Future<void> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // =========================
  // Laundry Type (Clothes / Bedding)
  // =========================
  static Future<void> saveLaundryType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(laundryType, type);
  }

  static Future<String?> loadLaundryType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(laundryType);
  }

  // =========================
  // Note
  // =========================
  static Future<void> saveNote(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(note, text);
  }

  static Future<String?> loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(note);
  }

  // =========================
  // Image
  // =========================
  static Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(imagePath, path);
  }

  static Future<String?> loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(imagePath);
  }

  // =========================
  // Clear All Laundry Data
  // =========================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(laundryType);
    await prefs.remove(machineSize);
    await prefs.remove(dryerSize);
    await prefs.remove(temperature);
    await prefs.remove(detergent);
    await prefs.remove(softener);
    await prefs.remove(note);
    await prefs.remove(imagePath);
  }

  // =========================
  // Load All (for Summary Page)
  // =========================
  static Future<Map<String, dynamic>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> result = {};

    for (final key in [
      laundryType,
      machineSize,
      dryerSize,
      temperature,
      detergent,
      softener,
    ]) {
      final value = prefs.getString(key);
      if (value != null) {
        result[key] = jsonDecode(value);
      }
    }

    result[note] = prefs.getString(note);
    result[imagePath] = prefs.getString(imagePath);

    return result;
  }
}
