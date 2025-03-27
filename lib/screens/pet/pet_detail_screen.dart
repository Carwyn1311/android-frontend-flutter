import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Auth/login_screen.dart';
import '../payment_detail/payment_detail_screen.dart';
import '../payment_detail/shopping_cart_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  Future<void> _addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('shopping_cart') ?? [];

    // Thêm sản phẩm vào giỏ hàng
    cartItems.add(jsonEncode(pet));
    await prefs.setStringList('shopping_cart', cartItems);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sản phẩm đã được thêm vào giỏ hàng!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pet['name'],
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShoppingCartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hình ảnh sản phẩm
          if (pet['images'] != null && pet['images'].isNotEmpty)
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(pet['images'][0]['url']),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 250,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Không có hình ảnh', style: TextStyle(color: Colors.grey)),
              ),
            ),

          // Thông tin sản phẩm
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Giá: ${pet['price']} VND',
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mô tả:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    pet['description'] ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tình trạng: ${pet['status']}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          // Nút Thêm vào giỏ hàng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => _addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'THÊM VÀO GIỎ HÀNG',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Nút Mua Ngay
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('jwt_token');
                String? username = prefs.getString('username'); // Lấy username từ SharedPreferences

                if (token == null) {
                  // Nếu chưa đăng nhập
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bạn cần đăng nhập để thanh toán'),
                      action: SnackBarAction(
                        label: 'Đăng nhập',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  // Nếu đã đăng nhập
                  String phone = prefs.getString('phone') ?? 'Chưa cập nhật';
                  String address = prefs.getString('address') ?? 'Chưa cập nhật';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        productName: pet['name'] ?? 'Tên sản phẩm',
                        price: double.tryParse(pet['price'].toString()) ?? 0.0,
                        userPhone: phone,
                        userAddress: address,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'MUA NGAY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
