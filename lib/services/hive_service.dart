import 'package:hive_flutter/hive_flutter.dart';
import '../models/date_model.dart';

class HiveService {
  static const String _boxName = 'important_dates';
  static Box<ImportantDate>? _box;

  static Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ImportantDate>(_boxName);
    }
  }

  static Box<ImportantDate> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call HiveService.init() first.');
    }
    return _box!;
  }

  // Add a new important date
  static Future<void> addDate(ImportantDate date) async {
    await init();
    await box.put(date.id, date);
  }

  // Get all important dates
  static Future<List<ImportantDate>> getAllDates() async {
    await init();
    return box.values.toList();
  }

  // Get a specific date by ID
  static Future<ImportantDate?> getDate(String id) async {
    await init();
    return box.get(id);
  }

  // Update an existing date
  static Future<void> updateDate(ImportantDate date) async {
    await init();
    await box.put(date.id, date);
  }

  // Delete a date by ID
  static Future<void> deleteDate(String id) async {
    await init();
    await box.delete(id);
  }

  // Get upcoming dates (not passed)
  static Future<List<ImportantDate>> getUpcomingDates() async {
    await init();
    final allDates = box.values.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allDates.where((date) {
      final eventDate = DateTime(date.date.year, date.date.month, date.date.day);
      return eventDate.isAtSameMomentAs(today) || eventDate.isAfter(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get passed dates
  static Future<List<ImportantDate>> getPassedDates() async {
    await init();
    final allDates = box.values.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allDates.where((date) {
      final eventDate = DateTime(date.date.year, date.date.month, date.date.day);
      return eventDate.isBefore(today);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get dates for today
  static Future<List<ImportantDate>> getTodayDates() async {
    await init();
    final allDates = box.values.toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allDates.where((date) {
      final eventDate = DateTime(date.date.year, date.date.month, date.date.day);
      return eventDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Clear all data
  static Future<void> clearAll() async {
    await init();
    await box.clear();
  }

  // Get statistics
  static Future<Map<String, int>> getStatistics() async {
    await init();
    final allDates = box.values.toList();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int total = allDates.length;
    int upcoming = 0;
    int passed = 0;
    int todayCount = 0;
    
    for (final date in allDates) {
      final eventDate = DateTime(date.date.year, date.date.month, date.date.day);
      if (eventDate.isAtSameMomentAs(todayDate)) {
        todayCount++;
        upcoming++; // Today counts as upcoming
      } else if (eventDate.isAfter(todayDate)) {
        upcoming++;
      } else {
        passed++;
      }
    }
    
    return {
      'total': total,
      'upcoming': upcoming,
      'passed': passed,
      'today': todayCount,
    };
  }

  // Close the box (call this when app is disposed)
  static Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}