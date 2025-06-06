import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class for saving and loading form data from local storage.
class FormStorage {
  /// In-memory storage for web platforms.
  final Map<String, String> _memoryStorage = {};
  static const String _keyPrefix = 'auto_form_builder_';

  /// Saves form data to storage.
  Future<bool> saveForm(String formId, Map<String, dynamic> data) async {
    try {
      final jsonData = jsonEncode(_prepareDataForStorage(data));

      // Use shared_preferences for persistent storage
      if (!kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_keyPrefix$formId', jsonData);
      } else {
        // Fallback to in-memory storage for web
        _memoryStorage[formId] = jsonData;
      }

      return true;
    } catch (e) {
      debugPrint('Error saving form: $e');
      return false;
    }
  }

  /// Loads form data from storage.
  Future<Map<String, dynamic>?> loadForm(String formId) async {
    try {
      String? jsonData;

      // Use shared_preferences for persistent storage
      if (!kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        jsonData = prefs.getString('$_keyPrefix$formId');
      } else {
        // Fallback to in-memory storage for web
        jsonData = _memoryStorage[formId];
      }

      if (jsonData == null) return null;

      return _restoreDataFromStorage(jsonDecode(jsonData));
    } catch (e) {
      debugPrint('Error loading form: $e');
      return null;
    }
  }

  /// Deletes form data from storage.
  Future<bool> deleteForm(String formId) async {
    try {
      if (!kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('$_keyPrefix$formId');
      } else {
        _memoryStorage.remove(formId);
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting form: $e');
      return false;
    }
  }

  /// Prepares data for storage by converting non-serializable types
  Map<String, dynamic> _prepareDataForStorage(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is DateTime) {
        // Convert DateTime to ISO string
        result[key] = {'type': 'datetime', 'value': value.toIso8601String()};
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  /// Restores data from storage by converting serialized types back
  Map<String, dynamic> _restoreDataFromStorage(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is Map && value['type'] == 'datetime') {
        // Convert ISO string back to DateTime
        result[key] = DateTime.parse(value['value']);
      } else {
        result[key] = value;
      }
    });

    return result;
  }
}