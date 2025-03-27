import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/config_url.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();

  void sendOtp(BuildContext context) async {
    final username = usernameController.text.trim();

    // Kiểm tra nếu username bị rỗng
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter your username"),
      ));
      return;
    }

    try {
      // Gửi yêu cầu POST tới API
      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}Authenticate/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(username), // Gửi chuỗi trực tiếp
      );

      // Debugging
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Nếu API trả về thành công
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Lấy mã OTP từ API
        final otp = responseBody['otp'];

        // Kiểm tra nếu OTP không bị null hoặc trống
        if (otp != null && otp.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("OTP generated successfully: $otp"),
          ));

          // Chuyển đến màn hình đặt lại mật khẩu
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordScreen(username: username)),
          );
        } else {
          // Nếu OTP là null hoặc trống
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to generate OTP. Please try again."),
          ));
        }
      } else {
        // Xử lý lỗi từ backend
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${responseBody['message'] ?? 'An unexpected error occurred'}"),
        ));
      }
    } catch (e) {
      // Xử lý lỗi khi gửi yêu cầu
      print('Request Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred: $e"),
      ));
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendOtp(context),
              child: Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  ResetPasswordScreen({required this.username});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool _obscurePassword = true;

  void resetPassword(BuildContext context) async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    // Kiểm tra nếu các trường bị trống
    if (otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields"),
      ));
      return;
    }

    // Debug: Log JSON payload
    print({
      'username': widget.username,
      'resetCode': otp,
      'newPassword': newPassword,
    });

    try {
      // Gửi yêu cầu POST tới API
      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}Authenticate/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'resetCode': otp,
          'newPassword': newPassword,
        }),
      );

      // Debugging phản hồi từ backend
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password reset successfully"),
        ));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // Hiển thị lỗi từ backend
        try {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${responseBody['message'] ?? response.body}"),
          ));
        } catch (e) {
          // Xử lý lỗi không xác định
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("An unexpected error occurred"),
          ));
        }
      }
    } catch (e) {
      // Xử lý lỗi khi gửi yêu cầu
      print('Request Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred: $e"),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: "OTP"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "New Password",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => resetPassword(context),
              child: Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
