class ChartDataModel {
  final DateTime date;
  final double volume;

  ChartDataModel({required this.date, required this.volume});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      date: DateTime.parse(json['day'].toString()),
      volume: (json['daily_volume'] ?? 0).toDouble(),
    );
  }
}
