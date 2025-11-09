import 'package:flutter/material.dart';
import 'browse_listings_screen.dart';
import 'my_listings_screen.dart';
import 'my_offers_screen.dart';
import 'received_offers_screen.dart';
import 'settings_screen.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/swap_offer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  final List<Widget> _screens = [
    const BrowseListingsScreen(),
    const MyListingsScreen(),
    const MyOffersScreen(),
    const ReceivedOffersScreen(),
    const SettingsScreen(),
  ];

  Widget _buildBadgedIcon(IconData icon, int count) {
    return Stack(
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: StreamBuilder<List<SwapOffer>>(
        stream: _firestoreService.getReceivedOffers(currentUserId ?? ''),
        builder: (context, snapshot) {
          final pendingCount = snapshot.hasData 
              ? snapshot.data!.where((offer) => offer.status == 'pending').length 
              : 0;
          
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Browse',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'My Books',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'My Offers',
              ),
              BottomNavigationBarItem(
                icon: _buildBadgedIcon(Icons.inbox, pendingCount),
                label: 'Received',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}