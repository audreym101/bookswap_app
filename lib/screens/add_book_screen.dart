import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;
  String _imageBase64 = '';
  String _imageUrl = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Show options for camera, gallery, or URL
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Image URL'),
              onTap: () => Navigator.pop(context, 'url'),
            ),
          ],
        ),
      ),
    );
    
    if (choice == null) return;
    
    if (choice == 'url') {
      _showUrlDialog();
      return;
    }
    
    final source = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    try {
      String base64Image;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        final file = File(picked.path);
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        base64Image = base64Encode(await compressed!.readAsBytes());
      }

      setState(() {
        _imageBase64 = base64Image;
        _imageUrl = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: ${e.toString()}')),
        );
      }
    }
  }

  void _showUrlDialog() {
    final sampleUrls = [
      'https://picsum.photos/400/600?random=1',
      'https://picsum.photos/400/600?random=2',
      'https://picsum.photos/400/600?random=3',
      'https://via.placeholder.com/400x600/FF6B6B/FFFFFF?text=Book+Cover',
      'https://via.placeholder.com/400x600/4ECDC4/FFFFFF?text=Sample+Book',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Custom URL',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Or choose a sample:'),
              const SizedBox(height: 8),
              ...sampleUrls.map((url) => ListTile(
                leading: Image.network(
                  url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image),
                ),
                title: Text('Sample ${sampleUrls.indexOf(url) + 1}'),
                onTap: () {
                  setState(() {
                    _imageUrl = url;
                    _imageBase64 = '';
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _imageUrl = _imageUrlController.text.trim();
                _imageBase64 = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Use Custom URL'),
          ),
        ],
      ),
    );
  }

  Future<void> _addBook() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and author')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser!;
      
      final book = Book(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        imageBase64: _imageUrl.isNotEmpty ? _imageUrl : _imageBase64,
        ownerId: user.uid,
        ownerName: user.email?.split('@')[0] ?? 'Unknown',
        isAvailable: true,
        createdAt: DateTime.now(),
        condition: _selectedCondition,
      );

      await _firestoreService.addBook(book);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding book: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  String _selectedCondition = 'Like New';
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrl,
                          fit: BoxFit.cover,
                          headers: const {'User-Agent': 'BookSwap/1.0'},
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text('Image failed to load', 
                                       style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  Text('Try a different URL', 
                                       style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : _imageBase64.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_imageBase64),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40),
                          Text('Tap to add book cover'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Condition', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: _conditions.map((condition) {
                final isSelected = condition == _selectedCondition;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCondition = condition),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          condition,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addBook,
                      child: const Text('Post Book'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}