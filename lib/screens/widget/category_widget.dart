import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../product/product_list_screen.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            "Danh mục sản phẩm dành cho thú cưng",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 90,
          width: MediaQuery.of(context).size.width,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(
                        supplyCategoryId: int.parse(categories[index].id),
                        categoryName: categories[index].name,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 68,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(categories[index].image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        categories[index].name,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
