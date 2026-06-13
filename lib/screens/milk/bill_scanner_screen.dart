import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/milk_model.dart';
import '../../services/milk_service.dart';

class BillScannerScreen extends ConsumerStatefulWidget {
  const BillScannerScreen({super.key});

  @override
  ConsumerState<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends ConsumerState<BillScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _imageFile;
  bool _isScanning = false;
  bool _isScanned = false;
  bool _isSaving = false;

  // Controllers for manual entry
  final _dskCodeController = TextEditingController();
  final _dskNameController = TextEditingController();
  final _fidNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _rateController = TextEditingController();
  final _totalAmountController = TextEditingController();
  String _milkType = 'COW';
  String _session = 'Morning';
  DateTime _billDate = DateTime.now();

  // Extracted fields from scan
  String _dskCode = '';
  String _dskName = '';
  String _fidName = '';
  String _scannedMilkType = '';
  String _scannedSession = '';
  double _quantity = 0.0;
  double _fatPercentage = 0.0;
  double _snfPercentage = 0.0;
  double _ratePerLitre = 0.0;
  double _totalAmount = 0.0;
  DateTime _scannedDate = DateTime.now();

  final MilkService _milkService = MilkService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  // Pick image
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _isScanned = false;
      });
      await _scanBill();
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _sourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 35),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Improved OCR scan
  Future<void> _scanBill() async {
    if (_imageFile == null) return;
    setState(() => _isScanning = true);

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final text = recognizedText.text;
      debugPrint('========== SCANNED TEXT ==========');
      debugPrint(text);
      debugPrint('==================================');

      _extractBillData(text);

      setState(() {
        _isScanning = false;
        _isScanned = true;
      });

      // If scan detected some data, show success
      // If not, auto switch to manual tab
      if (_quantity == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not read bill clearly. Switched to manual entry.'),
              backgroundColor: Colors.orange,
            ),
          );
          _tabController.animateTo(1);
        }
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _tabController.animateTo(1);
      }
    }
  }

  // Improved extraction logic
  void _extractBillData(String text) {
    // Reset all values
    _dskCode = '';
    _dskName = '';
    _fidName = '';
    _scannedMilkType = '';
    _scannedSession = '';
    _quantity = 0.0;
    _fatPercentage = 0.0;
    _snfPercentage = 0.0;
    _ratePerLitre = 0.0;
    _totalAmount = 0.0;
    _scannedDate = DateTime.now();

    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase().trim();
      final rawLine = lines[i].trim();

      // DSK CODE
      if (line.contains('DSK CODE') || line.contains('DSK COD')) {
        final match = RegExp(r'\d{4,}').firstMatch(line);
        if (match != null) _dskCode = match.group(0) ?? '';
      }

      // DSK NAME
      if (line.contains('DSK NAME') || line.contains('DSK NAM')) {
        String name = rawLine
            .toUpperCase()
            .replaceAll(RegExp(r'DSK\s*NAM[E]?'), '')
            .replaceAll(':', '')
            .trim();
        if (name.isNotEmpty) _dskName = name;
      }

      // FID NAME
      if (line.contains('FID NAME') || line.contains('FID NAM')) {
        String name = rawLine
            .toUpperCase()
            .replaceAll(RegExp(r'FID\s*NAM[E]?'), '')
            .replaceAll(':', '')
            .trim();
        if (name.isNotEmpty) _fidName = name;
      }

      // MILK TYPE
      if (line.contains('MILK TYPE') || line.contains('MILK TYP')) {
        if (line.contains('BUFFALO')) {
          _scannedMilkType = 'BUFFALO';
        } else {
          _scannedMilkType = 'COW';
        }
      }

      // DATE and SESSION
      if (line.contains('DATE') || line.contains('DT')) {
        final dateMatch =
            RegExp(r'(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})')
                .firstMatch(line);
        if (dateMatch != null) {
          try {
            final day = int.parse(dateMatch.group(1)!);
            final month = int.parse(dateMatch.group(2)!);
            int year = int.parse(dateMatch.group(3)!);
            if (year < 100) year += 2000;
            _scannedDate = DateTime(year, month, day);
          } catch (_) {}
        }
        // Session detection
        if (RegExp(r'\bM\b').hasMatch(line) ||
            line.endsWith(' M') ||
            line.contains('MORNING')) {
          _scannedSession = 'Morning';
        } else if (RegExp(r'\bE\b').hasMatch(line) ||
            line.endsWith(' E') ||
            line.contains('EVENING')) {
          _scannedSession = 'Evening';
        }
      }

      // FAT and SNF on same line: %FAT:04.1 %SNF:07.7
      if (line.contains('FAT') && line.contains('SNF')) {
        final fatMatch =
            RegExp(r'FAT[:\s%]*(\d+\.?\d*)').firstMatch(line);
        final snfMatch =
            RegExp(r'SNF[:\s%]*(\d+\.?\d*)').firstMatch(line);
        if (fatMatch != null) {
          _fatPercentage =
              double.tryParse(fatMatch.group(1) ?? '0') ?? 0;
        }
        if (snfMatch != null) {
          _snfPercentage =
              double.tryParse(snfMatch.group(1) ?? '0') ?? 0;
        }
      } else {
        // FAT on separate line
        if (line.contains('%FAT') || line.startsWith('FAT')) {
          final match =
              RegExp(r'FAT[:\s%]*(\d+\.?\d*)').firstMatch(line);
          if (match != null) {
            _fatPercentage =
                double.tryParse(match.group(1) ?? '0') ?? 0;
          }
        }
        // SNF on separate line
        if (line.contains('%SNF') || line.startsWith('SNF')) {
          final match =
              RegExp(r'SNF[:\s%]*(\d+\.?\d*)').firstMatch(line);
          if (match != null) {
            _snfPercentage =
                double.tryParse(match.group(1) ?? '0') ?? 0;
          }
        }
      }

      // QTY and RT/LT on same line: QTY:017.64L RT/LT:36.58
      if (line.contains('QTY') && line.contains('RT')) {
        final qtyMatch =
            RegExp(r'QTY[:\s]*(\d+\.?\d*)').firstMatch(line);
        final rateMatch =
            RegExp(r'RT[/A-Z]*[:\s]*(\d+\.?\d*)').firstMatch(line);
        if (qtyMatch != null) {
          _quantity =
              double.tryParse(qtyMatch.group(1) ?? '0') ?? 0;
        }
        if (rateMatch != null) {
          _ratePerLitre =
              double.tryParse(rateMatch.group(1) ?? '0') ?? 0;
        }
      } else {
        // QTY on separate line
        if (line.contains('QTY') || line.contains('QUANTITY')) {
          final match =
              RegExp(r'(\d+\.?\d*)L?').firstMatch(line.replaceAll('QTY', '').replaceAll(':', '').trim());
          if (match != null) {
            _quantity =
                double.tryParse(match.group(1) ?? '0') ?? 0;
          }
        }
        // Rate on separate line
        if (line.contains('RT/LT') ||
            line.contains('RATE') ||
            line.contains('RT/L')) {
          final match = RegExp(r'(\d+\.?\d*)').firstMatch(
              line
                  .replaceAll(RegExp(r'RT[/A-Z]*'), '')
                  .replaceAll('RATE', '')
                  .replaceAll(':', '')
                  .trim());
          if (match != null) {
            _ratePerLitre =
                double.tryParse(match.group(1) ?? '0') ?? 0;
          }
        }
      }

      // Total amount (RS)
      if (line.startsWith('RS') ||
          line.contains('RS :') ||
          line.contains('AMT') ||
          line.contains('AMOUNT') ||
          line.contains('TOTAL')) {
        final matches = RegExp(r'(\d+\.?\d*)').allMatches(line);
        for (final match in matches) {
          final val = double.tryParse(match.group(0) ?? '0') ?? 0;
          if (val > 50) {
            _totalAmount = val;
            break;
          }
        }
      }
    }
  }

  // Save scanned milk record
  Future<void> _saveScannedRecord() async {
    if (_quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity not detected. Please use manual entry.'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(1);
      return;
    }
    await _saveMilkRecord(
      dskCode: _dskCode,
      dskName: _dskName,
      fidName: _fidName,
      milkType: _scannedMilkType.isEmpty ? 'COW' : _scannedMilkType,
      session: _scannedSession.isEmpty ? 'Morning' : _scannedSession,
      quantity: _quantity,
      fat: _fatPercentage,
      snf: _snfPercentage,
      rate: _ratePerLitre,
      total: _totalAmount,
      date: _scannedDate,
    );
  }

  // Save manual milk record
  Future<void> _saveManualRecord() async {
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }
    await _saveMilkRecord(
      dskCode: _dskCodeController.text.trim(),
      dskName: _dskNameController.text.trim(),
      fidName: _fidNameController.text.trim(),
      milkType: _milkType,
      session: _session,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      snf: double.tryParse(_snfController.text) ?? 0,
      rate: double.tryParse(_rateController.text) ?? 0,
      total: double.tryParse(_totalAmountController.text) ?? 0,
      date: _billDate,
    );
  }

  Future<void> _saveMilkRecord({
    required String dskCode,
    required String dskName,
    required String fidName,
    required String milkType,
    required String session,
    required double quantity,
    required double fat,
    required double snf,
    required double rate,
    required double total,
    required DateTime date,
  }) async {
    setState(() => _isSaving = true);
    try {
      final milk = MilkModel(
        id: const Uuid().v4(),
        animalId: '',
        animalName: fidName,
        morningAmount: session == 'Morning' ? quantity : 0,
        eveningAmount: session == 'Evening' ? quantity : 0,
        totalAmount: quantity,
        date: date,
        session: session,
        fatPercentage: fat,
        snfPercentage: snf,
        ratePerLitre: rate,
        totalAmount2: total,
        dskCode: dskCode,
        dskName: dskName,
        fidName: fidName,
        milkType: milkType,
        notes: '',
      );

      await _milkService.addMilkRecord(milk);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Milk record saved! 🥛'),
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

  // Pick date
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Milk Bill Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.document_scanner), text: 'Scan Bill'),
            Tab(icon: Icon(Icons.edit), text: 'Manual Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScanTab(),
          _buildManualTab(),
        ],
      ),
    );
  }

  // ── SCAN TAB ──
  Widget _buildScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image area
          GestureDetector(
            onTap: _showImagePicker,
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 2,
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner,
                            size: 70, color: Colors.blue.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap to Scan Bill',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Camera or Gallery',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Tips for better scan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tips for better scanning',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('• Place bill on flat dark surface'),
                Text('• Ensure good lighting'),
                Text('• Keep camera steady and close'),
                Text('• Make sure all text is visible'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scanning indicator
          if (_isScanning)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(width: 16),
                  Text(
                    'Reading bill...',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Scanned results
          if (_isScanned && _quantity > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Bill scanned successfully!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results card
            Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Extracted Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _billRow('📅 Date',
                      DateFormat('dd MMM yyyy').format(_scannedDate)),
                  _billRow('🕐 Session',
                      _scannedSession.isEmpty ? 'Not detected' : _scannedSession),
                  _billRow('🏢 DSK Name',
                      _dskName.isEmpty ? 'Not detected' : _dskName),
                  _billRow('👤 FID Name',
                      _fidName.isEmpty ? 'Not detected' : _fidName),
                  _billRow('🐄 Milk Type',
                      _scannedMilkType.isEmpty ? 'Not detected' : _scannedMilkType),
                  const Divider(),
                  _billRow('🥛 Quantity', '$_quantity L'),
                  _billRow('🧪 Fat %', '$_fatPercentage %'),
                  _billRow('🧪 SNF %', '$_snfPercentage %'),
                  _billRow('💰 Rate/Litre', '₹$_ratePerLitre'),
                  const Divider(),
                  _billRow('💵 Total Amount', '₹$_totalAmount',
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveScannedRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Milk Record',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Switch to manual
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _tabController.animateTo(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enter Manually Instead',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── MANUAL ENTRY TAB ──
  Widget _buildManualTab() {
    return SingleChildScrollView(
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
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
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

          // Milk Type selector
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
            isRequired: true,
          ),
          const SizedBox(height: 12),

          // Fat and SNF in row
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

          // Rate and Total in row
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
              onPressed: _isSaving ? null : _saveManualRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Milk Record',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
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
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _billRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}