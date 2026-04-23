import 'package:dio/dio.dart';
import 'package:parcial_2/core/constants/api_constants.dart';
import 'package:parcial_2/models/accidente_model.dart';

class AccidentesService {
  final Dio _dio = Dio();

  Future<List<AccidenteModel>> fetchAll() async {
    try {
      final response = await _dio.get(
        ApiConstants.accidentesBaseUrl,
        queryParameters: {'\$limit': '100000'},
      );
      final List data = response.data;
      return data.map((json) => AccidenteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching accidentes: ${e.message}');
    }
  }

  Future<int> fetchCount() async {
    try {
      final response = await _dio.get(
        ApiConstants.accidentesBaseUrl,
        queryParameters: {'\$select': 'count(*)', '\$limit': '1'},
      );
      final List data = response.data;
      if (data.isNotEmpty) {
        return int.tryParse(data[0]['count'].toString()) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception('Error fetching count: ${e.message}');
    }
  }
}
