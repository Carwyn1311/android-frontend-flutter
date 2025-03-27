class Category {
  final String id;
  final String image;
  final String name;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });
}

final categories = [
  Category(id: "1",name: "Đồ ăn cho pet", image: "assets/san-pham-1648734362.png"),
  Category(id: "2",name: "Đồ chơi cho pet", image: "assets/dochoimeo.png"),
  Category(id: "3",name: "Phụ kiện hăm sóc & vệ sinh", image: "assets/dochoicho.png"),
  Category(id: "4",name: "Làm đẹp & sức khỏe", image: "assets/keocatchopet.png"),
  Category(id: "5",name: "Dụng cụ vận chuyển ", image: "assets/chuongcho.png"),
];
