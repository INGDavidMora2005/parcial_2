import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

class EstablecimientoFormView extends StatefulWidget {
  final int? id;
  final EstablecimientoModel? establecimiento;

  const EstablecimientoFormView({
    super.key,
    this.id,
    this.establecimiento,
  });

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _nitController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.establecimiento != null) {
      _nombreController.text = widget.establecimiento!.nombre ?? '';
      _nitController.text = widget.establecimiento!.nit ?? '';
      _direccionController.text = widget.establecimiento!.direccion ?? '';
      _telefonoController.text = widget.establecimiento!.telefono ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nitController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isCreate = widget.id == null;
    if (isCreate && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una imagen')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (isCreate) {
        await EstablecimientosService().create(
          nombre: _nombreController.text,
          nit: _nitController.text,
          direccion: _direccionController.text,
          telefono: _telefonoController.text,
          logoPath: _selectedImage!.path,
        );
      } else {
        await EstablecimientosService().update(
          id: widget.id!,
          nombre: _nombreController.text,
          nit: _nitController.text,
          direccion: _direccionController.text,
          telefono: _telefonoController.text,
          logoPath: _selectedImage?.path,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isCreate
                  ? 'Establecimiento creado'
                  : 'Establecimiento actualizado')),
        );
        context.go(
            isCreate ? '/establecimientos' : '/establecimientos/${widget.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.id == null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isCreate ? 'Crear Establecimiento' : 'Editar Establecimiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (widget.establecimiento?.logo != null &&
                                  _selectedImage == null)
                              ? NetworkImage(widget.establecimiento!.logo!)
                              : null,
                      child: (_selectedImage == null &&
                              widget.establecimiento?.logo == null)
                          ? const Icon(Icons.business, size: 64)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nitController,
                decoration: const InputDecoration(labelText: 'NIT'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 32),

              // Submit button
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(isCreate ? 'Crear' : 'Actualizar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
