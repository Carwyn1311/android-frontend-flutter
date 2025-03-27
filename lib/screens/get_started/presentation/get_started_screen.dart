import 'package:flutter/material.dart';




import '../../../core/theme/app_color.dart';
import '../../Auth/login_screen.dart';
import '../../main_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo PetShop
            const SizedBox(
              width: 130,
              height: 115,
              child: Image(
                image: AssetImage(
                  "assets/logo_petshop_cherry.png",
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bạn cần thú cưng như thế nào? Hãy đến với chúng tôi",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Image(
                image: AssetImage(
                  "assets/img_get_started.png",
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Nhận ngay các chương trình khuyến mãi hấp dẫn tại đây, "
                  "chỉ cần đăng ký tài khoản ngay để đáp ứng nhu cầu tốt nhất cho thú cưng yêu quý của bạn",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // Điều hướng đến MainScreen và xóa màn hình trước đó khỏi ngăn xếp
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                      (route) => false, // Xóa toàn bộ ngăn xếp điều hướng
                );
              },
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Bắt đầu tìm hiểu",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColor.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hãy đăng nhập ngay! ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Điều hướng đến LoginScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
