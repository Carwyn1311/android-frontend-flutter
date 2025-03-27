class PetItem {
  final int petId;
  final String name;
  final int age;
  final int price;
  final String description;
  final int categoryId;
  final List<String> images;
  final String status;

  PetItem({
    required this.petId,
    required this.name,
    required this.age,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.images,
    required this.status,
  });

  factory PetItem.fromJson(Map<String, dynamic> json) {
    return PetItem(
      petId: json['petId'],
      name: json['name'],
      age: json['age'],
      price: json['price'],
      description: json['description'],
      categoryId: json['categoryId'],
      images: (json['images'] as List<dynamic>).map((e) => e['url'] as String).toList(),
      status: json['status'],
    );
  }
}
