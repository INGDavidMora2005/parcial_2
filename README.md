# parcial_2 — Accidentes Tuluá + CRUD Establecimientos

Aplicación Flutter que integra dos módulos:

1. **Estadísticas de Accidentes de Tránsito en Tuluá** — consume el dataset público de Datos Abiertos Colombia, procesa los registros con un `Isolate` y visualiza 4 estadísticas con `fl_chart`.
2. **CRUD de Establecimientos** — consume la API REST del sistema de parqueadero, con carga de logo (imagen) mediante `image_picker`.

---

## Flujo GitFlow

```
main
 └── dev
      └── feature/parcial_flutter_final   ← rama de desarrollo
```

- Los commits siguen la convención `feat:`, `fix:`, `docs:`, `refactor:`, etc.
- Se abre un Pull Request `feature → dev` con descripción y evidencias.
- Tras revisión se hace merge a `dev` y luego a `main`.

---

## APIs consumidas

### API 1 — Accidentes de Tránsito Tuluá (Datos Abiertos Colombia)

| Campo | Valor |
|---|---|
| Base URL | `https://www.datos.gov.co/resource/ezt8-5wyj.json` |
| Autenticación | No requiere |
| Endpoint usado | `GET ?$limit=100000` |

**Campos relevantes del JSON:**

| Campo | Descripción |
|---|---|
| `clase_de_accidente` | Tipo de accidente (Choque, Atropello, Volcamiento, Otros) |
| `gravedad_del_accidente` | Severidad (Con muertos / Con heridos / Solo daños) |
| `barrio_hecho` | Barrio donde ocurrió el accidente |
| `dia` | Día de la semana |
| `hora` | Hora del accidente |
| `area` | Zona (urbana/rural) |
| `clase_de_vehiculo` | Tipo de vehículo involucrado |

**Ejemplo de respuesta JSON:**

```json
[
  {
    "clase_de_accidente": "Choque",
    "gravedad_del_accidente": "Con heridos",
    "barrio_hecho": "CENTRO",
    "dia": "Viernes",
    "hora": "14:30",
    "area": "Urbana",
    "clase_de_vehiculo": "Automóvil"
  }
]
```

---

### API 2 — Establecimientos (API Parqueadero)

