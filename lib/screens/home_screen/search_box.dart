import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_cherry_pet_shop/config/config_url.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key, required Future<List<String>> Function(String query) fetchSuggestions});

  @override
  _SearchBoxState createState() => _SearchBoxState();
}


class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Hàm lấy dữ liệu từ API
  Future<List<dynamic>> _fetchData(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load $endpoint. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $endpoint: $e');
    }
  }

  // Hàm lấy gợi ý từ API
  Future<List<String>> _fetchSuggestions(String query) async {
    final List<String> suggestions = [];
    if (query.isEmpty) return suggestions;

    try {
      // Fetch từ API Pet
      final pets = await _fetchData('Pet');
      suggestions.addAll(
        pets.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).map<String>((item) => item['name']).toList(),
      );

      // Fetch từ API Product
      final products = await _fetchData('Product');
      suggestions.addAll(
        products.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).map<String>((item) => item['name']).toList(),
      );

      // Fetch từ API Service
      final services = await _fetchData('Service');
      suggestions.addAll(
        services.where((item) => item['name'].toLowerCase().contains(query.toLowerCase())).map<String>((item) => item['name']).toList(),
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    return suggestions;
  }

  // Xử lý tìm kiếm và cập nhật gợi ý
  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final suggestions = await _fetchSuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _search,
                  decoration: const InputDecoration(
                    hintText: "Search | pets, products, services...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _suggestions = [];
                    });
                  },
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
        if (_errorMessage != null)
          Center(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_suggestions.isEmpty && !_isLoading && _errorMessage == null)
          const Center(
            child: Text(
              "Không tìm thấy kết quả.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        if (_suggestions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_suggestions[index]),
                onTap: () {
                  // Xử lý khi chọn gợi ý
                  print("Selected: ${_suggestions[index]}");
                },
              );
            },
          ),
      ],
    );
  }
}
