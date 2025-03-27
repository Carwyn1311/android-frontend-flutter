import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({Key? key}) : super(key: key);

  @override
  _AdminUserListState createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}Authenticate/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Kiểm tra nếu API trả về object có key `users`
        if (data is Map<String, dynamic> && data.containsKey('users')) {
          setState(() {
            _users = data['users']; // Gán danh sách từ key `users`
            _isLoading = false;
          });
        } else if (data is List<dynamic>) {
          // Nếu API trả về một danh sách trực tiếp
          setState(() {
            _users = data;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final roles = user['roles'] != null ? (user['roles'] as List).join(', ') : 'Unknown';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                user['username'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user['email'] ?? 'N/A'}'),
                  Text('Họ và tên: ${user['fullName'] ?? 'N/A'}'),
                  Text('Địa chỉ: ${user['address'] ?? 'N/A'}'),
                  Text('Số điện thoại: ${user['phoneNumber'] ?? 'N/A'}'),
                  Text('Vai trò: $roles'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
