import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_cherry_pet_shop/models/postFacebook.dart';


class EditPostScreen extends StatefulWidget {
  final postFacebook post; // Nhận bài đăng cần chỉnh sửa

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _tenController;
  late TextEditingController _moTaController;
  late TextEditingController _anhDaiDienController;
  late TextEditingController _hinhAnhController;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(text: widget.post.ten);
    _moTaController = TextEditingController(text: widget.post.moTa);
    _anhDaiDienController =
        TextEditingController(text: widget.post.anhDaiDien);
    _hinhAnhController = TextEditingController(text: widget.post.hinhAnh);
  }

  Future<void> _updatePost() async {
    final url =
        'https://foundgreenpen14.conveyor.cloud/api/PostApi/${widget.post.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': widget.post.id,
        'ten': _tenController.text,
        'moTa': _moTaController.text,
        'anhDaiDien': _anhDaiDienController.text,
        'hinhAnh': _hinhAnhController.text,
        'soLuotThich': widget.post.soLuotThich,
        'soLuotBinhLuan': widget.post.soLuotBinhLuan,
        'soLuotChiaSe': widget.post.soLuotChiaSe,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Navigator.pop(context, true); // Quay về màn hình chính
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật bài đăng thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể cập nhật bài đăng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa Bài Đăng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tenController,
              decoration: const InputDecoration(
                labelText: 'Tên người đăng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _moTaController,
              decoration: const InputDecoration(
                labelText: 'Mô tả bài đăng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _anhDaiDienController,
              decoration: const InputDecoration(
                labelText: 'URL Ảnh đại diện',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hinhAnhController,
              decoration: const InputDecoration(
                labelText: 'URL Hình ảnh bài đăng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updatePost,
              icon: const Icon(Icons.save),
              label: const Text('Cập Nhật'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
