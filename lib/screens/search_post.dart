import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_cherry_pet_shop/config/config_url.dart';
import '../models/postFacebook.dart';

class SearchPostScreen extends StatefulWidget {
  final String searchId;
  final Future<void> Function() fetchPosts;

  const SearchPostScreen({super.key, required this.searchId, required this.fetchPosts});

  @override
  _SearchPostScreenState createState() => _SearchPostScreenState();
}

class _SearchPostScreenState extends State<SearchPostScreen> {
  List<postFacebook> posts = [];
  bool isLoading = true;
  final String apiUrl = '${Config_URL.baseUrl}/PostApi'; // URL API của bạn

  @override
  void initState() {
    super.initState();
    fetchPostsById(widget.searchId); // Tìm kiếm bài viết theo ID
  }

  // Phương thức tìm kiếm bài viết theo ID
  Future<void> fetchPostsById(String searchId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$searchId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra kiểu dữ liệu và xử lý phù hợp
        if (data is List) {
          // Nếu trả về một danh sách
          setState(() {
            posts = data.map((post) => postFacebook.fromJson(post as Map<String, dynamic>)).toList();
            isLoading = false;
          });
        } else if (data is Map) {
          // Nếu trả về một bài viết duy nhất
          setState(() {
            posts = [postFacebook.fromJson(data as Map<String, dynamic>)];
            isLoading = false;
          });
        } else {
          setState(() {
            posts = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          posts = [];
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        posts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('No posts found'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: post.anhDaiDien.isNotEmpty
                            ? NetworkImage(post.anhDaiDien)
                            : null, // Không hiển thị ảnh gì nếu không có anhDaiDien
                        backgroundColor: Colors.grey[200], // Thêm nền nhạt nếu không có ảnh đại diện
                      ),
                      const SizedBox(width: 10),
                      Text(
                        post.ten,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    post.moTa,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  post.hinhAnh.isNotEmpty
                      ? Image.network(post.hinhAnh) // Hiển thị hình ảnh bài viết
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Likes', post.soLuotThich),
                      _buildStatColumn('Comments', post.soLuotBinhLuan),
                      _buildStatColumn('Shares', post.soLuotChiaSe),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Phương thức hiển thị các số liệu như Like, Comment, Share
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
