import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_cherry_pet_shop/screens/Auth/logout_screen.dart';
import 'package:the_cherry_pet_shop/screens/widget/carousel_widget.dart';
import 'package:the_cherry_pet_shop/screens/widget/shop_widget.dart';
import '../core/theme/app_color.dart';
import 'home_screen/search_box.dart';
import 'widget/category_widget.dart';
import 'widget/pets_widget.dart';
import 'widget/popular_product_widget.dart';
import 'widget/promotion_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false; // Trạng thái đăng nhập

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Kiểm tra trạng thái đăng nhập khi mở màn hình
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<List<String>> fetchSuggestionsFromAPI(String query) async {
    // Giả lập API call
    await Future.delayed(const Duration(milliseconds: 500)); // Delay mô phỏng API
    return ['Product 1', 'Product 2', 'Pet 1', 'Service 1']
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("PetShop"),
                if (isLoggedIn) // Hiển thị nút Logout nếu đã đăng nhập
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LogoutScreen()),
                      );
                    },
                  ),
              ],
            ),
            centerTitle: true,
            backgroundColor: AppColor.primaryColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: SearchBox(fetchSuggestions: fetchSuggestionsFromAPI),
            ),

          ),

          /// using this method you can easily change the widget order

          const SliverToBoxAdapter(
            child: CarouselWidget(),
          ),
          const SliverToBoxAdapter(
            child: PromotionWidget(),
          ),
          const SliverToBoxAdapter(
            child: PetsWidget(),
          ),
          const SliverToBoxAdapter(
            child: CategoryWidget(),
          ),
          const SliverToBoxAdapter(
            child: PopularServiceWidget(),
          ),
          const SliverToBoxAdapter(
            child: ShopWidget(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
