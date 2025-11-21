import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';

// Este widget es reutilizable y se encarga de dibujar el gráfico de historial.
class HistoryChart extends StatelessWidget {
  final List<HistoricalDataPoint> history;

  const HistoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text("No hay datos históricos disponibles."));
    }

    // El gráfico necesita los puntos en orden cronológico (el más antiguo primero)
    final reversedHistory = history.reversed.toList();
    final theme = Theme.of(context);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles:
                SideTitles(showTitles: true, reservedSize: 28, interval: 1),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (reversedHistory.length / 5).ceil().toDouble(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < reversedHistory.length) {
                  final date = reversedHistory[value.toInt()].date;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${date.day}/${date.month}',
                        style: theme.textTheme.bodySmall),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: reversedHistory.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.aqi.toDouble());
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.surface,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.cardColor,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final date = reversedHistory[flSpot.x.toInt()].date;
                return LineTooltipItem(
                  '${date.day}/${date.month}\n',
                  theme.textTheme.bodySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'AQI: ${flSpot.y.toInt()}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        minY: 0,
        maxY: 6,
      ),
    );
  }
}
