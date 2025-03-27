import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';

class AdminProductList extends StatefulWidget {
  const AdminProductList({Key? key}) : super(key: key);

  @override
  State<AdminProductList> createState() => _AdminProductListState();
}

class _AdminProductListState extends State<AdminProductList> {
  List<dynamic> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}Product'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config_URL.baseUrl}Product/$productId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _products.removeWhere((product) => product['productId'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  Future<void> _addOrEditProduct({Map<String, dynamic>? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditProductScreen(product: product),
      ),
    );
    if (result == true) {
      _fetchProducts();
    }
  }

  Widget _buildImage(String? url) {
    return url != null
        ? Image.network(
      url,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    )
        : _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_cart,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final imageUrl = (product['images'] != null && product['images'].isNotEmpty)
              ? product['images'][0]['imageUrl']
              : null;

          return ListTile(
            leading: _buildImage(imageUrl),
            title: Text(product['name']),
            subtitle: Text(
                'Giá: ${product['price']} VND\nSố lượng: ${product['quantity']}\nDanh mục: ${product['supplyCategory']['name']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () => _addOrEditProduct(product: product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(product['productId']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditProduct(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddOrEditProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddOrEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddOrEditProductScreen> createState() => _AddOrEditProductScreenState();
}

class _AddOrEditProductScreenState extends State<AddOrEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _priceController = TextEditingController(text: widget.product?['price']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?['description'] ?? '');
    _quantityController = TextEditingController(text: widget.product?['quantity']?.toString() ?? '');
    _imageController = TextEditingController(
      text: widget.product?['images']?.isNotEmpty == true
          ? widget.product!['images'][0]['imageUrl']
          : '',
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.product != null;
    final url = isEditing
        ? Uri.parse('${Config_URL.baseUrl}Product/${widget.product!['productId']}')
        : Uri.parse('${Config_URL.baseUrl}Product');

    final productData = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text),
      'description': _descriptionController.text,
      'quantity': int.parse(_quantityController.text),
      'images': [
        {'imageUrl': _imageController.text}
      ],
      'supplyCategoryId': widget.product?['supplyCategoryId'] ?? 0,
    };

    try {
      final response = isEditing
          ? await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      )
          : await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (value) =>
                  value!.isEmpty ? 'Tên không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Giá không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Số lượng không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) =>
                  value!.isEmpty ? 'Mô tả không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: 'URL Ảnh'),
                  validator: (value) =>
                  value!.isEmpty ? 'URL ảnh không được để trống' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.product != null ? 'Cập nhật' : 'Thêm mới'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
