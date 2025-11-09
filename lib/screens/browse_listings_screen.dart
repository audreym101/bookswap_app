import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import 'add_book_screen.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  Future<void> _initiateSwap(Book book) async {
    final user = _authService.currentUser!;
    final offer = SwapOffer(
      id: '',
      bookId: book.id,
      bookTitle: book.title,
      requesterId: user.uid,
      requesterName: user.email ?? 'Unknown',
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _firestoreService.createSwapOffer(offer);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap request sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBookScreen()),
        ),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Book>>(
        stream: _firestoreService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No books available',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          
          final books = snapshot.data!;
          final currentUserId = _authService.currentUser?.uid;
          final availableBooks = books.where((book) => book.ownerId != currentUserId).toList();
          
          if (availableBooks.isEmpty) {
            return const Center(
              child: Text(
                'No books available for swap',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: availableBooks.length,
            itemBuilder: (context, index) {
              final book = availableBooks[index];
              return Card(
                color: const Color(0xFF2C2C2C),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4A4A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: book.imageBase64.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(book.imageBase64),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.book, color: Colors.white54),
                                    ),
                                  )
                                : const Icon(Icons.book, color: Colors.white54),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFC107),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        book.condition,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Owner: ${book.ownerName}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _initiateSwap(book),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Request Swap'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}