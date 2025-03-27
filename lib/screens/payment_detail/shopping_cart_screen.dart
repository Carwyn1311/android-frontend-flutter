import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'payment_detail_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('shopping_cart') ?? [];
    setState(() {
      _cartItems = cartItems
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _updateCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems =
    _cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('shopping_cart', cartItems);
  }

  Future<void> _clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('shopping_cart');
    setState(() {
      _cartItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Giỏ hàng đã được xóa!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  double _calculateTotalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * (item['quantity'] ?? 1));
    });
  }

  Future<Map<String, String>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username') ?? 'guest_user',
      'name': prefs.getString('name') ?? 'Người dùng',
      'phone': prefs.getString('phone') ?? 'Chưa cập nhật',
      'address': prefs.getString('address') ?? 'Chưa cập nhật',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
        backgroundColor: Colors.blue,
      ),
      body: _cartItems.isEmpty
          ? const Center(
        child: Text(
          'Giỏ hàng của bạn đang trống!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                      'Giá: ${item['price']} VND\nSố lượng: ${item['quantity'] ?? 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) {
                              item['quantity']--;
                              _updateCart();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            item['quantity'] =
                                (item['quantity'] ?? 1) + 1;
                            _updateCart();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Tổng tiền: ${_calculateTotalPrice().toStringAsFixed(0)} VND',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Lấy thông tin người dùng
                    Map<String, String> userInfo = await _getUserInfo();

                    // Chuyển hướng đến trang thanh toán
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          productName: 'Giỏ hàng', // Tên chung cho giỏ hàng
                          price: _calculateTotalPrice(),
                          userPhone: userInfo['phone']!,
                          userAddress: userInfo['address']!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'THANH TOÁN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'XÓA GIỎ HÀNG',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
