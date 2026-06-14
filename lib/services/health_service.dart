import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/health_model.dart';

class HealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add health record
  Future<void> addHealthRecord(HealthModel health) async {
    try {
      await _firestore
          .collection('health_records')
          .doc(health.id)
          .set(health.toMap());
      debugPrint('Health record saved successfully!');
    } catch (e) {
      debugPrint('Error saving health record: $e');
      rethrow;
    }
  }

  // Get all health records
  Stream<List<HealthModel>> getHealthRecords() {
    return _firestore
        .collection('health_records')
        .orderBy('treatmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthModel.fromMap(doc.data()))
            .toList());
  }

  // Get health records by animal
  Stream<List<HealthModel>> getHealthRecordsByAnimal(
      String animalId) {
    return _firestore
        .collection('health_records')
        .where('animalId', isEqualTo: animalId)
        .orderBy('treatmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthModel.fromMap(doc.data()))
            .toList());
  }

  // Get upcoming appointments
  Stream<List<HealthModel>> getUpcomingAppointments() {
    return getHealthRecords().map((records) => records
        .where((r) => r.hasUpcomingAppointment)
        .toList()
      ..sort((a, b) => a.nextAppointmentDate!
          .compareTo(b.nextAppointmentDate!)));
  }

  // Update health record
  Future<void> updateHealthRecord(HealthModel health) async {
    try {
      await _firestore
          .collection('health_records')
          .doc(health.id)
          .update(health.toMap());
      debugPrint('Health record updated successfully!');
    } catch (e) {
      debugPrint('Error updating health record: $e');
      rethrow;
    }
  }

  // Delete health record
  Future<void> deleteHealthRecord(String id) async {
    try {
      await _firestore
          .collection('health_records')
          .doc(id)
          .delete();
      debugPrint('Health record deleted successfully!');
    } catch (e) {
      debugPrint('Error deleting health record: $e');
      rethrow;
    }
  }

  // Get total health cost
  Stream<double> getTotalHealthCost() {
    return _firestore
        .collection('health_records')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['cost'] ?? 0).toDouble())
            .fold(0.0, (total, cost) => total + cost));
  }
}