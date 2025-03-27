class Product {
  final int productId;
  final String name;
  final double price; // Hỗ trợ cả double và int
  final String description;
  final int quantity;
  final SupplyCategory supplyCategory;
  final List<ProductImage> images;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.quantity,
    required this.supplyCategory,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0), // Đảm bảo hỗ trợ cả int và double
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      supplyCategory: SupplyCategory.fromJson(json['supplyCategory'] ?? {}),
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ProductImage.fromJson(image))
          .toList() ??
          [],
    );
  }
}

class SupplyCategory {
  final int supplyCategoryId;
  final String name;

  SupplyCategory({
    required this.supplyCategoryId,
    required this.name,
  });

  factory SupplyCategory.fromJson(Map<String, dynamic> json) {
    return SupplyCategory(
      supplyCategoryId: json['supplyCategoryId'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ProductImage {
  final int productImageId;
  final String imageUrl;

  ProductImage({
    required this.productImageId,
    required this.imageUrl,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      productImageId: json['productImageId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
