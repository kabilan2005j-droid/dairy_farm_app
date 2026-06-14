import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/sales_model.dart';
import '../../providers/sales_provider.dart';
import 'add_sale_screen.dart';
import 'edit_sale_screen.dart';

class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final totalIncomeAsync = ref.watch(totalIncomeProvider);
    final pendingAmountAsync = ref.watch(pendingAmountProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text(
          'Sales & Income',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSaleScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: salesAsync.when(
        data: (sales) {
          return Column(
            children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange,
                child: Row(
                  children: [
                    // Total sales
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Sales',
                        value: '${sales.length}',
                        icon: Icons.shopping_cart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Total income
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Income',
                        value: totalIncomeAsync.when(
                          data: (total) =>
                              '₹${total.toStringAsFixed(0)}',
                          loading: () => '...',
                          error: (_, _) => '₹0',
                        ),
                        icon: Icons.currency_rupee,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pending amount
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Pending',
                        value: pendingAmountAsync.when(
                          data: (pending) =>
                              '₹${pending.toStringAsFixed(0)}',
                          loading: () => '...',
                          error: (_, _) => '₹0',
                        ),
                        icon: Icons.pending,
                        isWarning: true,
                      ),
                    ),
                  ],
                ),
              ),

              // Sales list
              Expanded(
                child: sales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_money,
                                size: 80,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No sales recorded yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to record your first sale',
                              style: TextStyle(
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sales.length,
                        itemBuilder: (context, index) {
                          final sale = sales[index];
                          return _buildSaleCard(
                              context, ref, sale);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
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

  Widget _buildSaleCard(
      BuildContext context, WidgetRef ref, SalesModel sale) {
    final isPaid = sale.paymentStatus == 'Paid';
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.orange,
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
                            sale.buyerName,
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
                              color: isPaid
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sale.paymentStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: isPaid
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(sale.date)} • ${sale.session}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Milk Type: ${sale.milkType}',
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
                          color: Colors.orange),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditSaleScreen(sale: sale),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () =>
                          _confirmDelete(context, ref, sale),
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
                    '${sale.quantity.toStringAsFixed(1)} L'),
                _divider(),
                _statItem(
                    '💰 Rate',
                    '₹${sale.ratePerLitre.toStringAsFixed(2)}'),
                _divider(),
                _statItem(
                  '💵 Total',
                  '₹${sale.totalAmount.toStringAsFixed(0)}',
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
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
        height: 30, width: 1, color: Colors.grey.shade300);
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, SalesModel sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: Text(
            'Are you sure you want to delete this sale record for ${sale.buyerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(salesServiceProvider)
                  .deleteSale(sale.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sale deleted!'),
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