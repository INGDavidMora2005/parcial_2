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
    return EstablecimientoModel(
      id: json['id'],
      nombre: json['nombre'],
      nit: json['nit'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      logo: json['logo'],
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
