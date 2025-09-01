import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../User/login.dart';
import '../core/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final displayName = user?.username ?? user?.contact ?? "Name";
    final displayEmail = user?.email ?? "Email";
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, size: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail.toString(),
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _Tile(icon: Icons.shopping_bag_outlined, title: "Orders"),
            const SizedBox(height: 10),
            const _Tile(icon: Icons.favorite_border, title: "Favorites"),
            const SizedBox(height: 10),
            const _Tile(icon: Icons.location_on_outlined, title: "Addresses"),
            const SizedBox(height: 10),
            const _Tile(icon: Icons.credit_card, title: "Payment Methods"),
            const SizedBox(height: 10),
            const _Tile(icon: Icons.notifications_none, title: "Notifications"),
            const SizedBox(height: 10),
            const _Tile(icon: Icons.settings_outlined, title: "Settings"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  await auth.doLogout(); // clears tokens + user + notifies
                } catch (e) {
                  print("Logout failed $e");
                }

                if (!context.mounted) return;

                // Hard-redirect to Login and clear the back stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: const Color(0xFFF5F6F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
