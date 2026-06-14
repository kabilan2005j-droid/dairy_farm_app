import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/feed_model.dart';
import '../../providers/feed_provider.dart';
import 'add_feed_screen.dart';
import 'edit_feed_screen.dart';

class FeedListScreen extends ConsumerWidget {
  const FeedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(feedsProvider);
    final totalCostAsync = ref.watch(totalFeedCostProvider);
    final lowStockAsync = ref.watch(lowStockFeedsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Feed Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFeedScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: feedsAsync.when(
        data: (feeds) {
          return Column(
            children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Items',
                        value: '${feeds.length}',
                        icon: Icons.inventory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Cost',
                        value: totalCostAsync.when(
                          data: (cost) =>
                              '₹${cost.toStringAsFixed(0)}',
                          loading: () => '...',
                          error: (_, _) => '₹0',
                        ),
                        icon: Icons.currency_rupee,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Low Stock',
                        value: lowStockAsync.when(
                          data: (low) => '${low.length}',
                          loading: () => '...',
                          error: (_, _) => '0',
                        ),
                        icon: Icons.warning_amber,
                        isWarning: true,
                      ),
                    ),
                  ],
                ),
              ),

              // Low stock warning banner
              lowStockAsync.when(
                data: (lowStock) {
                  if (lowStock.isEmpty) return const SizedBox();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: Colors.red.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${lowStock.length} item(s) running low: ${lowStock.map((f) => f.feedName).join(', ')}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),

              // Feed list
              Expanded(
                child: feeds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grass,
                                size: 80,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No feed items yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first feed',
                              style: TextStyle(
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: feeds.length,
                        itemBuilder: (context, index) {
                          return _buildFeedCard(
                              context, ref, feeds[index]);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        error: (error, stack) =>
            Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: isWarning ? Colors.yellow : Colors.white,
              size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(
      BuildContext context, WidgetRef ref, FeedModel feed) {
    final isLow = feed.isLowStock;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLow
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLow
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grass,
                    color:
                        isLow ? Colors.red : Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            feed.feedName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              feed.feedType,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isLow) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⚠️ Low',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Purchased: ${DateFormat('dd MMM yyyy').format(feed.purchaseDate)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (feed.supplierName.isNotEmpty)
                        Text(
                          'Supplier: ${feed.supplierName}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.green),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditFeedScreen(feed: feed),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, ref, feed),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLow
                  ? Colors.red.shade50
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  '📦 Stock',
                  '${feed.quantity.toStringAsFixed(1)} ${feed.unit}',
                  isWarning: isLow,
                ),
                _divider(),
                _statItem(
                  '💰 Price',
                  '₹${feed.unitPrice.toStringAsFixed(1)}/${feed.unit}',
                ),
                _divider(),
                _statItem(
                  '💵 Total',
                  '₹${feed.totalCost.toStringAsFixed(0)}',
                  isHighlight: true,
                ),
                _divider(),
                _statItem(
                  '⚠️ Alert at',
                  '${feed.lowStockThreshold.toStringAsFixed(0)} ${feed.unit}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value,
      {bool isHighlight = false, bool isWarning = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isWarning
                ? Colors.red
                : isHighlight
                    ? Colors.green
                    : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
        height: 30, width: 1, color: Colors.grey.shade300);
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, FeedModel feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feed'),
        content: Text(
            'Are you sure you want to delete ${feed.feedName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(feedServiceProvider)
                  .deleteFeed(feed.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feed deleted!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}