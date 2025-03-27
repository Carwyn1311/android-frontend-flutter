import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:the_cherry_pet_shop/screens/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  bool isLoading = false; // Trạng thái tải

  final String baseUrl = 'https://foundgreenpen14.conveyor.cloud/api/ProductApi'; // API URL

  @override
  void initState() {
    super.initState();
    // Khởi tạo TextEditingControllers với giá trị mặc định từ Product
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageController = TextEditingController(
      text: widget.product.images.isNotEmpty ? widget.product.images[0].imageUrl : '',
    );
  }

  // Kiểm tra dữ liệu nhập hợp lệ
  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return false;
    }

    if (double.tryParse(_priceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price!')),
      );
      return false;
    }
    return true;
  }

  // Hàm cập nhật sản phẩm
  Future<void> editProduct() async {
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true; // Bắt đầu tải
    });

    final updatedProduct = {
      "productId": widget.product.productId,
      "name": _nameController.text,
      "description": _descriptionController.text,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "quantity": widget.product.quantity,
      "supplyCategoryId": widget.product.supplyCategoryId,
      "supplyCategory": {
        "supplyCategoryId": widget.product.supplyCategory.supplyCategoryId,
        "name": widget.product.supplyCategory.name,
      },
      "images": [
        {
          "productImageId": widget.product.images.isNotEmpty
              ? widget.product.images[0].productImageId
              : 0,
          "productId": widget.product.productId,
          "imageUrl": _imageController.text,
        }
      ],
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${widget.product.productId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProduct),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context, true); // Quay lại với kết quả thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update product: ${response.statusCode}\n${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Kết thúc tải
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),

            // Input Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),

            // Input Price
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            // Input Image URL
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),

            // Update Button or Loading Indicator
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: editProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Update Product',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
