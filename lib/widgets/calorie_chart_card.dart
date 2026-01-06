import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';

class CalorieChartCard extends StatefulWidget {
  final String title;
  final String timeRange;
  final List<Map<String, dynamic>> data;

  const CalorieChartCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.data,
  });

  @override
  State<CalorieChartCard> createState() => _CalorieChartCardState();
}

class _CalorieChartCardState extends State<CalorieChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final (maxY, interval) = _calculateMaxYAndInterval();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  "Hari ini",
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Chart
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround, //
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.primaryGreen,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = widget.data[group.x.toInt()];
                      return BarTooltipItem(
                        '${data['full_name'] ?? data['day']}\n',
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${data['calories']} kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getBottomTitles,
                      reservedSize: 38,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36, // 👉 diperkecil biar lebih rapat
                      interval: interval,
                      getTitlesWidget: _getLeftTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.dividerColor, strokeWidth: 1);
                  },
                  checkToShowHorizontalLine: (value) {
                    return (value % interval == 0) || (value >= maxY - 0.01);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  (double, double) _calculateMaxYAndInterval() {
    if (widget.data.isEmpty) {
      return (1000, 250); // Default values if no data
    }

    // Find maximum calories value
    double maxCalories = 0;
    for (final item in widget.data) {
      final calories = item['calories'] as double;
      if (calories > maxCalories) maxCalories = calories;
    }

    // Set maxY exactly to the highest calories value
    double maxY = maxCalories;

    // Calculate interval based on maxY
    double interval;
    if (maxY <= 500) {
      interval = 100;
    } else if (maxY <= 1000) {
      interval = 200;
    } else if (maxY <= 2000) {
      interval = 500;
    } else if (maxY <= 5000) {
      interval = 1000;
    } else {
      interval = 2000;
    }

    // Adjust interval supaya maxY pas kelipatan
    final numberOfIntervals = (maxY / interval).ceil();
    if (numberOfIntervals > 0) {
      interval = maxY / numberOfIntervals;
    }

    return (maxY, interval);
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final calories = data['calories'] as double;
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: calories,
            color: isTouched ? AppTheme.accentTeaGreen : AppTheme.primaryGreen,
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= widget.data.length) return Container();

    final data = widget.data[value.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        data['day'],
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value.toInt()}',
        style: AppTheme.bodySmall.copyWith(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Kalori Aktual', AppTheme.primaryGreen),
        const SizedBox(width: AppTheme.spacingL),
        // _buildLegendItem(
        //   'Target: ${widget.data.isNotEmpty ? widget.data[0]['target'] : 0} kcal',
        //   AppTheme.textSecondary,
        // ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