| Campo | Valor |
|---|---|
| Base URL | `https://parking.visiontic.com.co/api` |
| Documentación | [Swagger](https://parking.visiontic.com.co/api/documentation) |
| Autenticación | No requiere (endpoints públicos usados) |

**Endpoints implementados:**

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/establecimientos` | Listar todos |
| `GET` | `/establecimientos/{id}` | Ver uno |
| `POST` | `/establecimientos` | Crear (`multipart/form-data`) |
| `POST` | `/establecimiento-update/{id}` | Editar (con `_method=PUT`) |
| `DELETE` | `/establecimientos/{id}` | Eliminar |

> La API usa *method spoofing* de Laravel para el update: se envía `POST` con el campo `_method=PUT` en el `form-data`.

**Campos del establecimiento:** `nombre`, `nit`, `direccion`, `telefono`, `logo` (archivo de imagen).

**Ejemplo de respuesta JSON:**

```json
{
  "data": {
    "id": 1,
    "nombre": "Parqueadero Central",
    "nit": "900123456-7",
    "direccion": "Calle 10 # 5-20",
    "telefono": "3001234567",
    "logo": "/storage/logos/logo.jpg"
  }
}
```

---

## Future/async/await vs Isolate

### ¿Cuándo usar `Future` / `async` / `await`?

Se usa para operaciones de I/O asíncronas que no bloquean el hilo principal porque el sistema operativo las maneja externamente (peticiones HTTP, lectura de archivos, base de datos). El hilo de Flutter queda libre mientras espera la respuesta.

**Ejemplos en el proyecto:** todas las llamadas a Dio en `AccidentesService` y `EstablecimientosService`.

### ¿Cuándo usar `Isolate`?

Se usa para tareas **CPU-intensivas** que sí bloquearían el hilo principal si se ejecutaran directamente. Un `Isolate` corre en un hilo separado de Dart con su propio heap, por lo que no compite con el motor de renderizado de Flutter.

**¿Por qué se eligió `Isolate` para las estadísticas?**

El endpoint `?$limit=100000` puede devolver miles de registros. Iterar sobre esa lista, normalizar valores, contar frecuencias y ordenar resultados es computación pura. Si esto se ejecutara en el hilo principal, la interfaz se congelaría (janks de 16 ms o más). Al delegarlo a `Isolate.run()`, el hilo de UI sigue libre y el usuario puede hacer scroll o interactuar mientras se procesan los datos.

```dart
// Llamada en estadisticas_view.dart
final result = await Isolate.run(() => calcularEstadisticas(rawData));
```

**Requisito de versión:** `Isolate.run()` requiere Dart ≥ 2.19 / Flutter 3. Si se usara una versión anterior, la alternativa válida es `compute()` de `flutter/foundation.dart`.

---

## Arquitectura y estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada, carga .env
├── app_router.dart                    # Definición de rutas con go_router
│
├── core/
│   └── constants/
│       └── api_constants.dart         # URLs desde flutter_dotenv
│
├── models/
│   ├── accidente_model.dart           # Modelo de accidente de tránsito
│   └── establecimiento_model.dart     # Modelo de establecimiento + URL de logo
│
├── services/
│   ├── accidentes_service.dart        # GET accidentes (fetchAll, fetchCount)
│   └── establecimientos_service.dart  # CRUD establecimientos con Dio
│
├── isolates/
│   └── accidentes_isolate.dart        # Función pura: calcularEstadisticas()
│
├── views/
│   ├── dashboard/
│   │   └── dashboard_view.dart        # Pantalla principal con resumen y accesos
│   ├── accidentes/
│   │   └── estadisticas_view.dart     # 4 gráficas con fl_chart
│   └── establecimientos/
│       ├── establecimientos_list_view.dart    # Listado con ListView.builder
│       ├── establecimiento_detail_view.dart   # Detalle + botones editar/eliminar
│       └── establecimiento_form_view.dart     # Formulario crear/editar
│
└── widgets/
    └── skeleton_card.dart             # Widget reutilizable con Skeletonizer
```

---

## Paquetes utilizados

| Paquete | Versión | Uso |
|---|---|---|
| `dio` | ^5.4.0 | Consumo de ambas APIs y envío multipart/form-data |
| `go_router` | ^17.0.0 | Navegación declarativa con rutas nombradas |
| `flutter_dotenv` | ^6.0.0 | Variables de entorno (URLs base) desde `.env` |
| `fl_chart` | ^0.68.0 | PieChart y BarChart con datos reales |
| `skeletonizer` | ^2.0.0 | Efecto skeleton mientras carga |
| `image_picker` | ^1.0.7 | Selección de logo desde galería o cámara |

---

## Rutas implementadas con go_router

| Nombre | Path | Descripción | Parámetros |
|---|---|---|---|
| `dashboard` | `/` | Dashboard principal | — |
| `estadisticas` | `/estadisticas` | 4 gráficas de accidentes | — |
| `establecimientos` | `/establecimientos` | Listado de establecimientos | — |
| `establecimiento-create` | `/establecimientos/create` | Formulario de creación | — |
| `establecimiento-detail` | `/establecimientos/:id` | Detalle de un establecimiento | `id` (path) |
| `establecimiento-edit` | `/establecimientos/:id/edit` | Formulario de edición | `id` (path) + `EstablecimientoModel` (extra) |

> Las rutas estáticas (`/create`) se definen **antes** que las dinámicas (`/:id`) para que go_router no las confunda.

**Paso de parámetros entre pantallas:**

```dart
// Navegación con path param
context.go('/establecimientos/${establecimiento.id}');

// Navegación con extra (objeto completo para evitar segunda petición)
context.go('/establecimientos/${widget.id}/edit', extra: _establecimiento);

// Recepción en el router
builder: (context, state) => EstablecimientoFormView(
  id: int.parse(state.pathParameters['id']!),
  establecimiento: state.extra as EstablecimientoModel?,
),
```

---

## Isolate — mensajes en consola

Al procesar los accidentes se imprimen dos líneas en consola:

```
[Isolate] Iniciado — 8542 registros recibidos
[Isolate] Completado en 312 ms
```

La función `calcularEstadisticas` en `lib/isolates/accidentes_isolate.dart` es una **función pura** (no depende de estado externo ni de Flutter), lo que la hace compatible con `Isolate.run()`.

---

## Variables de entorno (`.env`)

```env
ACCIDENTES_BASE_URL=https://www.datos.gov.co/resource/ezt8-5wyj.json
PARQUEADERO_BASE_URL=https://parking.visiontic.com.co/api
```

El archivo `.env` está declarado como asset en `pubspec.yaml` y se carga en `main()` antes de `runApp()`:

```dart
await dotenv.load(fileName: ".env");
```

Las URLs se acceden mediante `ApiConstants`:

```dart
class ApiConstants {
  static String get accidentesBaseUrl => dotenv.env['ACCIDENTES_BASE_URL'] ?? '';
  static String get parqueaderoBaseUrl => dotenv.env['PARQUEADERO_BASE_URL'] ?? '';
}
```

---

## Capturas de pantalla

> *(Insertar capturas del PDF de evidencias aquí)*

| Pantalla | Descripción |
|---|---|
| Dashboard | Resumen con total de accidentes y establecimientos, cards de acceso |
| Estadísticas — Skeleton | Estado de carga con efecto skeleton |
| Estadísticas — PieChart (Clase) | Distribución por clase de accidente |
| Estadísticas — BarChart (Gravedad) | Distribución por gravedad |
| Estadísticas — BarChart (Barrios) | Top 5 barrios con más accidentes |
| Estadísticas — BarChart (Día) | Distribución por día de la semana |
| Establecimientos — Skeleton | Estado de carga con efecto skeleton |
| Establecimientos — Listado | Lista con logo, nombre, NIT, dirección, teléfono |
| Crear establecimiento | Formulario con selector de imagen (galería/cámara) |
| Editar establecimiento | Formulario precargado con datos existentes |
| Detalle establecimiento | Vista completa con logo |
| Eliminar — Confirmación | AlertDialog de confirmación antes de eliminar |

---

## Cómo ejecutar el proyecto

```bash
# Clonar el repositorio
git clone https://github.com/<usuario>/parcial_2.git
cd parcial_2
git checkout feature/parcial_flutter_final

# Instalar dependencias
flutter pub get

# Ejecutar
flutter run
```

> Asegurarse de tener Flutter ≥ 3.0 / Dart ≥ 2.19 para que `Isolate.run()` esté disponible.
> Verificar con: `flutter --version`
