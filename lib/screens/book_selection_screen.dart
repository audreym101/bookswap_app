import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/book_card.dart';

class BookSelectionScreen extends StatefulWidget {
  final Book targetBook;
  
  const BookSelectionScreen({super.key, required this.targetBook});

  @override
  State<BookSelectionScreen> createState() => _BookSelectionScreenState();
}

class _BookSelectionScreenState extends State<BookSelectionScreen> {
  final _wantedBookController = TextEditingController();
  
  @override
  void dispose() {
    _wantedBookController.dispose();
    super.dispose();
  }

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
                Text('${widget.targetBook.title} by ${widget.targetBook.author}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _wantedBookController,
                  decoration: const InputDecoration(
                    labelText: 'What type of book do you want in return?',
                    hintText: 'e.g., Mystery novels, Science fiction, Romance...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
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
                      onTap: () {
                        final wantedDescription = _wantedBookController.text.trim();
                        Navigator.pop(context, {
                          'book': book,
                          'wantedDescription': wantedDescription,
                        });
                      },
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