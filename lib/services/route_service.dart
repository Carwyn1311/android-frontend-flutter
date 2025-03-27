import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RouteService {
  final String apiKey;

  RouteService({required this.apiKey});

  // Tìm đường đi ngắn nhất
  Future<Map<String, dynamic>> getShortestRoute(LatLng source, LatLng destination) async {
    final String url = "https://api.geoapify.com/v1/routematrix?apiKey=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "mode": "drive", // Chế độ: lái xe
        "sources": [
          {"location": [source.longitude, source.latitude]}
        ],
        "targets": [
          {"location": [destination.longitude, destination.latitude]}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['sources_to_targets'] != null && data['sources_to_targets'].isNotEmpty) {
        final routeInfo = data['sources_to_targets'][0][0];
        return {
          "distance": routeInfo['distance'], // Khoảng cách (mét)
          "time": routeInfo['time'], // Thời gian (giây)
        };
      } else {
        print("Phản hồi không có dữ liệu 'sources_to_targets'.");
        throw Exception("Không tìm thấy tuyến đường.");
      }
    } else {
      print("Lỗi API: ${response.statusCode}");
      throw Exception("Lỗi khi gọi API Geoapify.");
    }
  }

  // Tìm tuyến đường chi tiết giữa hai điểm
  Future<List<LatLng>> getRouteDetails(LatLng source, LatLng destination) async {
    final String url =
        "https://api.geoapify.com/v1/routing?waypoints=${source.latitude},${source.longitude}|${destination.latitude},${destination.longitude}&mode=drive&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['features'] != null &&
          data['features'].isNotEmpty &&
          data['features'][0]['geometry']['coordinates'] != null) {
        final coordinates = data['features'][0]['geometry']['coordinates'] as List;

        return coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      } else {
        print("Phản hồi không có dữ liệu 'features' hoặc 'coordinates'.");
        throw Exception("Không tìm thấy tuyến đường chi tiết.");
      }
    } else {
      print("Lỗi API: ${response.statusCode}");
      throw Exception("Lỗi khi gọi API Geoapify để lấy chi tiết tuyến đường.");
    }
  }
}
