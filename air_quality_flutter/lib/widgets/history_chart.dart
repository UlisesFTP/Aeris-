import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';

// AQI color palette (international standard)
const List<Color> _kAqiColors = [
  Color(0xFF4CAF50), // 1 Good        – green
  Color(0xFF8BC34A), // 2 Fair        – light green
  Color(0xFFFFEB3B), // 3 Moderate    – yellow
  Color(0xFFFF9800), // 4 Poor        – orange
  Color(0xFFE53935), // 5 Very Poor   – red
  Color(0xFF6A1B9A), // 6 Dangerous   – purple
];

const List<String> _kAqiLabels = [
  'Bueno',
  'Aceptable',
  'Moderado',
  'Malo',
  'Muy malo',
  'Peligroso',
];

class HistoryChart extends StatefulWidget {
  final List<HistoricalDataPoint> history;
  const HistoryChart({super.key, required this.history});

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin datos históricos todavía',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      );
    }

    // Chronological order (oldest first)
    final sorted = widget.history.reversed.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, _) {
        return Column(
          children: [
            // ── Bar chart ──────────────────────────────────────────────────
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 6.5,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.spot != null &&
                            event is! FlPointerExitEvent) {
                          _touchedIndex =
                              response!.spot!.touchedBarGroupIndex;
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      tooltipRoundedRadius: 10,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final point = sorted[groupIndex];
                        final aqiIdx = (point.aqi - 1).clamp(0, 5);
                        return BarTooltipItem(
                          '${point.date.day}/${point.date.month}\n',
                          TextStyle(
                            fontSize: 11,
                            color: onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: _kAqiLabels[aqiIdx],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kAqiColors[aqiIdx],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final labels = {
                            1.0: 'Bien',
                            3.0: 'Mod',
                            5.0: 'Mal',
                          };
                          final label = labels[value];
                          if (label == null) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= sorted.length) {
                            return const SizedBox.shrink();
                          }
                          final date = sorted[idx].date;
                          // Show every other label if too crowded
                          if (sorted.length > 10 && idx % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      final isKeyLevel = [1.0, 3.0, 5.0].contains(value);
                      return FlLine(
                        color: onSurface.withValues(
                            alpha: isKeyLevel ? 0.12 : 0.05),
                        strokeWidth: isKeyLevel ? 1.0 : 0.5,
                        dashArray: isKeyLevel ? null : [4, 4],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: sorted.asMap().entries.map((entry) {
                    final i = entry.key;
                    final point = entry.value;
                    final aqiIdx = (point.aqi - 1).clamp(0, 5);
                    final color = _kAqiColors[aqiIdx];
                    final isTouched = i == _touchedIndex;
                    final barHeight = point.aqi.toDouble() * _scaleAnim.value;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: barHeight,
                          width: isTouched ? 14 : 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          color: isTouched
                              ? color
                              : color.withValues(alpha: 0.85),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 6,
                            color: isDark
                                ? const Color(0xFF252525)
                                : const Color(0xFFF5F5F5),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── AQI legend row (compact) ───────────────────────────────────
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _kAqiColors[i],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _kAqiLabels[i],
                          style: TextStyle(
                            fontSize: 9,
                            color: onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
