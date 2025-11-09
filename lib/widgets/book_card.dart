import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: book.imageBase64.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(book.imageBase64),
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book),
              ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${book.author}'),
            Text('Condition: ${book.condition}'),
            Text('Owner: ${book.ownerName}'),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}