class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  // Thêm trường tĩnh để lưu trữ người dùng hiện tại
  static UserModel? currentUser;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['userName'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': username,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }

  // Phương thức kiểm tra người dùng có phải Admin không
  bool get isAdmin => role == 'Admin';

  // Phương thức để đặt người dùng hiện tại
  static void setCurrentUser(UserModel user) {
    currentUser = user;
  }

  // Phương thức để reset người dùng hiện tại về null
  static void resetCurrentUser() {
    currentUser = null;
  }
}
