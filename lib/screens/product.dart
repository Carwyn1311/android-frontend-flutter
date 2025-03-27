class Product {
  final int productId;
  final String name;
  final double price;
  final String description;
  final int quantity;
  final int supplyCategoryId;
  final SupplyCategory supplyCategory;
  final List<ProductImage> images;

  Product({
    this.productId = 0,
    this.name = '',
    this.price = 0.0,
    this.description = '',
    this.quantity = 0,
    this.supplyCategoryId = 0,
    required this.supplyCategory,
    this.images = const [],
  });

  // Tạo đối tượng từ JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      supplyCategoryId: json['supplyCategoryId'] ?? 0,
      supplyCategory: json['supplyCategory'] != null
          ? SupplyCategory.fromJson(json['supplyCategory'])
          : SupplyCategory(supplyCategoryId: 0, name: ''),
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ProductImage.fromJson(image))
          .toList() ??
          [],
    );
  }

  // Chuyển đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
      'supplyCategoryId': supplyCategoryId,
      'supplyCategory': supplyCategory.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }
}

class SupplyCategory {
  final int supplyCategoryId;
  final String name;

  SupplyCategory({
    this.supplyCategoryId = 0,
    this.name = '',
  });

  factory SupplyCategory.fromJson(Map<String, dynamic> json) {
    return SupplyCategory(
      supplyCategoryId: json['supplyCategoryId'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplyCategoryId': supplyCategoryId,
      'name': name,
    };
  }
}

class ProductImage {
  final int productImageId;
  final int productId;
  final String imageUrl;

  ProductImage({
    this.productImageId = 0,
    this.productId = 0,
    this.imageUrl = '',
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      productImageId: json['productImageId'] ?? 0,
      productId: json['productId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productImageId': productImageId,
      'productId': productId,
      'imageUrl': imageUrl,
    };
  }
}
