Map<String, dynamic> calcularEstadisticas(List<Map<String, dynamic>> rawList) {
  // ignore: avoid_print
  print('[Isolate] Iniciado — ${rawList.length} registros recibidos');
  final start = DateTime.now();

  final Map<String, int> claseAccidente = {};
  final Map<String, int> gravedadAccidente = {};
  final Map<String, int> topBarrios = {};
  final Map<String, int> diaSemana = {};

  for (final item in rawList) {
    // claseAccidente
    final clase = item['clase_de_accidente'];
    if (clase != null) {
      final normalized = ['Choque', 'Atropello', 'Volcamiento'].contains(clase)
          ? clase
          : 'Otros';
      claseAccidente[normalized] = (claseAccidente[normalized] ?? 0) + 1;
    }

    // gravedadAccidente
    final gravedad = item['gravedad_del_accidente'];
    if (gravedad != null) {
      String normalized;
      if (gravedad.toLowerCase().contains('muerto')) {
        normalized = 'Con muertos';
      } else if (gravedad.toLowerCase().contains('herido')) {
        normalized = 'Con heridos';
      } else {
        normalized = 'Solo daños';
      }
      gravedadAccidente[normalized] = (gravedadAccidente[normalized] ?? 0) + 1;
    }

    // topBarrios
    final barrio = item['barrio_hecho'];
    if (barrio != null) {
      topBarrios[barrio] = (topBarrios[barrio] ?? 0) + 1;
    }

    // diaSemana
    final dia = item['dia'];
    if (dia != null) {
      diaSemana[dia] = (diaSemana[dia] ?? 0) + 1;
    }
  }

  // Sort topBarrios descending and take top 5
  final sortedBarrios = topBarrios.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final Map<String, int> top5Barrios = {};
  for (int i = 0; i < sortedBarrios.length && i < 5; i++) {
    top5Barrios[sortedBarrios[i].key] = sortedBarrios[i].value;
  }

  // Sort diaSemana by order: Lunes, Martes, Miércoles, Jueves, Viernes, Sábado, Domingo
  const order = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  final Map<String, int> orderedDiaSemana = {};
  for (final day in order) {
    if (diaSemana.containsKey(day)) {
      orderedDiaSemana[day] = diaSemana[day]!;
    }
  }

  final elapsed = DateTime.now().difference(start).inMilliseconds;
  // ignore: avoid_print
  print('[Isolate] Completado en $elapsed ms');

  return {
    'claseAccidente': claseAccidente,
    'gravedadAccidente': gravedadAccidente,
    'topBarrios': top5Barrios,
    'diaSemana': orderedDiaSemana,
  };
}
