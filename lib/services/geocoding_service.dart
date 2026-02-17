import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationModel {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  String get fullLabel => [name, admin1, country].where((e) => e != null).join(', ');

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      country: json['country'],
      admin1: json['admin1'],
    );
  }
}

class GeocodingService {
  Future<List<LocationModel>> searchCities(String query) async {
    if (query.length < 3) return [];

    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=pt&format=json',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] == null) return [];
        
        return List<LocationModel>.from(
          data['results'].map((item) => LocationModel.fromJson(item)),
        );
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching cities: $e');
      return [];
    }
  }
}
