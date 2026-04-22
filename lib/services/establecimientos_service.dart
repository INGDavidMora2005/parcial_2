import 'package:dio/dio.dart';
import 'package:parcial_2/core/constants/api_constants.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

class EstablecimientosService {
  final Dio _dio = Dio();

  Future<List<EstablecimientoModel>> getAll() async {
    try {
      final response =
          await _dio.get('${ApiConstants.parqueaderoBaseUrl}/establecimientos');
      final List data = response.data['data'] ?? response.data;
      return data.map((json) => EstablecimientoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching establecimientos: ${e.message}');
    }
  }

  Future<EstablecimientoModel> getById(int id) async {
    try {
      final response = await _dio
          .get('${ApiConstants.parqueaderoBaseUrl}/establecimientos/$id');
      return EstablecimientoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching establecimiento: ${e.message}');
    }
  }

  Future<EstablecimientoModel> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    required String logoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
        'logo': await MultipartFile.fromFile(logoPath, filename: 'logo.jpg'),
      });
      final response = await _dio.post(
        '${ApiConstants.parqueaderoBaseUrl}/establecimientos',
        data: formData,
      );
      return EstablecimientoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error creating establecimiento: ${e.message}');
    }
  }

  Future<EstablecimientoModel> update({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
        '_method': 'PUT',
      });
      if (logoPath != null) {
        formData.files.add(MapEntry(
          'logo',
          await MultipartFile.fromFile(logoPath, filename: 'logo.jpg'),
        ));
      }
      final response = await _dio.post(
        '${ApiConstants.parqueaderoBaseUrl}/establecimiento-update/$id',
        data: formData,
      );
      return EstablecimientoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error updating establecimiento: ${e.message}');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio
          .delete('${ApiConstants.parqueaderoBaseUrl}/establecimientos/$id');
    } on DioException catch (e) {
      throw Exception('Error deleting establecimiento: ${e.message}');
    }
  }
}
