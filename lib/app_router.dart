import 'package:go_router/go_router.dart';
import 'package:parcial_2/views/dashboard/dashboard_view.dart';
import 'package:parcial_2/views/accidentes/estadisticas_view.dart';
import 'package:parcial_2/views/establecimientos/establecimientos_list_view.dart';
import 'package:parcial_2/views/establecimientos/establecimiento_detail_view.dart';
import 'package:parcial_2/views/establecimientos/establecimiento_form_view.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        name: 'dashboard',
        path: '/',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        name: 'estadisticas',
        path: '/estadisticas',
        builder: (context, state) => const EstadisticasView(),
      ),
      GoRoute(
        name: 'establecimientos',
        path: '/establecimientos',
        builder: (context, state) => const EstablecimientosListView(),
      ),
      GoRoute(
        name: 'establecimiento-detail',
        path: '/establecimientos/:id',
        builder: (context, state) => EstablecimientoDetailView(
          id: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        name: 'establecimiento-create',
        path: '/establecimientos/create',
        builder: (context, state) => const EstablecimientoFormView(
          id: null,
          establecimiento: null,
        ),
      ),
      GoRoute(
        name: 'establecimiento-edit',
        path: '/establecimientos/:id/edit',
        builder: (context, state) => EstablecimientoFormView(
          id: int.parse(state.pathParameters['id']!),
          establecimiento: state.extra as EstablecimientoModel?,
        ),
      ),
    ],
  );
}
