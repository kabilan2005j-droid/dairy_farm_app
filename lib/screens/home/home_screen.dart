import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/animal_provider.dart';
import '../../providers/milk_provider.dart';
import '../../providers/sales_provider.dart';
import '../../theme/app_theme.dart';
import '../animals/animal_list_screen.dart';
import '../milk/milk_list_screen.dart';
import '../sales/sales_list_screen.dart';
import '../feed/feed_list_screen.dart';
import '../health/health_list_screen.dart';
import '../reports/reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final animalsAsync = ref.watch(animalsProvider);
    final milkAsync = ref.watch(milkRecordsProvider);
    final salesAsync = ref.watch(salesProvider);
    final todayMilkAsync = ref.watch(todayTotalMilkProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background glow effects
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary
                    .withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan
                    .withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning 🌅',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              user?.email
                                      ?.split('@')
                                      .first
                                      .capitalize() ??
                                  'Farmer',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Notification bell
                            GlassCard(
                              padding:
                                  const EdgeInsets.all(10),
                              borderRadius: 12,
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textWhite,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Logout
                            GlassCard(
                              padding:
                                  const EdgeInsets.all(10),
                              borderRadius: 12,
                              child: GestureDetector(
                                onTap: () async {
                                  await ref
                                      .read(
                                          authServiceProvider)
                                      .logout();
                                },
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.pink,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 24, 20, 0),
                    child: Row(
                      children: [
                        // Animals stat
                        Expanded(
                          child: animalsAsync.when(
                            data: (animals) => _buildStatCard(
                              label: 'Animals',
                              value:
                                  '${animals.length}',
                              icon: Icons.pets,
                              color: AppColors.lime,
                            ),
                            loading: () => _buildStatCard(
                              label: 'Animals',
                              value: '...',
                              icon: Icons.pets,
                              color: AppColors.lime,
                            ),
                            error: (_, _) =>
                                _buildStatCard(
                              label: 'Animals',
                              value: '0',
                              icon: Icons.pets,
                              color: AppColors.lime,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Today milk stat
                        Expanded(
                          child: todayMilkAsync.when(
                            data: (total) => _buildStatCard(
                              label: "Today's Milk",
                              value:
                                  '${total.toStringAsFixed(1)}L',
                              icon: Icons.water_drop,
                              color: AppColors.cyan,
                            ),
                            loading: () => _buildStatCard(
                              label: "Today's Milk",
                              value: '...',
                              icon: Icons.water_drop,
                              color: AppColors.cyan,
                            ),
                            error: (_, _) =>
                                _buildStatCard(
                              label: "Today's Milk",
                              value: '0L',
                              icon: Icons.water_drop,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total income stat
                        Expanded(
                          child: salesAsync.when(
                            data: (sales) {
                              final total = sales.fold(
                                  0.0,
                                  (sum, s) =>
                                      sum + s.totalAmount);
                              return _buildStatCard(
                                label: 'Income',
                                value:
                                    '₹${total.toStringAsFixed(0)}',
                                icon:
                                    Icons.currency_rupee,
                                color: AppColors.amber,
                              );
                            },
                            loading: () => _buildStatCard(
                              label: 'Income',
                              value: '...',
                              icon: Icons.currency_rupee,
                              color: AppColors.amber,
                            ),
                            error: (_, _) =>
                                _buildStatCard(
                              label: 'Income',
                              value: '₹0',
                              icon: Icons.currency_rupee,
                              color: AppColors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 28, 20, 16),
                    child: Text(
                      'Farm Management',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),

                // Feature grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildFeatureCard(
                        context,
                        title: 'Milk\nTracking',
                        icon: Icons.water_drop_rounded,
                        color: AppColors.cyan,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MilkListScreen(),
                          ),
                        ),
                      ),
                      _buildFeatureCard(
                        context,
                        title: 'Animal\nRecords',
                        icon: Icons.pets_rounded,
                        color: AppColors.lime,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AnimalListScreen(),
                          ),
                        ),
                      ),
                      _buildFeatureCard(
                        context,
                        title: 'Sales &\nIncome',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.amber,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SalesListScreen(),
                          ),
                        ),
                      ),
                      _buildFeatureCard(
                        context,
                        title: 'Feed\nInventory',
                        icon: Icons.grass_rounded,
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FeedListScreen(),
                          ),
                        ),
                      ),
                      _buildFeatureCard(
                        context,
                        title: 'Health\nRecords',
                        icon: Icons.favorite_rounded,
                        color: AppColors.pink,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const HealthListScreen(),
                          ),
                        ),
                      ),
                      _buildFeatureCard(
                        context,
                        title: 'Reports &\nAnalytics',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ReportsScreen(),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                // Recent milk activity
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 28, 20, 8),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MilkListScreen(),
                            ),
                          ),
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent milk records
                milkAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: GlassCard(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                        16),
                                child: Text(
                                  'No milk records yet',
                                  style:
                                      GoogleFonts.poppins(
                                    color:
                                        AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final recent = records.take(3).toList();
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = recent[index];
                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                                    20, 0, 20, 10),
                            child: GlassCard(
                              padding:
                                  const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration:
                                        BoxDecoration(
                                      color: AppColors.cyan
                                          .withValues(
                                              alpha: 0.15),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color:
                                          AppColors.cyan,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          record.session
                                                  .isEmpty
                                              ? 'Milk Record'
                                              : '${record.session} Session',
                                          style: GoogleFonts
                                              .poppins(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: AppColors
                                                .textWhite,
                                          ),
                                        ),
                                        Text(
                                          record.milkType
                                                  .isEmpty
                                              ? 'Milk'
                                              : record
                                                  .milkType,
                                          style: GoogleFonts
                                              .poppins(
                                            fontSize: 12,
                                            color: AppColors
                                                .textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,
                                    children: [
                                      Text(
                                        '${record.totalAmount.toStringAsFixed(1)}L',
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              AppColors.cyan,
                                        ),
                                      ),
                                      Text(
                                        '₹${record.totalAmount2.toStringAsFixed(0)}',
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 12,
                                          color: AppColors
                                              .primary,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: recent.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(),
                  ),
                  error: (_, _) =>
                      const SliverToBoxAdapter(
                    child: SizedBox(),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}