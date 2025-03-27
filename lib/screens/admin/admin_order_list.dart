import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';

class AdminOrderList extends StatefulWidget {
  const AdminOrderList({Key? key}) : super(key: key);

  @override
  _AdminOrderListState createState() => _AdminOrderListState();
}

class _AdminOrderListState extends State<AdminOrderList> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}Order'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List<dynamic>) {
          setState(() {
            _orders = data;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to load orders: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                'Mã đơn hàng: ${order['orderId'] ?? 'N/A'}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày tạo: ${order['orderDate'] ?? 'N/A'}'),
                  Text('Khách hàng: ${order['customerName'] ?? 'N/A'}'),
                  Text('Trạng thái: ${order['status'] ?? 'N/A'}'),
                  Text('Tổng giá: ${order['totalPrice'] ?? 'N/A'} VND'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info, color: Colors.blue),
                onPressed: () {
                  // Thêm xử lý chi tiết đơn hàng tại đây
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
