import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/animal_model.dart';

class AnimalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Calculate calving date based on animal type
  DateTime? calculateCalvingDate(String animalType, DateTime vaccinationDate) {
    int gestationDays = animalType == 'Cow' ? 283 : 310;
    return vaccinationDate.add(Duration(days: gestationDays));
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String animalId) async {
    final ref = _storage.ref().child('animals/$animalId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Add animal to Firestore
  Future<void> addAnimal(AnimalModel animal) async {
    await _firestore
        .collection('animals')
        .doc(animal.id)
        .set(animal.toMap());
  }

  // Get all animals stream
  Stream<List<AnimalModel>> getAnimals() {
    return _firestore
        .collection('animals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnimalModel.fromMap(doc.data()))
            .toList());
  }

  // Delete animal
  Future<void> deleteAnimal(String animalId) async {
    await _firestore.collection('animals').doc(animalId).delete();
    try {
      await _storage.ref().child('animals/$animalId.jpg').delete();
    } catch (e) {
      // Image may not exist
    }
  }

  // Update animal
  Future<void> updateAnimal(AnimalModel animal) async {
    await _firestore
        .collection('animals')
        .doc(animal.id)
        .update(animal.toMap());
  }
}