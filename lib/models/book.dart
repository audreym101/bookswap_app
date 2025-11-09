class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageBase64;
  final String ownerId;
  final String ownerName;
  final bool isAvailable;
  final DateTime createdAt;
  final String condition;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageBase64,
    required this.ownerId,
    required this.ownerName,
    required this.isAvailable,
    required this.createdAt,
    required this.condition,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      condition: map['condition'] ?? 'Like New',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'imageBase64': imageBase64,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'condition': condition,
    };
  }
}