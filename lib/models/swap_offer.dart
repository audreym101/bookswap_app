class SwapOffer {
  final String id;
  final String bookId; // Book being requested
  final String bookTitle;
  final String offeredBookId; // Book being offered in exchange
  final String offeredBookTitle;
  final String wantedBookDescription; // What the requester wants in return
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
    required this.offeredBookId,
    required this.offeredBookTitle,
    this.wantedBookDescription = '',
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
      offeredBookId: map['offeredBookId'] ?? '',
      offeredBookTitle: map['offeredBookTitle'] ?? '',
      wantedBookDescription: map['wantedBookDescription'] ?? '',
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
      'offeredBookId': offeredBookId,
      'offeredBookTitle': offeredBookTitle,
      'wantedBookDescription': wantedBookDescription,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}