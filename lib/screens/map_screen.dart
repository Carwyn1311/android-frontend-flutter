import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String geoapifyApiKey = "e5468ede2f0d4c96b0996c13d69f58bc";
  late MapController mapController;
  List<Marker> markers = [];
  LatLng mapCenter = LatLng(10.843312, 106.788597); // Địa chỉ shop mặc định
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  LatLng? displayedCoordinates; // Lưu tọa độ được hiển thị
  List<LatLng> polylinePoints = []; // Danh sách điểm cho polyline

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    // Thêm marker mặc định tại vị trí shop
    markers.add(
      Marker(
        point: mapCenter,
        builder: (ctx) => Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -30,
              child: Container(
                constraints: BoxConstraints(maxWidth: 150),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Cherry the Pet Shop",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              Icons.location_on,
              color: Colors.black,
              size: 40.0,
            ),
          ],
        ),
      ),
    );
    polylinePoints.add(mapCenter); // Thêm điểm mặc định vào polyline
  }

  Future<void> getCurrentLocation() async {
    // Kiểm tra và yêu cầu quyền trước khi lấy vị trí
    final hasPermission = await LocationService.checkAndRequestLocationPermission();
    if (!hasPermission) {
      _showErrorDialog("Quyền truy cập vị trí bị từ chối. Vui lòng cấp quyền để tiếp tục.");
      return;
    }

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        mapCenter = LatLng(position.latitude, position.longitude);
        displayedCoordinates = mapCenter;
        markers.add(
          Marker(
            point: LatLng(position.latitude, position.longitude),
            builder: (ctx) => Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        );
        mapController.move(LatLng(position.latitude, position.longitude), 13.0);
        polylinePoints.add(LatLng(position.latitude, position.longitude));
      });
    } else {
      _showErrorDialog("Không thể lấy vị trí hiện tại. Vui lòng kiểm tra dịch vụ định vị.");
    }
  }

  Future<void> searchLocation(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
        });
        return;
      }

      final String url =
          "https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=$geoapifyApiKey";

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['features'].isNotEmpty) {
            setState(() {
              _searchResults = data['features']
                  .map<Map<String, dynamic>>((feature) => {
                'name': feature['properties']['formatted'],
                'lat': feature['geometry']['coordinates'][1],
                'lon': feature['geometry']['coordinates'][0],
              })
                  .toList();
            });
          } else {
            setState(() {
              _searchResults = [];
            });
          }
        } else {
          _showErrorDialog("Lỗi khi tìm kiếm địa chỉ.");
        }
      } catch (e) {
        _showErrorDialog("Lỗi kết nối mạng: $e");
      }
    });
  }

  void moveToLocation(double lat, double lon, String name) {
    setState(() {
      mapCenter = LatLng(lat, lon);
      displayedCoordinates = mapCenter;
      markers.add(
        Marker(
          point: LatLng(lat, lon),
          builder: (ctx) => Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
      mapController.move(LatLng(lat, lon), 13.0);
      polylinePoints.add(LatLng(lat, lon));
      _searchResults = [];
    });
  }

  void resetMap() {
    setState(() {
      // Quay lại vị trí mặc định
      mapController.move(mapCenter, 13.0);

      // Làm sạch marker và polyline, sau đó thêm lại marker mặc định
      markers = [
        Marker(
          point: mapCenter,
          builder: (ctx) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -30,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Cherry the Pet Shop",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(
                Icons.location_on,
                color: Colors.black,
                size: 40.0,
              ),
            ],
          ),
        ),
      ];

      // Làm sạch danh sách polyline và thêm điểm mặc định
      polylinePoints = [mapCenter];

      // Hiển thị SnackBar thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã reset bản đồ về vị trí Cherry the Pet Shop."),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geoapify Map Tracking"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: mapCenter,
              zoom: 13.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  displayedCoordinates = latlng;
                  markers.add(
                    Marker(
                      point: latlng,
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40.0,
                      ),
                    ),
                  );
                  polylinePoints.add(latlng);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$geoapifyApiKey",
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => searchLocation(value),
                  decoration: InputDecoration(
                    hintText: "Nhập địa chỉ",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(result['name']),
                          onTap: () => moveToLocation(
                            result['lat'],
                            result['lon'],
                            result['name'],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: getCurrentLocation,
              backgroundColor: Colors.blue,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: FloatingActionButton(
              onPressed: resetMap,
              backgroundColor: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  Text(
                    "Reset",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                displayedCoordinates != null
                    ? "Lat: ${displayedCoordinates!.latitude.toStringAsFixed(6)}\nLng: ${displayedCoordinates!.longitude.toStringAsFixed(6)}"
                    : "Chưa có tọa độ",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
