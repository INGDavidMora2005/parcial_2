import 'package:parcial_2/core/constants/api_constants.dart';

class EstablecimientoModel {
  final int? id;
  final String? nombre;
  final String? nit;
  final String? direccion;
  final String? telefono;
  final String? logo;

  EstablecimientoModel({
    this.id,
    this.nombre,
    this.nit,
    this.direccion,
    this.telefono,
    this.logo,
  });

  factory EstablecimientoModel.fromJson(Map<String, dynamic> json) {
    final logoValue = json['logo'];
    String? logo;
    if (logoValue != null) {
      if (logoValue.startsWith('http')) {
        logo = logoValue;
      } else {
        final base = ApiConstants.parqueaderoBaseUrl.replaceFirst('/api', '');
        final path = logoValue.startsWith('/') ? logoValue : '/$logoValue';
        logo = '$base$path';
      }
    }
    return EstablecimientoModel(
      id: json['id'],
      nombre: json['nombre'],
      nit: json['nit'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      logo: logo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'logo': logo,
    };
  }
}
