class DayData {
  final DateTime date;
  final double? temperature;
  final bool isFuture;

  DayData({
    required this.date,
    this.temperature,
    required this.isFuture,
  });

  bool get hasTemperature => temperature != null;
}
