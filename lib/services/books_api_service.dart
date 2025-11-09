import 'dart:convert';
import 'package:http/http.dart' as http;

class BooksApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  
  static Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$query&maxResults=5'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        
        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          return {
            'title': volumeInfo['title'] ?? '',
            'authors': (volumeInfo['authors'] as List?)?.join(', ') ?? '',
            'description': volumeInfo['description'] ?? '',
            'imageUrl': volumeInfo['imageLinks']?['thumbnail'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}