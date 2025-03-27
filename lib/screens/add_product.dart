import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart'; // Import model Product nếu chưa có

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final String apiUrl = 'https://othergreylamp51.conveyor.cloud/api/Product';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          products = (json.decode(response.body) as List)
              .map((product) => Product.fromJson(product))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _addProduct(Product product) async {
    // Chuẩn bị request body dựa trên định dạng mà bạn yêu cầu
    final Map<String, dynamic> requestBody = {
      "productId": 0, // Giữ nguyên 0 nếu thêm sản phẩm mới
      "name": product.name,
      "price": product.price,
      "description": product.description,
      "quantity": product.quantity,
      "supplyCategoryId": product.supplyCategoryId,
      "supplyCategory": {
        "supplyCategoryId": product.supplyCategory.supplyCategoryId,
        "name": product.supplyCategory.name,
      },
      "images": product.images
          .map((image) => {
        "productImageId": image.productImageId,
        "productId": image.productId,
        "imageUrl": image.imageUrl,
      })
          .toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody), // Encode request body
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        await fetchProducts(); // Làm mới danh sách sản phẩm
        return true;
      } else {
        // Xử lý khi không thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add product: ${response.statusCode}\n${response.body}',
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc server không phản hồi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shop'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(
                    onProductAdded: _addProduct,
                  ),
                ),
              );
              if (result == true) {
                fetchProducts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Product Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Thêm logic tìm kiếm ở đây nếu cần
                  },
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Image.network(
                            product.images.isNotEmpty
                                ? product.images.first.imageUrl
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Category: ${product.supplyCategory.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductScreen extends StatelessWidget {
  final Future<bool> Function(Product) onProductAdded;

  const AddProductScreen({Key? key, required this.onProductAdded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logic để nhập thông tin sản phẩm mới
    return Container(); // Hoàn thành giao diện AddProduct nếu cần
  }
}
