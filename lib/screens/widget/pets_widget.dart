import 'package:flutter/material.dart';
import '../pet/pet_list_screen.dart';
import '../../models/pet_model.dart';

class PetsWidget extends StatefulWidget {
  const PetsWidget({super.key});

  @override
  State<PetsWidget> createState() => _PetsWidgetState();
}

class _PetsWidgetState extends State<PetsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            "Thú cưng",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 80,
          width: MediaQuery.of(context).size.width,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: pets.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 8);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetListScreen(
                        categoryId: int.parse(pets[index].id),
                        categoryName: pets[index].name,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            pets[index].image,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      pets[index].name,
                      style: Theme.of(context).textTheme.titleSmall,
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
