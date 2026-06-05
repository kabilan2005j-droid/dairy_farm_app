import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/animal_model.dart';
import '../services/animal_service.dart';

// Animal service provider
final animalServiceProvider = Provider<AnimalService>((ref) {
  return AnimalService();
});

// Animals stream provider
final animalsProvider = StreamProvider<List<AnimalModel>>((ref) {
  return ref.watch(animalServiceProvider).getAnimals();
});

// Add animal provider
final addAnimalProvider = Provider((ref) {
  return AddAnimalNotifier(ref);
});

class AddAnimalNotifier {
  final Ref ref;
  AddAnimalNotifier(this.ref);

  Future<void> addAnimal({
    required String name,
    required String tagNumber,
    required String breed,
    required String gender,
    required String animalType,
    required bool isPregnant,
    DateTime? lastVaccinationDate,
    File? imageFile,
  }) async {
    final service = ref.read(animalServiceProvider);
    final id = const Uuid().v4();

    // Upload image if provided
    String imageUrl = '';
    if (imageFile != null) {
      imageUrl = await service.uploadImage(imageFile, id);
    }

    // Calculate calving date
    DateTime? calvingDate;
    if (isPregnant && lastVaccinationDate != null) {
      calvingDate = service.calculateCalvingDate(
        animalType,
        lastVaccinationDate,
      );
    }

    final animal = AnimalModel(
      id: id,
      name: name,
      tagNumber: tagNumber,
      breed: breed,
      gender: gender,
      animalType: animalType,
      imageUrl: imageUrl,
      isPregnant: isPregnant,
      lastVaccinationDate: lastVaccinationDate,
      calvingDate: calvingDate,
      createdAt: DateTime.now(),
    );

    await service.addAnimal(animal);
  }
}