import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/feed_model.dart';
import '../../providers/feed_provider.dart';

class AddFeedScreen extends ConsumerStatefulWidget {
  const AddFeedScreen({super.key});

  @override
  ConsumerState<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends ConsumerState<AddFeedScreen> {
  final _feedNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _lowStockController = TextEditingController(text: '10');
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  String _feedType = 'Hay';
  String _unit = 'kg';
  DateTime _purchaseDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _feedTypes = [
    'Hay',
    'Silage',
    'Grain',
    'Concentrate',
    'Straw',
    'Mineral Mix',
    'Other',
  ];

  final List<String> _units = ['kg', 'ton', 'bag', 'bundle'];

  @override
  void dispose() {
    _feedNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _totalCostController.dispose();
    _lowStockController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    final total = qty * price;
    if (total > 0) {
      _totalCostController.text = total.toStringAsFixed(2);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _saveFeed() async {
    if (_feedNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _unitPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill feed name, quantity and price'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final quantity =
          double.tryParse(_quantityController.text) ?? 0;
      final unitPrice =
          double.tryParse(_unitPriceController.text) ?? 0;
      final totalCost =
          double.tryParse(_totalCostController.text) ??
              (quantity * unitPrice);
      final lowStock =
          double.tryParse(_lowStockController.text) ?? 10;

      final feed = FeedModel(
        id: const Uuid().v4(),
        feedName: _feedNameController.text.trim(),
        feedType: _feedType,
        quantity: quantity,
        unit: _unit,
        unitPrice: unitPrice,
        totalCost: totalCost,
        lowStockThreshold: lowStock,
        supplierName: _supplierController.text.trim(),
        purchaseDate: _purchaseDate,
        notes: _notesController.text.trim(),
      );

      await ref.read(feedServiceProvider).addFeed(feed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed added successfully! 🌾'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.green),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Purchase Date',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(_purchaseDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feed Type
            const Text('Feed Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedTypes.map((type) {
                return GestureDetector(
                  onTap: () => setState(() => _feedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _feedType == type
                          ? Colors.green
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _feedType == type
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: _feedType == type
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Feed Name
            _buildTextField(
              controller: _feedNameController,
              label: 'Feed Name *',
              hint: 'e.g. Rice Straw, Groundnut Cake',
              icon: Icons.grass,
            ),
            const SizedBox(height: 12),

            // Unit selector
            const Text('Unit',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: _units.map((u) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _unit = u),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _unit == u
                            ? Colors.green
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _unit == u
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          u,
                          style: TextStyle(
                            color: _unit == u
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Quantity and Unit Price
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity *',
                    hint: 'e.g. 100',
                    icon: Icons.scale,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _unitPriceController,
                    label: 'Price/Unit (₹) *',
                    hint: 'e.g. 15',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total Cost
            _buildTextField(
              controller: _totalCostController,
              label: 'Total Cost (₹)',
              hint: 'Auto calculated',
              icon: Icons.receipt,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Low Stock Threshold
            _buildTextField(
              controller: _lowStockController,
              label: 'Low Stock Alert (quantity)',
              hint: 'e.g. 10',
              icon: Icons.warning_amber,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Supplier Name
            _buildTextField(
              controller: _supplierController,
              label: 'Supplier Name',
              hint: 'Enter supplier name',
              icon: Icons.store,
            ),
            const SizedBox(height: 12),

            // Notes
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Any additional notes',
              icon: Icons.note,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveFeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Save Feed',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}