import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/milk_model.dart';
import '../../providers/milk_provider.dart';
import 'bill_scanner_screen.dart';
import 'edit_milk_screen.dart';

class MilkListScreen extends ConsumerWidget {
  const MilkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milkAsync = ref.watch(milkRecordsProvider);
    final todayTotalAsync = ref.watch(todayTotalMilkProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Milk Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BillScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: milkAsync.when(
        data: (records) {
          return Column(
            children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Today's total
                        Expanded(
                          child: _buildSummaryCard(
                            title: "Today's Total",
                            value: todayTotalAsync.when(
                              data: (total) => '${total.toStringAsFixed(1)} L',
                              loading: () => '...',
                              error: (_, _) => '0 L',
                            ),
                            icon: Icons.water_drop,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total records
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Records',
                            value: '${records.length}',
                            icon: Icons.receipt_long,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total amount
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Amount',
                            value:
                                '₹${records.fold(0.0, (total, r) => total + r.totalAmount2).toStringAsFixed(0)}',
                            icon: Icons.currency_rupee,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Records list
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop,
                                size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No milk records yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first record',
                              style:
                                  TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return _buildMilkCard(
                              context, ref, record);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMilkCard(
      BuildContext context, WidgetRef ref, MilkModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Session icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: record.session == 'Morning'
                        ? Colors.orange.shade50
                        : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    record.session == 'Morning'
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                    color: record.session == 'Morning'
                        ? Colors.orange
                        : Colors.indigo,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            record.session.isEmpty
                                ? 'Milk Record'
                                : record.session,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record.milkType.isEmpty
                                  ? 'COW'
                                  : record.milkType,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(record.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (record.fidName.isNotEmpty)
                        Text(
                          'FID: ${record.fidName}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditMilkScreen(milk: record),
                          ),
                        );
                      },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, ref, record),
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
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  '🥛 Qty',
                  '${record.totalAmount.toStringAsFixed(1)} L',
                ),
                _divider(),
                _statItem(
                  '🧪 Fat',
                  '${record.fatPercentage.toStringAsFixed(1)}%',
                ),
                _divider(),
                _statItem(
                  '🧪 SNF',
                  '${record.snfPercentage.toStringAsFixed(1)}%',
                ),
                _divider(),
                _statItem(
                  '💰 Rate',
                  '₹${record.ratePerLitre.toStringAsFixed(1)}',
                ),
                _divider(),
                _statItem(
                  '💵 Total',
                  '₹${record.totalAmount2.toStringAsFixed(0)}',
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, MilkModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete this ${record.session} milk record of ${record.totalAmount.toStringAsFixed(1)}L?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(milkServiceProvider)
                  .deleteMilkRecord(record.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record deleted!'),
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