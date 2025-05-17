class StudySessionModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInMinutes;
  final bool isFocused;

  StudySessionModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationInMinutes,
    required this.isFocused,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationInMinutes: json['durationInMinutes'] as int,
      isFocused: json['isFocused'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'isFocused': isFocused,
    };
  }
}
