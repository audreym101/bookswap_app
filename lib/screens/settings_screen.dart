import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<UserProfile?>(
              future: _firestoreService.getUserProfile(currentUserId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                final profile = snapshot.data;
                return Card(
                  color: const Color(0xFF2C2C2C),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white70),
                            const SizedBox(width: 16),
                            Text(
                              profile?.displayName ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.white70),
                            const SizedBox(width: 16),
                            Text(
                              profile?.email ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              profile?.emailVerified == true 
                                  ? Icons.verified 
                                  : Icons.warning,
                              color: profile?.emailVerified == true 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              profile?.emailVerified == true 
                                  ? 'Email Verified' 
                                  : 'Email Not Verified',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF2C2C2C),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white70),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeThumbColor: const Color(0xFFFFC107),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _authService.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}