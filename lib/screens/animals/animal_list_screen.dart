import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/animal_model.dart';
import '../../providers/animal_provider.dart';
import 'add_animal_screen.dart';

class AnimalListScreen extends ConsumerWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Animal Records',
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
              builder: (context) => const AddAnimalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: animalsAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No animals added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first animal',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return _buildAnimalCard(context, ref, animal);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAnimalCard(
      BuildContext context, WidgetRef ref, AnimalModel animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Animal header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Animal image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: animal.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            animal.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Icon(
                              Icons.pets,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 16),
                // Animal details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            animal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (animal.isPregnant)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🤰 Pregnant',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.pink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tag: ${animal.tagNumber} • ${animal.animalType}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Breed: ${animal.breed} • ${animal.gender}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, animal),
                ),
              ],
            ),
          ),

          // Calving date if pregnant
          if (animal.isPregnant && animal.calvingDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_friendly,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Expected Calving: ${DateFormat('dd MMM yyyy').format(animal.calvingDate!)}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _daysUntilCalving(animal.calvingDate!),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _daysUntilCalving(DateTime calvingDate) {
    final now = DateTime.now();
    final difference = calvingDate.difference(now).inDays;
    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Today!';
    return '$difference days left';
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AnimalModel animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text('Are you sure you want to delete ${animal.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(animalServiceProvider)
                  .deleteAnimal(animal.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Animal deleted successfully'),
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