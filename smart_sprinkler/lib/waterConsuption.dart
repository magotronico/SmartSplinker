import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterConsumptionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data points
    final List<FlSpot> spots = [
      FlSpot(1, 45.45),
      FlSpot(5, 66.66),
      FlSpot(9, 76.54),
      FlSpot(10, 68.97),
      FlSpot(11, 55.32),
      FlSpot(12, 92.12),
      FlSpot(13, 78.45),
      FlSpot(14, 64.29),
      FlSpot(15, 80.85),
      FlSpot(16, 90.0),
      FlSpot(22, 44.44),
      FlSpot(24, 44.44),
      FlSpot(25, 80.44),
      FlSpot(28, 75.89),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  String formattedDate = DateFormat('MMM d')
                      .format(DateTime(2023, 11, barSpot.x.toInt()));
                  return LineTooltipItem(
                    '$formattedDate\n${barSpot.y.toStringAsFixed(2)} Lts',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 15, // For "Días del mes"
              getTitles: (value) {
                switch (value.toInt()) {
                  case 1:
                  case 8:
                  case 15:
                  case 22:
                  case 29:
                    return value.toInt().toString();
                  default:
                    return '';
                }
              },
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                return [0, 20, 40, 60, 80, 100].contains(value.toInt())
                    ? '${value.toInt()} Lts'
                    : '';
              },
              reservedSize:
                  45, // Increase this value if the labels are collapsing
              margin: 12, // You can also adjust the margin if necessary
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 1,
          maxX: 30,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots, // Here we are using the spots list
              isCurved: true,
              colors: [Theme.of(context).primaryColor],
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          axisTitleData: FlAxisTitleData(
            leftTitle: AxisTitle(
              showTitle: true,
              titleText: 'Agua consumida (Lts.)',
              margin: 10,
            ),
            bottomTitle: AxisTitle(
              showTitle: true,
              margin: 10,
              titleText: 'Día del Mes',
            ),
          ),
        ),
      ),
    );
  }
}
