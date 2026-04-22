import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EstablecimientoDetailView extends StatefulWidget {
  final int id;

  const EstablecimientoDetailView({super.key, required this.id});

  @override
  State<EstablecimientoDetailView> createState() =>
      _EstablecimientoDetailViewState();
}

class _EstablecimientoDetailViewState extends State<EstablecimientoDetailView> {
  EstablecimientoModel? _establecimiento;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEstablecimiento();
  }

  Future<void> _loadEstablecimiento() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final establecimiento =
          await EstablecimientosService().getById(widget.id);
      setState(() {
        _establecimiento = establecimiento;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEstablecimiento() async {
    try {
      await EstablecimientosService().delete(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Establecimiento eliminado')),
        );
        context.go('/establecimientos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/establecimientos'),
        ),
        title: const Text('Detalle Establecimiento'),
        actions: [
          IconButton(
            onPressed: _establecimiento == null
                ? null
                : () => context.go('/establecimientos/${widget.id}/edit',
                    extra: _establecimiento),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _establecimiento == null ? null : _showDeleteDialog,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _isLoading
          ? Skeletonizer(
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: CircleAvatar(radius: 64)),
                    const SizedBox(height: 24),
                    const Text('Nombre del establecimiento largo'),
                    const SizedBox(height: 8),
                    const Text('NIT: 000000000'),
                    const SizedBox(height: 8),
                    const Text('Dirección: Calle ejemplo 123'),
                    const SizedBox(height: 8),
                    const Text('Teléfono: 3001234567'),
                  ],
                ),
              ),
            )
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _establecimiento == null
                  ? const Center(child: Text('Establecimiento no encontrado'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 64,
                              backgroundImage: _establecimiento!.logo != null
                                  ? NetworkImage(_establecimiento!.logo!)
                                  : null,
                              child: _establecimiento!.logo == null
                                  ? const Icon(Icons.business, size: 64)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('Nombre: ${_establecimiento!.nombre ?? ''}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('NIT: ${_establecimiento!.nit ?? ''}'),
                          const SizedBox(height: 8),
                          Text(
                              'Dirección: ${_establecimiento!.direccion ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Teléfono: ${_establecimiento!.telefono ?? ''}'),
                        ],
                      ),
                    ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Establecimiento'),
        content: const Text('¿Está seguro de eliminar este establecimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEstablecimiento();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
