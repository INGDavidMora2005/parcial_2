import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:parcial_2/services/accidentes_service.dart';
import 'package:parcial_2/isolates/accidentes_isolate.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({super.key});

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  Future<Map<String, dynamic>?>? _estadisticasFuture;

  @override
  void initState() {
    super.initState();
    _estadisticasFuture = _loadEstadisticas();
  }

  Future<Map<String, dynamic>?> _loadEstadisticas() async {
    try {
      final accidentes = await AccidentesService().fetchAll();
      final rawData = accidentes.map((e) => e.toJson()).toList();
      final result = await Isolate.run(() => calcularEstadisticas(rawData));
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Accidentes'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _estadisticasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          } else {
            return _buildSuccessState(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SkeletonCard(height: 250),
        const SizedBox(height: 16),
        SkeletonCard(height: 250),
        const SizedBox(height: 16),
        SkeletonCard(height: 250),
        const SizedBox(height: 16),
        SkeletonCard(height: 250),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64),
          const SizedBox(height: 16),
          const Text('Error al cargar estadísticas'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _estadisticasFuture = _loadEstadisticas();
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(Map<String, dynamic> data) {
    final claseAccidente = data['claseAccidente'] as Map<String, int>;
    final gravedadAccidente = data['gravedadAccidente'] as Map<String, int>;
    final topBarrios = data['topBarrios'] as Map<String, int>;
    final diaSemana = data['diaSemana'] as Map<String, int>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPieChart('Distribución por clase de accidente', claseAccidente),
        const SizedBox(height: 16),
        _buildBarChart('Distribución por gravedad', gravedadAccidente),
        const SizedBox(height: 16),
        _buildBarChart('Top 5 barrios con más accidentes', topBarrios),
        const SizedBox(height: 16),
        _buildBarChart('Distribución por día de la semana', diaSemana),
      ],
    );
  }

  Widget _buildPieChart(String title, Map<String, int> data) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    final sections = data.entries.map((entry) {
      final percentage = (entry.value / total * 100).round();
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: Colors.primaries[
            data.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.entries.map((entry) {
                final color = Colors.primaries[
                    data.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, color: color),
                    const SizedBox(width: 4),
                    Text('${entry.key}: ${entry.value}'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, Map<String, int> data) {
    final barGroups = data.entries.map((entry) {
      return BarChartGroupData(
        x: data.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.indigo,
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.keys.length) {
                            return Text(
                              data.keys.elementAt(index),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
