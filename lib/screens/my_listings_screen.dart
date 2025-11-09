import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  Future<void> _deleteBook(String bookId) async {
    await _firestoreService.deleteBook(bookId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
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
        stream: _firestoreService.getUserBooks(currentUserId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No books posted yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          
          final books = snapshot.data!;
          return StreamBuilder<List<SwapOffer>>(
            stream: _firestoreService.getReceivedOffers(currentUserId ?? ''),
            builder: (context, offerSnapshot) {
              final pendingOffers = offerSnapshot.hasData 
                  ? offerSnapshot.data!.where((offer) => offer.status == 'pending').toList()
                  : <SwapOffer>[];
              
              final pendingBookIds = pendingOffers.map((offer) => offer.bookId).toSet();
              final availableBooks = books.where((book) => !pendingBookIds.contains(book.id)).toList();
              final pendingBooks = books.where((book) => pendingBookIds.contains(book.id)).toList();
              
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (availableBooks.isNotEmpty) ...[
                    const Text(
                      'Available Books',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...availableBooks.map((book) => _buildBookCard(book, false)),
                    const SizedBox(height: 16),
                  ],
                  if (pendingBooks.isNotEmpty) ...[
                    const Text(
                      'Pending Swap Offers',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...pendingBooks.map((book) => _buildBookCard(book, true)),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(Book book, bool isPending) {
    return Card(
      color: isPending ? const Color(0xFF3A2A1A) : const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isPending)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Pending swap offer',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ),
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
                          child: book.imageBase64.startsWith('http')
                              ? Image.network(
                                  book.imageBase64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.book, color: Colors.white54),
                                )
                              : Image.memory(
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
                      const SizedBox(height: 4),
                      Text(
                        book.description,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
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
                ),
                if (!isPending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBookScreen(book: book),
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _deleteBook(book.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
            if (!isPending) ...[
              const SizedBox(height: 16),
              StreamBuilder<List<Book>>(
                stream: _firestoreService.getBooks(),
                builder: (context, swapSnapshot) {
                  if (!swapSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  
                  final availableBooks = swapSnapshot.data!
                      .where((b) => b.ownerId != _authService.currentUser?.uid && b.isAvailable)
                      .toList();
                  
                  if (availableBooks.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No books available for swap',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    );
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available for swap:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: availableBooks.length,
                            itemBuilder: (context, swapIndex) {
                              final swapBook = availableBooks[swapIndex];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 8),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A4A4A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: swapBook.imageBase64.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: swapBook.imageBase64.startsWith('http')
                                                  ? Image.network(
                                                      swapBook.imageBase64,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          const Icon(Icons.book, color: Colors.white54, size: 20),
                                                    )
                                                  : Image.memory(
                                                      base64Decode(swapBook.imageBase64),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          const Icon(Icons.book, color: Colors.white54, size: 20),
                                                    ),
                                            )
                                          : const Icon(Icons.book, color: Colors.white54, size: 20),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      swapBook.title,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}