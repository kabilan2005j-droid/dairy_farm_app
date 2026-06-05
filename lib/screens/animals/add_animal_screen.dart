import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/animal_provider.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _breedController = TextEditingController();
  String _gender = 'Female';
  String _animalType = 'Cow';
  bool _isPregnant = false;
  DateTime? _vaccinationDate;
  DateTime? _calvingDate;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // Show image source dialog
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
              'Select Image Source',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _imageSourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
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

  Widget _imageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  // Pick vaccination date
  Future<void> _pickVaccinationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _vaccinationDate = picked;
        // Auto calculate calving date
        int gestationDays = _animalType == 'Cow' ? 283 : 310;
        _calvingDate = picked.add(Duration(days: gestationDays));
      });
    }
  }

  // Save animal
  Future<void> _saveAnimal() async {
    if (_nameController.text.isEmpty ||
        _tagController.text.isEmpty ||
        _breedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_isPregnant && _vaccinationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter vaccination date for pregnant animal')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(addAnimalProvider).addAnimal(
            name: _nameController.text.trim(),
            tagNumber: _tagController.text.trim(),
            breed: _breedController.text.trim(),
            gender: _gender,
            animalType: _animalType,
            isPregnant: _isPregnant,
            lastVaccinationDate: _vaccinationDate,
            imageFile: _imageFile,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal added successfully! 🐄'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'Add Animal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            Center(
              child: GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: Colors.grey.shade400, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photo',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Animal Type
            const Text('Animal Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['Cow', 'Buffalo'].map((type) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _animalType = type;
                        // Recalculate calving date if vaccination date exists
                        if (_vaccinationDate != null) {
                          int gestationDays = type == 'Cow' ? 283 : 310;
                          _calvingDate = _vaccinationDate!
                              .add(Duration(days: gestationDays));
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _animalType == type
                            ? Colors.green
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _animalType == type
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          type,
                          style: TextStyle(
                            color: _animalType == type
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

            // Name field
            const Text('Animal Name',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter animal name',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tag Number
            const Text('Tag Number',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                hintText: 'Enter tag number',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breed
            const Text('Breed',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                hintText: 'Enter breed',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            const Text('Gender',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['Female', 'Male'].map((g) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _gender == g
                            ? Colors.green
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _gender == g
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color:
                                _gender == g ? Colors.white : Colors.black,
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

            // Pregnancy toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Is Pregnant?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                 Switch(
  value: _isPregnant,
  onChanged: (value) =>
      setState(() => _isPregnant = value),
  activeThumbColor: Colors.green,
  activeTrackColor: Colors.green.shade200,
), 
                ],
              ),
            ),

            // Pregnancy details
            if (_isPregnant) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pregnancy Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Vaccination date picker
                    GestureDetector(
                      onTap: _pickVaccinationDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.vaccines, color: Colors.green),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Vaccination Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _vaccinationDate != null
                                      ? DateFormat('dd MMM yyyy')
                                          .format(_vaccinationDate!)
                                      : 'Tap to select date',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Auto calculated calving date
                    if (_calvingDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.child_friendly,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expected Calving Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(_calvingDate!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '($_animalType gestation: ${_animalType == 'Cow' ? 283 : 310} days)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAnimal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Animal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}