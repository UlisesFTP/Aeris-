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
        gridData: const FlGridData(show: false),
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
              interval: (reversedHistory.length / 5)
                  .ceil()
                  .toDouble(), // Muestra unas 5 etiquetas
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
        borderData: FlBorderData(
            show: true, border: Border.all(color: theme.dividerColor)),
        lineBarsData: [
          LineChartBarData(
            spots: reversedHistory.asMap().entries.map((entry) {
              // El eje X es el índice y el eje Y es el valor de AQI
              return FlSpot(entry.key.toDouble(), entry.value.aqi.toDouble());
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.secondary.withOpacity(0.3),
            ),
          ),
        ],
        minY: 0, // El AQI no puede ser menor que 0
        maxY: 6, // El AQI máximo es 5, damos un poco de margen
      ),
    );
  }
}
