import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() =>
      _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  Future<List<EstablecimientoModel>>? _establecimientosFuture;

  @override
  void initState() {
    super.initState();
    _loadEstablecimientos();
  }

  void _loadEstablecimientos() {
    _establecimientosFuture = EstablecimientosService().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Establecimientos'),
      ),
      body: FutureBuilder<List<EstablecimientoModel>>(
        future: _establecimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState();
          } else {
            return _buildSuccessState(snapshot.data!);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/establecimientos/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => SkeletonCard(height: 80),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64),
          const SizedBox(height: 16),
          const Text('Error al cargar establecimientos'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loadEstablecimientos();
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(List<EstablecimientoModel> establecimientos) {
    if (establecimientos.isEmpty) {
      return const Center(
        child: Text('No hay establecimientos'),
      );
    }

    return ListView.builder(
      itemCount: establecimientos.length,
      itemBuilder: (context, index) {
        final establecimiento = establecimientos[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: establecimiento.logo != null
                  ? NetworkImage(establecimiento.logo!)
                  : null,
              child: establecimiento.logo == null
                  ? const Icon(Icons.business)
                  : null,
            ),
            title: Text(establecimiento.nombre ?? ''),
            subtitle: Text(establecimiento.nit ?? ''),
            onTap: () => context.go('/establecimientos/${establecimiento.id}'),
          ),
        );
      },
    );
  }
}
