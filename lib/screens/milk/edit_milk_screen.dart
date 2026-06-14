import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/milk_model.dart';
import '../../providers/milk_provider.dart';

class EditMilkScreen extends ConsumerStatefulWidget {
  final MilkModel milk;
  const EditMilkScreen({super.key, required this.milk});

  @override
  ConsumerState<EditMilkScreen> createState() => _EditMilkScreenState();
}

class _EditMilkScreenState extends ConsumerState<EditMilkScreen> {
  late TextEditingController _dskCodeController;
  late TextEditingController _dskNameController;
  late TextEditingController _fidNameController;
  late TextEditingController _quantityController;
  late TextEditingController _fatController;
  late TextEditingController _snfController;
  late TextEditingController _rateController;
  late TextEditingController _totalAmountController;
  late String _milkType;
  late String _session;
  late DateTime _billDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data
    _dskCodeController =
        TextEditingController(text: widget.milk.dskCode);
    _dskNameController =
        TextEditingController(text: widget.milk.dskName);
    _fidNameController =
        TextEditingController(text: widget.milk.fidName);
    _quantityController = TextEditingController(
        text: widget.milk.totalAmount.toString());
    _fatController = TextEditingController(
        text: widget.milk.fatPercentage.toString());
    _snfController = TextEditingController(
        text: widget.milk.snfPercentage.toString());
    _rateController = TextEditingController(
        text: widget.milk.ratePerLitre.toString());
    _totalAmountController = TextEditingController(
        text: widget.milk.totalAmount2.toString());
    _milkType =
        widget.milk.milkType.isEmpty ? 'COW' : widget.milk.milkType;
    _session = widget.milk.session.isEmpty
        ? 'Morning'
        : widget.milk.session;
    _billDate = widget.milk.date;
  }

  @override
  void dispose() {
    _dskCodeController.dispose();
    _dskNameController.dispose();
    _fidNameController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _rateController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _billDate = picked);
  }

  Future<void> _saveChanges() async {
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final quantity =
          double.tryParse(_quantityController.text) ?? 0;
      final updatedMilk = MilkModel(
        id: widget.milk.id,
        animalId: widget.milk.animalId,
        animalName: _fidNameController.text.trim(),
        morningAmount: _session == 'Morning' ? quantity : 0,
        eveningAmount: _session == 'Evening' ? quantity : 0,
        totalAmount: quantity,
        date: _billDate,
        session: _session,
        fatPercentage:
            double.tryParse(_fatController.text) ?? 0,
        snfPercentage:
            double.tryParse(_snfController.text) ?? 0,
        ratePerLitre:
            double.tryParse(_rateController.text) ?? 0,
        totalAmount2:
            double.tryParse(_totalAmountController.text) ?? 0,
        dskCode: _dskCodeController.text.trim(),
        dskName: _dskNameController.text.trim(),
        fidName: _fidNameController.text.trim(),
        milkType: _milkType,
        notes: widget.milk.notes,
      );

      await ref
          .read(milkServiceProvider)
          .updateMilkRecord(updatedMilk);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record updated successfully! ✅'),
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Milk Record',
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
                        color: Colors.blue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bill Date',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_billDate),
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
                            ? Colors.blue
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _session == s
                              ? Colors.blue
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

            // DSK Code
            _buildTextField(
              controller: _dskCodeController,
              label: 'DSK Code',
              hint: 'e.g. 000000001103',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 12),

            // DSK Name
            _buildTextField(
              controller: _dskNameController,
              label: 'DSK Name',
              hint: 'e.g. Palayam',
              icon: Icons.store,
            ),
            const SizedBox(height: 12),

            // FID Name
            _buildTextField(
              controller: _fidNameController,
              label: 'FID Name',
              hint: 'e.g. Janu',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),

            // Quantity
            _buildTextField(
              controller: _quantityController,
              label: 'Quantity (Litres) *',
              hint: 'e.g. 17.64',
              icon: Icons.water_drop,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Fat and SNF
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _fatController,
                    label: 'Fat %',
                    hint: 'e.g. 4.1',
                    icon: Icons.science,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _snfController,
                    label: 'SNF %',
                    hint: 'e.g. 7.7',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rate and Total
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rateController,
                    label: 'Rate/Litre (₹)',
                    hint: 'e.g. 36.58',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _totalAmountController,
                    label: 'Total Amount (₹)',
                    hint: 'e.g. 645.27',
                    icon: Icons.receipt,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Update Record',
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}