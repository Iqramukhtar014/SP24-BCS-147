import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _apiKey = '12a00335d26f4ca2cf951624b5c361be';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getWeatherByCity(String city) async {
    final url = Uri.parse(
        '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherModel> getWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<ForecastModel> getForecastByCity(String city) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&cnt=8');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return ForecastModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<List<WeatherModel>> getMultipleCities(List<String> cities) async {
    List<WeatherModel> results = [];
    for (String city in cities) {
      try {
        final weather = await getWeatherByCity(city);
        results.add(weather);
      } catch (_) {}
    }
    return results;
  }

  String getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '⛅';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
