import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_cherry_pet_shop/models/user_model.dart';
import 'Auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoggedIn = false; // Trạng thái đăng nhập
  UserModel? userModel; // Model lưu thông tin người dùng
  String? _username; // Username từ SharedPreferences

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUsername();
  }

  // Kiểm tra trạng thái đăng nhập
  void _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_info');

    if (userData != null) {
      setState(() {
        isLoggedIn = true;
        userModel = UserModel.fromJson(json.decode(userData));
      });
    } else {
      setState(() {
        isLoggedIn = false;
        userModel = null; // Reset thông tin user về null
      });
    }
  }

  // Lấy username từ SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      userModel = null;
      // Chưa đăng nhập
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(40.0), // Thêm 40px padding toàn bộ
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                // Chuyển đến màn hình đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ).then((_) {
                  _checkLoginStatus(); // Kiểm tra lại trạng thái sau khi đăng nhập
                  _loadUsername(); // Lấy lại username
                });
              },
              child: const Text('Đăng nhập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ),
        ),
      );
    }

    // Đã đăng nhập và có dữ liệu user
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0), // Thêm 40px padding toàn bộ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Khung màu xanh thay cho hình đại diện
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị thông tin username từ SharedPreferences
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.blueAccent),
              title: const Text('Tên tài khoản'),
              subtitle: Text(_username ?? 'Không có thông tin'),
            ),

            // Hiển thị thông tin role từ UserModel
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
              title: const Text('Vai trò'),
              subtitle: Text(userModel?.role ?? 'Không xác định'),
            ),
          ],
        ),
      ),
    );
  }
}
