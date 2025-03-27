import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_cherry_pet_shop/screens/product.dart';

class ProductService {
  final String baseUrl = "https://your-api-endpoint.com/api/products"; // Thay bằng URL API của bạn

  // Lấy danh sách sản phẩm
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // Thêm sản phẩm mới
  Future<bool> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 201; // Trả về true nếu thêm thành công
    } catch (e) {
      throw Exception("Error adding product: $e");
    }
  }

  // Sửa sản phẩm
  Future<bool> editProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/${product.productId}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200; // Trả về true nếu sửa thành công
    } catch (e) {
      throw Exception("Error editing product: $e");
    }
  }

  // Xóa sản phẩm
  Future<bool> deleteProduct(int productId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$productId"));

      return response.statusCode == 204; // Trả về true nếu xóa thành công
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }
}
