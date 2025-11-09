class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.createdAt,
  });

  factory SwapOffer.fromMap(Map<String, dynamic> map, String id) {
    return SwapOffer(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}