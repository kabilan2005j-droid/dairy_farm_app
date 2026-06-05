import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../animals/animal_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Dairy Farm Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Farmer',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manage your dairy farm efficiently',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu title
            const Text(
              'Farm Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Feature grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.water_drop,
                  title: 'Milk\nTracking',
                  color: Colors.blue,
                  onTap: () {
                    // Coming soon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Milk Tracking — Coming Soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.pets,
                  title: 'Animal\nRecords',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnimalListScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.attach_money,
                  title: 'Sales &\nIncome',
                  color: Colors.orange,
                  onTap: () {
                    // Coming soon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sales & Income — Coming Soon!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.grass,
                  title: 'Feed\nInventory',
                  color: Colors.green,
                  onTap: () {
                    // Coming soon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feed Inventory — Coming Soon!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Health\nRecords',
                  color: Colors.red,
                  onTap: () {
                    // Coming soon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health Records — Coming Soon!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Reports &\nAnalytics',
                  color: Colors.purple,
                  onTap: () {
                    // Coming soon
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reports & Analytics — Coming Soon!'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}