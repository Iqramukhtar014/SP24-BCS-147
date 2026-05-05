class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final String iconCode;

  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
    );
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class ForecastModel {
  final List<ForecastItem> items;

  ForecastModel({required this.items});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    return ForecastModel(
      items: list.map((e) => ForecastItem.fromJson(e)).toList(),
    );
  }
}
