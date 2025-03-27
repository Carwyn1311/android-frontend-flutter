import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart'; // Thư viện jwt_decoder
import '../services/api_client.dart';
import '../services/auth_service.dart';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  // Phương thức để giải mã token
  static Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token); // Giải mã token và trả về Map
    } catch (e) {
      return {}; // Trả về Map rỗng nếu có lỗi
    }
  }

  // Đăng nhập
  static Future<Map<String, dynamic>> login(String username, String password) async {
    var result = await _authService.login(username, password);
    return result; // returns a map with {success: bool, token: string?, role: string?, message: string?}
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String initials,
    required String role,
    required String address,
    required String phoneNumber,
    required String fullName,
  }) async {
    // Tạo body để gửi lên API
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "initials": initials,
      "role": role,
      "address": address,
      "phoneNumber": phoneNumber,
      "fullName": fullName,
    };

    try {
      // Gọi API đăng ký thông qua ApiClient
      var response = await _apiClient.post('Authenticate/register', body: body);

      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại, vui lòng thử lại.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

}
