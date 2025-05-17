class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String location; // Untuk dilempar ke Google Maps
  final bool hasAlarm;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.hasAlarm,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      hasAlarm: json['hasAlarm'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'hasAlarm': hasAlarm,
    };
  }
}
