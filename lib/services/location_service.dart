import 'package:geolocator/geolocator.dart';

class LocationService {
  // Kiểm tra và yêu cầu quyền vị trí
  static Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Trả về false nếu dịch vụ định vị không bật
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Trả về false nếu người dùng từ chối quyền truy cập
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Trả về false nếu quyền truy cập bị từ chối vĩnh viễn
      return false;
    }

    // Trả về true nếu quyền đã được cấp
    return true;
  }

  // Lấy vị trí hiện tại
  static Future<Position?> getCurrentLocation() async {
    // Kiểm tra và yêu cầu quyền trước khi lấy vị trí
    bool hasPermission = await checkAndRequestLocationPermission();
    if (!hasPermission) {
      return null; // Trả về null nếu không có quyền
    }

    // Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
