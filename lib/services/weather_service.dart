import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, double>> fetchTemperatureData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$latitude&longitude=$longitude'
        '&daily=temperature_2m_max&timezone=America/Sao_Paulo'
        '&start_date=2026-01-01&end_date=$todayStr',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout: A conexão demorou muito. Verifique sua internet.');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dates = List<String>.from(data['daily']['time']);
        final temps = List<dynamic>.from(data['daily']['temperature_2m_max']);

        final Map<String, double> temperatureMap = {};
        for (int i = 0; i < dates.length; i++) {
          if (temps[i] != null) {
            temperatureMap[dates[i]] = temps[i].toDouble();
          }
        }

        return temperatureMap;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return {};
    }
  }
}
