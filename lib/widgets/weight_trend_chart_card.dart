import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';

class WeightTrendChartCard extends StatefulWidget {
  final String title;
  final String timeRange;
  final List<Map<String, dynamic>> data;
  final double targetWeight;

  const WeightTrendChartCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.data,
    required this.targetWeight,
  });

  @override
  State<WeightTrendChartCard> createState() => _WeightTrendChartCardState();
}

class _WeightTrendChartCardState extends State<WeightTrendChartCard> {
  List<FlSpot> _spots = [];
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _prepareChartData();
  }

  @override
  @override
  void didUpdateWidget(WeightTrendChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.targetWeight != widget.targetWeight) {
      _prepareChartData();
    }
  }

  void _prepareChartData() {
    if (widget.data.isEmpty) return;

    _spots = widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final weight = entry.value['weight'] as double;
      return FlSpot(index.toDouble(), weight);
    }).toList();

    final weights = widget.data.map((item) => item['weight'] as double).toList()
      ..add(widget.targetWeight);

    final min = weights.reduce((a, b) => a < b ? a : b);
    final max = weights.reduce((a, b) => a > b ? a : b);

    _minY = min - 1;
    _maxY = max + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

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
                  widget.timeRange,
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
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.dividerColor, strokeWidth: 1);
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: _getBottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 50,
                      getTitlesWidget: _getLeftTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (widget.data.length - 1).toDouble(),
                minY: _minY,
                maxY: _maxY,
                lineBarsData: [
                  // Actual weight line
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentTeaGreen],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withValues(alpha: 0.3),
                          AppTheme.accentTeaGreen.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Target weight line
                  LineChartBarData(
                    spots: [
                      FlSpot(0, widget.targetWeight),
                      FlSpot(
                        (widget.data.length - 1).toDouble(),
                        widget.targetWeight,
                      ),
                    ],
                    isCurved: false,
                    color: AppTheme.warningOrange,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dashArray: [8, 6],
                    dotData: const FlDotData(show: false),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: widget.targetWeight,
                      strokeWidth: 3,
                      dashArray: [8, 6],
                      color: AppTheme.warningOrange,
                      // label: HorizontalLineLabel(
                      //   show: true,
                      //   alignment: Alignment.topRight,
                      //   padding: const EdgeInsets.only(right: 6, bottom: 4),
                      //   style: AppTheme.bodySmall.copyWith(
                      //     color: AppTheme.warningOrange,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // labelResolver: (line) =>
                      //     'Target ${widget.targetWeight.toStringAsFixed(1)} kg',
                      // ),
                    ),
                  ],
                ),

                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppTheme.primaryGreen,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        if (flSpot.barIndex == 0) {
                          final date =
                              widget.data[flSpot.x.toInt()]['date'] as DateTime;
                          return LineTooltipItem(
                            '${_formatDate(date)}\n${flSpot.y.toStringAsFixed(1)} kg',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Legend and Summary
          _buildLegendAndSummary(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Belum ada data berat badan',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Mulai catat berat badan kamu secara rutin untuk melihat tren progress',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= widget.data.length) return Container();

    final date = widget.data[value.toInt()]['date'] as DateTime;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        _formatDateShort(date),
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value.toStringAsFixed(0)}kg',
        style: AppTheme.bodySmall.copyWith(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLegendAndSummary() {
    final firstWeight = widget.data.first['weight'] as double;
    final lastWeight = widget.data.last['weight'] as double;
    final weightChange = lastWeight - firstWeight;

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Berat Aktual', AppTheme.primaryGreen, false),
            const SizedBox(width: AppTheme.spacingL),
            _buildLegendItem('Target', AppTheme.warningOrange, true),
          ],
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Perubahan',
                '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
              Container(width: 1, height: 30, color: AppTheme.dividerColor),
              _buildSummaryItem(
                'Sisa Target',
                '${(lastWeight - widget.targetWeight).toStringAsFixed(1)} kg',
                Icons.flag_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isDashed
              ? CustomPaint(painter: DashedLinePainter(color: color))
              : null,
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
