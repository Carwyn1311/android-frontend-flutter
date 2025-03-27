class Pet {
  final String id;
  final String image;
  final String name;

  Pet({
    required this.id,
    required this.name,
    required this.image,
  });
}

final pets = [
  Pet(id: "3", name: "Chim", image: "assets/bird_pet.jpg"),
  Pet(id: "2",name: "Mèo", image: "assets/cat_pet.jpg"),
  Pet(id: "1",name: "Chó", image: "assets/dog_pet.jpg"),
  Pet(id: "4",name: "Cá", image: "assets/fish_pet.jpg"),
  Pet(id: "5",name: "Hamster", image: "assets/hamster_pet.jpg"),
];
