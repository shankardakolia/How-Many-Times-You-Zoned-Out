import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_provider.dart';

class ZoneOutChart extends StatelessWidget {
  final List<DailyScore> scores;

  const ZoneOutChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: Colors.grey)),
      );
    }

    final maxY = scores.fold<int>(0, (max, s) => s.count > max ? s.count : max);
    final chartMaxY = maxY < 1 ? 1.0 : maxY.toDouble();

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 24, top: 16, bottom: 8),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: chartMaxY + 1,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final score = scores[group.x.toInt()];
                  return BarTooltipItem(
                    '${score.label}\n${score.count}x',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= scores.length) {
                      return const SizedBox.shrink();
                    }
                    // Show every other label if too many
                    if (scores.length > 5 && index % 2 != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        scores[index].label,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 1,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: scores.asMap().entries.map((entry) {
              final index = entry.key;
              final score = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: score.count.toDouble(),
                    color: const Color(0xFF1E3A8A),
                    width: scores.length > 7 ? 14 : 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
