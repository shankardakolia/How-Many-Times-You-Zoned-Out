import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class DailyScore {
  final String date;
  final int count;
  final String label;

  DailyScore({
    required this.date,
    required this.count,
    required this.label,
  });
}

class StatsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<DailyScore> _dailyScores = [];
  String? _bestFocusDay;
  int _totalZoneOuts = 0;
  bool _isLoading = false;

  List<DailyScore> get dailyScores => _dailyScores;
  String? get bestFocusDay => _bestFocusDay;
  int get totalZoneOuts => _totalZoneOuts;
  bool get isLoading => _isLoading;

  Future<void> loadStats({int days = 7}) async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final labelFormatter = DateFormat('MM/dd');

    final dates = <String>[];
    final labels = <String, String>{};
    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = formatter.format(d);
      dates.add(dateStr);
      labels[dateStr] = labelFormatter.format(d);
    }

    final scores = await _db.getDailyScores(dates);
    _dailyScores = dates.map((date) {
      return DailyScore(
        date: date,
        count: scores[date] ?? 0,
        label: labels[date] ?? date,
      );
    }).toList();

    _totalZoneOuts = _dailyScores.fold(0, (sum, s) => sum + s.count);
    _bestFocusDay = await _db.getBestFocusDay();

    _isLoading = false;
    notifyListeners();
  }

  String generateShareReport() {
    final buffer = StringBuffer();
    buffer.writeln('🧠 Brain Fog Report');
    buffer.writeln('==================');
    buffer.writeln('Date: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('📊 Past 7 Days Summary:');
    buffer.writeln('Total zone-outs: $_totalZoneOuts');
    if (_bestFocusDay != null) {
      buffer.writeln('Best focus day: $_bestFocusDay');
    }
    buffer.writeln('');
    buffer.writeln('Daily breakdown:');
    for (final score in _dailyScores) {
      final bar = '🟦' * score.count.clamp(0, 10);
      buffer.writeln('${score.label}: ${score.count}x $bar');
    }
    buffer.writeln('');
    buffer.writeln('Track your own zone-outs with How Many Times You Zoned Out!');
    return buffer.toString();
  }
}
