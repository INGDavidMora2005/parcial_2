class AccidenteModel {
  final String? claseDeAccidente;
  final String? gravedadDelAccidente;
  final String? barrioHecho;
  final String? dia;
  final String? hora;
  final String? area;
  final String? claseDeVehiculo;

  AccidenteModel({
    this.claseDeAccidente,
    this.gravedadDelAccidente,
    this.barrioHecho,
    this.dia,
    this.hora,
    this.area,
    this.claseDeVehiculo,
  });

  factory AccidenteModel.fromJson(Map<String, dynamic> json) {
    return AccidenteModel(
      claseDeAccidente: json['clase_de_accidente'],
      gravedadDelAccidente: json['gravedad_del_accidente'],
      barrioHecho: json['barrio_hecho'],
      dia: json['dia'],
      hora: json['hora'],
      area: json['area'],
      claseDeVehiculo: json['clase_de_vehiculo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clase_de_accidente': claseDeAccidente,
      'gravedad_del_accidente': gravedadDelAccidente,
      'barrio_hecho': barrioHecho,
      'dia': dia,
      'hora': hora,
      'area': area,
      'clase_de_vehiculo': claseDeVehiculo,
    };
  }
}
