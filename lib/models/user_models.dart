class UserModel {
  final String username;

  UserModel({required this.username});

  // Konversi dari Map (misal dari shared_preferences)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(username: json['username'] as String);
  }

  // Konversi ke Map (untuk disimpan ke shared_preferences)
  Map<String, dynamic> toJson() {
    return {'username': username};
  }
}
