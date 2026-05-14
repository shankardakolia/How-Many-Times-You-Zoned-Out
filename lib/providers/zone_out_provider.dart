import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/zone_out_entry.dart';

class ZoneOutProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<ZoneOutEntry> _todayEntries = [];
  bool _isLoading = false;
  int _currentDuration = 10;

  List<ZoneOutEntry> get todayEntries => _todayEntries;
  bool get isLoading => _isLoading;
  int get currentDuration => _currentDuration;
  int get todayCount => _todayEntries.length;

  void setDuration(int seconds) {
    _currentDuration = seconds;
    notifyListeners();
  }

  Future<void> loadTodayEntries() async {
    _isLoading = true;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayEntries = await _db.getTodayEntries(today);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({int? durationSeconds}) async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final entry = ZoneOutEntry(
      timestamp: now,
      durationSeconds: durationSeconds ?? _currentDuration,
      date: today,
    );
    await _db.insertEntry(entry);
    await loadTodayEntries();
  }
}
