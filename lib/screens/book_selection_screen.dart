import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/book_card.dart';

class BookSelectionScreen extends StatelessWidget {
  final Book targetBook;
  
  const BookSelectionScreen({super.key, required this.targetBook});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();
    final currentUserId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Book to Offer'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                const Text('You want:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${targetBook.title} by ${targetBook.author}'),
                const SizedBox(height: 8),
                const Text('Select one of your books to offer in exchange:'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: firestoreService.getUserBooks(currentUserId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('You need to post books before making swap offers'),
                  );
                }
                
                final books = snapshot.data!;
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.pop(context, book),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}