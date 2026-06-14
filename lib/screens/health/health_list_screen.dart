import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/health_model.dart';
import '../../providers/health_provider.dart';
import 'add_health_screen.dart';
import 'edit_health_screen.dart';

class HealthListScreen extends ConsumerWidget {
  const HealthListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthRecordsProvider);
    final totalCostAsync = ref.watch(totalHealthCostProvider);
    final upcomingAsync = ref.watch(upcomingAppointmentsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'Health Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHealthScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: healthAsync.when(
        data: (records) {
          return Column(
            children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Records',
                        value: '${records.length}',
                        icon: Icons.medical_services,
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
                        title: 'Upcoming',
                        value: upcomingAsync.when(
                          data: (upcoming) =>
                              '${upcoming.length}',
                          loading: () => '...',
                          error: (_, _) => '0',
                        ),
                        icon: Icons.event,
                        isWarning: true,
                      ),
                    ),
                  ],
                ),
              ),

              // Upcoming appointments banner
              upcomingAsync.when(
                data: (upcoming) {
                  if (upcoming.isEmpty) return const SizedBox();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: Colors.orange.shade50,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.event,
                                color: Colors.orange,
                                size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Upcoming Appointments',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...upcoming.take(2).map((r) => Text(
                              '• ${r.animalName} — ${r.recordType} on ${DateFormat('dd MMM').format(r.nextAppointmentDate!)} (${r.daysUntilAppointment} days)',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            )),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),

              // Records list
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services,
                                size: 80,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No health records yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add first health record',
                              style: TextStyle(
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          return _buildHealthCard(
                              context, ref, records[index]);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.red),
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

  Widget _buildHealthCard(
      BuildContext context, WidgetRef ref, HealthModel record) {
    Color statusColor;
    switch (record.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Ongoing':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    Color typeColor;
    switch (record.recordType) {
      case 'Vaccination':
        typeColor = Colors.purple;
        break;
      case 'Treatment':
        typeColor = Colors.red;
        break;
      case 'Surgery':
        typeColor = Colors.orange;
        break;
      default:
        typeColor = Colors.blue;
    }

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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.red,
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
                            record.animalName,
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
                              color: typeColor
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              record.recordType,
                              style: TextStyle(
                                fontSize: 11,
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.medicationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(record.treatmentDate),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (record.vetName.isNotEmpty)
                        Text(
                          'Vet: ${record.vetName}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.red,
                              size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditHealthScreen(
                                        health: record),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20),
                          onPressed: () => _confirmDelete(
                              context, ref, record),
                        ),
                      ],
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
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _statItem('💊 Dosage',
                    record.dosage.isEmpty ? '-' : record.dosage),
                _divider(),
                _statItem('💰 Cost',
                    '₹${record.cost.toStringAsFixed(0)}',
                    isHighlight: true),
                _divider(),
                _statItem(
                  '📅 Next',
                  record.nextAppointmentDate != null
                      ? DateFormat('dd MMM')
                          .format(record.nextAppointmentDate!)
                      : 'Not set',
                  isWarning:
                      record.hasUpcomingAppointment,
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
                ? Colors.orange
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
      BuildContext context, WidgetRef ref, HealthModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
            'Are you sure you want to delete this health record for ${record.animalName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(healthServiceProvider)
                  .deleteHealthRecord(record.id);
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