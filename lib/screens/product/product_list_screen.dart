import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';
import '../../models/product_model.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int supplyCategoryId;
  final String categoryName;

  const ProductListScreen({
    Key? key,
    required this.supplyCategoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = _fetchProductsByCategory(widget.supplyCategoryId);
  }

  Future<List<Product>> _fetchProductsByCategory(int supplyCategoryId) async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}Product'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Fetched products: $data"); // Log dữ liệu
        return data
            .map((json) => Product.fromJson(json))
            .where((product) =>
        product.supplyCategory.supplyCategoryId == supplyCategoryId)
            .toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("Error loading products: $e");
      throw Exception('Failed to load products: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách ${widget.categoryName}')),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load products: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: product.images.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images[0].imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                      : _buildPlaceholder(),
                  title: Text(
                    '${index + 1}. ${product.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Giá: ${product.price} VND\nSố lượng: ${product.quantity}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No products found'));
          }
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.white),
    );
  }
}
