import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/sales_model.dart';
import '../../providers/sales_provider.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  const AddSaleScreen({super.key});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _buyerNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _notesController = TextEditingController();
  String _milkType = 'COW';
  String _session = 'Morning';
  String _paymentStatus = 'Paid';
  DateTime _saleDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _buyerNameController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Auto calculate total when quantity or rate changes
  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final total = qty * rate;
    if (total > 0) {
      _totalAmountController.text = total.toStringAsFixed(2);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  Future<void> _saveSale() async {
    if (_buyerNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill buyer name, quantity and rate'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final quantity =
          double.tryParse(_quantityController.text) ?? 0;
      final rate = double.tryParse(_rateController.text) ?? 0;
      final total =
          double.tryParse(_totalAmountController.text) ?? (quantity * rate);

      final sale = SalesModel(
        id: const Uuid().v4(),
        buyerName: _buyerNameController.text.trim(),
        milkType: _milkType,
        quantity: quantity,
        ratePerLitre: rate,
        totalAmount: total,
        date: _saleDate,
        session: _session,
        paymentStatus: _paymentStatus,
        notes: _notesController.text.trim(),
      );

      await ref.read(salesServiceProvider).addSale(sale);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale recorded successfully! 💰'),
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
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Sale',
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
                        color: Colors.orange),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sale Date',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_saleDate),
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

            // Session selector
            const Text('Session',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['Morning', 'Evening'].map((s) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _session = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _session == s
                            ? Colors.orange
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _session == s
                              ? Colors.orange
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: _session == s
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Milk Type
            const Text('Milk Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['COW', 'BUFFALO'].map((type) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _milkType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _milkType == type
                            ? Colors.green
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _milkType == type
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          type,
                          style: TextStyle(
                            color: _milkType == type
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Buyer name
            _buildTextField(
              controller: _buyerNameController,
              label: 'Buyer Name *',
              hint: 'Enter buyer name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),

            // Quantity and Rate
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity (L) *',
                    hint: 'e.g. 10.5',
                    icon: Icons.water_drop,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _rateController,
                    label: 'Rate/Litre (₹) *',
                    hint: 'e.g. 36.58',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total amount
            _buildTextField(
              controller: _totalAmountController,
              label: 'Total Amount (₹)',
              hint: 'Auto calculated',
              icon: Icons.receipt,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Payment status
            const Text('Payment Status',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['Paid', 'Pending'].map((status) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _paymentStatus = status),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _paymentStatus == status
                            ? (status == 'Paid'
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _paymentStatus == status
                              ? (status == 'Paid'
                                  ? Colors.green
                                  : Colors.red)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _paymentStatus == status
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                onPressed: _isSaving ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Save Sale',
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
                  const BorderSide(color: Colors.orange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}