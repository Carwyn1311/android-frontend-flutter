import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/config_url.dart';

class AdminServiceList extends StatefulWidget {
  const AdminServiceList({Key? key}) : super(key: key);

  @override
  State<AdminServiceList> createState() => _AdminServiceListState();
}

class _AdminServiceListState extends State<AdminServiceList> with RouteAware {
  List<dynamic> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void didPopNext() {
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}Service'));
      if (response.statusCode == 200) {
        setState(() {
          _services = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching services: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(int serviceId) async {
    try {
      final response = await http.delete(Uri.parse('${Config_URL.baseUrl}Service/$serviceId'));
      if (response.statusCode == 200) {
        setState(() {
          _services.removeWhere((service) => service['serviceId'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete service. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting service: $e')),
      );
    }
  }

  Future<void> _addOrEditService({Map<String, dynamic>? service}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditServiceScreen(service: service),
      ),
    );
    if (result == true) {
      _fetchServices();
    }
  }

  Widget _buildImage(String? url) {
    return url != null
        ? Image.network(
      url,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    )
        : _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.pets,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách dịch vụ'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          final imageUrl = (service['images'] != null && service['images'].isNotEmpty)
              ? service['images'][0]['url']
              : null;

          return ListTile(
            leading: _buildImage(imageUrl),
            title: Text(service['name']),
            subtitle: Text('Giá: ${service['price']} VND'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _addOrEditService(service: service);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteService(service['serviceId']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditService();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver = ModalRoute.of(context)?.settings.arguments as RouteObserver<ModalRoute>?;
    routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    final routeObserver = ModalRoute.of(context)?.settings.arguments as RouteObserver<ModalRoute>?;
    routeObserver?.unsubscribe(this);
    super.dispose();
  }
}

class AddOrEditServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? service;

  const AddOrEditServiceScreen({Key? key, this.service}) : super(key: key);

  @override
  State<AddOrEditServiceScreen> createState() => _AddOrEditServiceScreenState();
}

class _AddOrEditServiceScreenState extends State<AddOrEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.service != null ? widget.service!['name'] : '');
    _priceController = TextEditingController(
        text: widget.service != null ? widget.service!['price'].toString() : '');
    _descriptionController = TextEditingController(
        text: widget.service != null ? widget.service!['description'] : '');
    _imageUrlController = TextEditingController(
        text: widget.service != null &&
            widget.service!['images'] != null &&
            widget.service!['images'].isNotEmpty
            ? widget.service!['images'][0]['url']
            : '');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.service != null;
    final url = isEditing
        ? Uri.parse('${Config_URL.baseUrl}Service/${widget.service!['serviceId']}')
        : Uri.parse('${Config_URL.baseUrl}Service');

    final requestBody = jsonEncode({
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text),
      'description': _descriptionController.text,
      'images': [
        {'url': _imageUrlController.text}
      ],
    });

    try {
      final response = isEditing
          ? await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      )
          : await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception(
            'Failed to save service. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Sửa dịch vụ' : 'Thêm dịch vụ'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên dịch vụ'),
                  validator: (value) =>
                  value!.isEmpty ? 'Tên không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  validator: (value) =>
                  value!.isEmpty ? 'Giá không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) =>
                  value!.isEmpty ? 'Mô tả không được để trống' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL ảnh'),
                  validator: (value) =>
                  value!.isEmpty ? 'URL ảnh không được để trống' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.service != null ? 'Cập nhật' : 'Thêm mới'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
