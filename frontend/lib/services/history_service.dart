import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grading_record.dart';

class HistoryService {
  static const _key = 'tilapiasize-history';

  Future<List<GradingRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => GradingRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<GradingRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final limited = records.take(10).map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(limited));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
