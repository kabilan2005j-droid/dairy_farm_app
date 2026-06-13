import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milk_model.dart';

class MilkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add milk record
  Future<void> addMilkRecord(MilkModel milk) async {
    await _firestore
        .collection('milk_records')
        .doc(milk.id)
        .set(milk.toMap());
  }

  // Get all milk records stream
  Stream<List<MilkModel>> getMilkRecords() {
    return _firestore
        .collection('milk_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MilkModel.fromMap(doc.data()))
            .toList());
  }

  // Get milk records by animal
  Stream<List<MilkModel>> getMilkRecordsByAnimal(String animalId) {
    return _firestore
        .collection('milk_records')
        .where('animalId', isEqualTo: animalId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MilkModel.fromMap(doc.data()))
            .toList());
  }

  // Get today's total milk
  Stream<double> getTodayTotalMilk() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('milk_records')
        .where('date',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['totalAmount'] ?? 0).toDouble())
.fold(0.0, (total, amount) => total + amount));  }

  // Delete milk record
  Future<void> deleteMilkRecord(String id) async {
    await _firestore.collection('milk_records').doc(id).delete();
  }
}