import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/health_model.dart';
import '../../providers/health_provider.dart';
import '../../providers/animal_provider.dart';

class EditHealthScreen extends ConsumerStatefulWidget {
  final HealthModel health;
  const EditHealthScreen({super.key, required this.health});

  @override
  ConsumerState<EditHealthScreen> createState() =>
      _EditHealthScreenState();
}

class _EditHealthScreenState
    extends ConsumerState<EditHealthScreen> {
  late TextEditingController _diseaseController;
  late TextEditingController _medicationController;
  late TextEditingController _dosageController;
  late TextEditingController _vetNameController;
  late TextEditingController _costController;
  late TextEditingController _notesController;
  late String _recordType;
  late String _status;
  late String _selectedAnimalId;
  late String _selectedAnimalName;
  late DateTime _treatmentDate;
  DateTime? _nextAppointmentDate;
  bool _isSaving = false;

  final List<String> _recordTypes = [
    'Vaccination', 'Treatment', 'Checkup',
    'Deworming', 'Surgery', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _diseaseController =
        TextEditingController(text: widget.health.diseaseName);
    _medicationController = TextEditingController(
        text: widget.health.medicationName);
    _dosageController =
        TextEditingController(text: widget.health.dosage);
    _vetNameController =
        TextEditingController(text: widget.health.vetName);
    _costController = TextEditingController(
        text: widget.health.cost.toString());
    _notesController =
        TextEditingController(text: widget.health.notes);
    _recordType = widget.health.recordType;
    _status = widget.health.status;
    _selectedAnimalId = widget.health.animalId;
    _selectedAnimalName = widget.health.animalName;
    _treatmentDate = widget.health.treatmentDate;
    _nextAppointmentDate = widget.health.nextAppointmentDate;
  }

  @override
  void dispose() {
    _diseaseController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _vetNameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTreatmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _treatmentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Colors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _treatmentDate = picked);
  }

  Future<void> _pickNextAppointmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextAppointmentDate ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Colors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _nextAppointmentDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (_medicationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter medication name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedHealth = HealthModel(
        id: widget.health.id,
        animalId: _selectedAnimalId,
        animalName: _selectedAnimalName,
        recordType: _recordType,
        diseaseName: _diseaseController.text.trim(),
        medicationName: _medicationController.text.trim(),
        dosage: _dosageController.text.trim(),
        vetName: _vetNameController.text.trim(),
        cost: double.tryParse(_costController.text) ?? 0,
        treatmentDate: _treatmentDate,
        nextAppointmentDate: _nextAppointmentDate,
        status: _status,
        notes: _notesController.text.trim(),
      );

      await ref
          .read(healthServiceProvider)
          .updateHealthRecord(updatedHealth);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health record updated! ✅'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Health Record',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal selector
            const Text('Select Animal *',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            animalsAsync.when(
              data: (animals) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedAnimalId.isEmpty
                        ? null
                        : _selectedAnimalId,
                    hint: const Text('Select an animal'),
                    items: animals.map((animal) {
                      return DropdownMenuItem<String>(
                        value: animal.id,
                        child: Text(
                          '${animal.name} (${animal.animalType})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final animal = animals
                            .firstWhere((a) => a.id == value);
                        setState(() {
                          _selectedAnimalId = value;
                          _selectedAnimalName = animal.name;
                        });
                      }
                    },
                  ),
                ),
              ),
              loading: () =>
                  const CircularProgressIndicator(),
              error: (_, _) =>
                  const Text('Error loading animals'),
            ),
            const SizedBox(height: 16),

            // Record Type
            const Text('Record Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recordTypes.map((type) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _recordType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _recordType == type
                          ? Colors.red
                          : Colors.grey.shade100,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: _recordType == type
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: _recordType == type
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

            // Treatment Date
            GestureDetector(
              onTap: _pickTreatmentDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.red),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('Treatment Date',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(_treatmentDate),
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
            const SizedBox(height: 12),

            // Disease
            _buildTextField(
              controller: _diseaseController,
              label: 'Disease / Condition',
              hint: 'e.g. Foot and Mouth Disease',
              icon: Icons.sick,
            ),
            const SizedBox(height: 12),

            // Medication
            _buildTextField(
              controller: _medicationController,
              label: 'Medication / Vaccine *',
              hint: 'e.g. FMD Vaccine',
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 12),

            // Dosage and Cost
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _dosageController,
                    label: 'Dosage',
                    hint: 'e.g. 5ml',
                    icon: Icons.science,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _costController,
                    label: 'Cost (₹)',
                    hint: 'e.g. 500',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vet name
            _buildTextField(
              controller: _vetNameController,
              label: 'Veterinarian Name',
              hint: 'Enter vet name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Status
            const Text('Status',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                'Completed',
                'Ongoing',
                'Scheduled'
              ].map((s) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: _status == s
                            ? Colors.red
                            : Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: _status == s
                              ? Colors.red
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: _status == s
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Next appointment
            GestureDetector(
              onTap: _pickNextAppointmentDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.red),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Appointment (Optional)',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),
                        Text(
                          _nextAppointmentDate != null
                              ? DateFormat('dd MMM yyyy').format(
                                  _nextAppointmentDate!)
                              : 'Tap to set next appointment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                _nextAppointmentDate != null
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_nextAppointmentDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.red),
                        onPressed: () => setState(
                            () => _nextAppointmentDate = null),
                      )
                    else
                      const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                  ],
                ),
              ),
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

            // Update button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Update Health Record',
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
}