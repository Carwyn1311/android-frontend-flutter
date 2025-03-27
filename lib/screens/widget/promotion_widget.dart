import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PromotionWidget extends StatefulWidget {
  const PromotionWidget({super.key});

  @override
  State<PromotionWidget> createState() => _PromotionWidgetState();
}

class _PromotionWidgetState extends State<PromotionWidget> {
  final ads = [
    {
      "image": "assets/ads_001.jpg",
      "text": "Ưu đãi giảm giá 20% toàn bộ dịch vụ !",
    },
    {
      "image": "assets/ads_002.jpg",
      "text": "Mua 1 tặng 1 cho các sản phẩm thú cưng.",
    },
    {
      "image": "assets/ads_003.jpg",
      "text": "Miễn phí vận chuyển thú cưng !",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            "Chương trình khuyến mãi",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 200, // Đủ chiều cao cho cả hình và chữ
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              viewportFraction: 1,
              disableCenter: true,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
            itemCount: ads.length,
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image(
                        image: AssetImage(
                          ads[index]["image"]!,
                        ),
                        fit: BoxFit.fill,
                        height: 140, // Chiều cao cho hình ảnh
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 4), // Khoảng cách nhỏ giữa hình và chữ
                    Text(
                      ads[index]["text"]!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
