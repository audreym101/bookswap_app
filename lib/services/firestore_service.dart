import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Book>> getBooks() {
    return _db.collection('books').where('isAvailable', isEqualTo: true)
        .snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<Book>> getUserBooks(String userId) {
    return _db.collection('books').where('ownerId', isEqualTo: userId)
        .snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addBook(Book book) async {
    await _db.collection('books').add(book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await _db.collection('books').doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  Future<void> createSwapOffer(SwapOffer offer) async {
    await _db.collection('swaps').add(offer.toMap());
  }

  Stream<List<SwapOffer>> getUserOffers(String userId) {
    return _db.collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    await _db.collection('swaps').doc(swapId).update({'status': status});
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<List<SwapOffer>> getReceivedOffers(String userId) {
    return _db.collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SwapOffer.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> sendMessage(String swapId, String senderId, String senderName, String message) async {
    await _db.collection('swaps').doc(swapId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String swapId) {
    return _db.collection('swaps').doc(swapId).collection('messages')
        .orderBy('timestamp')
        .snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}