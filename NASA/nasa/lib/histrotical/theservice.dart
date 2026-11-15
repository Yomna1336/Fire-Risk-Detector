import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model.dart';

class HistoricalServer {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<HistoricalResponse> fetchHistoricalInformation({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/historical-information',
    ).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius_km': '5',
        'days_back': '365',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return HistoricalResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed to load historical information: ${response.statusCode}',
      );
    }
  }
}