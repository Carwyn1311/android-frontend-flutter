import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config_url.dart';

class PaymentScreen extends StatefulWidget {
  final String productName;
  final double price;
  final String userPhone;
  final String userAddress;

  const PaymentScreen({
    Key? key,
    required this.productName,
    required this.price,
    required this.userPhone,
    required this.userAddress,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _username; // Username từ SharedPreferences
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _nameController = TextEditingController(text: 'Người mua');
    _phoneController = TextEditingController(text: widget.userPhone);
    _addressController = TextEditingController(text: widget.userAddress);
  }

  // Hàm lấy username từ SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
    });
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin người dùng')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final orderData = {
      "orderId": 0,
      "userId": "12345", // ID người dùng (cần thay bằng ID thực tế nếu có)
      "user": {
        "id": "12345", // ID người dùng
        "userName": _username,
        "normalizedUserName": _username?.toUpperCase(),
        "email": "example@email.com",
        "normalizedEmail": "EXAMPLE@EMAIL.COM",
        "emailConfirmed": true,
        "passwordHash": "hashedpassword",
        "securityStamp": "randomstring",
        "concurrencyStamp": "randomstring",
        "phoneNumber": _phoneController.text,
        "phoneNumberConfirmed": true,
        "twoFactorEnabled": false,
        "lockoutEnd": null,
        "lockoutEnabled": false,
        "accessFailedCount": 0,
        "address": _addressController.text,
        "fullName": _nameController.text,
        "appointments": [],
        "orders": [],
        "passwordResetCode": null,
        "resetCodeExpiration": null,
        "previousPasswordResetCode": null
      },
      "orderDate": DateTime.now().toIso8601String(),
      "totalPrice": widget.price,
      "status": "Pending",
      "orderDetails": [
        {
          "id": 0,
          "orderId": 0,
          "order": null,
          "productType": "Product",
          "productId": 1,
          "petId": 0,
          "quantity": 1,
          "price": widget.price,
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}Order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to place order. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Giá: ${widget.price.toStringAsFixed(0)} VND',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thông tin người mua:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tên tài khoản: $_username',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và Tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_nameController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vui lòng điền đầy đủ thông tin!')),
                      );
                      return;
                    }
                    _placeOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'THANH TOÁN',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
