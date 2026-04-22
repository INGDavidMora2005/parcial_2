import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/services/accidentes_service.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? accidentesTotal;
  int? establecimientosTotal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final accidentes = await AccidentesService().fetchAll();
      final establecimientos = await EstablecimientosService().getAll();
      setState(() {
        accidentesTotal = accidentes.length;
        establecimientosTotal = establecimientos.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        accidentesTotal = -1; // Indicate error
        establecimientosTotal = -1;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard — Parcial Flutter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: isLoading
                      ? SkeletonCard(height: 100)
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  accidentesTotal == -1
                                      ? 'Error'
                                      : '$accidentesTotal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const Text('Total Accidentes'),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: isLoading
                      ? SkeletonCard(height: 100)
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  establecimientosTotal == -1
                                      ? 'Error'
                                      : '$establecimientosTotal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const Text('Total Establecimientos'),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Módulos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  InkWell(
                    onTap: () => context.go('/estadisticas'),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, size: 48),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estadísticas de Accidentes',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Text(
                                      '4 gráficas con datos en tiempo real'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => context.go('/establecimientos'),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.business, size: 48),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gestión de Establecimientos',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Text(
                                      'CRUD completo con carga de imágenes'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
