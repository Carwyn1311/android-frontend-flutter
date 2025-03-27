class PetService {
  final int serviceId;
  final String name;
  final double price;
  final String description;
  final List<ServiceImage> images;

  PetService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });

  factory PetService.fromJson(Map<String, dynamic> json) {
    return PetService(
      serviceId: json['serviceId'] ?? 0,
      name: json['name'] ?? 'Chưa có tên',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      description: json['description'] ?? 'Không có mô tả',
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ServiceImage.fromJson(image))
          .toList() ??
          [],
    );
  }
}

class ServiceImage {
  final String url;

  ServiceImage({required this.url});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      url: json['url'] ?? 'https://via.placeholder.com/150',
    );
  }
}
