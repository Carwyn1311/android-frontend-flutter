import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/core/theme/app_color.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final selectedIndex = ValueNotifier(0);

  final carousels = [
    {
      "image": "assets/ads_01.jpg",
      "text": "Chào mừng đến với App The Cherry PetShop!",
    },
    {
      "image": "assets/ads_02.jpg",
      "text": "Không gian sạch sẽ, ngăn nắp !",
    },
    {
      "image": "assets/ads_03.jpg",
      "text": "Nhân viên thân thiện, hòa đồng .",
    },
    {
      "image": "assets/ads_04.jpg",
      "text": "Mọi thứ bạn cần chúng tôi đều có.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
              viewportFraction: 1,
              disableCenter: true,
              enableInfiniteScroll: true,
              autoPlay: true, // Kích hoạt chế độ tự động chạy
              autoPlayInterval: const Duration(seconds: 3), // Chuyển sau 5 giây
              onPageChanged: (index, reason) {
                selectedIndex.value = index;
              },
            ),
            itemCount: carousels.length,
            itemBuilder: (context, index, realIndex) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: AssetImage(
                      carousels[index]["image"]!,
                    ),
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        carousels[index]["text"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: ValueListenableBuilder(
              valueListenable: selectedIndex,
              builder: (context, selected, child) {
                return Row(
                  children: List.generate(
                    carousels.length,
                        (index) {
                      return Container(
                        height: 10,
                        width: 10,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: selected == index
                              ? AppColor.primaryColor
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
