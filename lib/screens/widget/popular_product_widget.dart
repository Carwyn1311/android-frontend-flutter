import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_cherry_pet_shop/config/config_url.dart';
import '../../models/pet_service_model.dart';
import '../apoinment/ServiceDetailScreen.dart';


class PopularServiceWidget extends StatefulWidget {
  const PopularServiceWidget({Key? key}) : super(key: key);

  @override
  _PopularServiceWidgetState createState() => _PopularServiceWidgetState();
}

class _PopularServiceWidgetState extends State<PopularServiceWidget> {
  late Future<List<PetService>> _services;

  @override
  void initState() {
    super.initState();
    _services = _fetchServices();
  }

  Future<List<PetService>> _fetchServices() async {
    final String apiUrl = '${Config_URL.baseUrl}Service';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('API Response: ${response.body}'); // In ra dữ liệu trả về từ API
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed Data: $data'); // In ra dữ liệu đã parse
        return data.map((json) => PetService.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // In ra lỗi nếu có
      throw Exception('Failed to load services: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            "Danh sách dịch vụ thú cưng",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<PetService>>(
            future: _services,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Không thể tải dịch vụ: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData) {
                final services = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () {
                        // Chuyển sang màn hình chi tiết dịch vụ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailScreen(service: service),
                          ),
                        );
                      },
                      child: Container(
                        width: 220,
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(1, 1),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Hình ảnh dịch vụ
                            Container(
                              width: 220,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  service.images.isNotEmpty
                                      ? service.images[0].url
                                      : 'https://via.placeholder.com/220x180',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Tên dịch vụ
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                service.name,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('Không có dịch vụ nào'));
              }
            },
          ),
        ),
      ],
    );
  }
}
