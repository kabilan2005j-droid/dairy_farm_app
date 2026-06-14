import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sales_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add sale
  Future<void> addSale(SalesModel sale) async {
    try {
      await _firestore
          .collection('sales')
          .doc(sale.id)
          .set(sale.toMap());
      debugPrint('Sale saved successfully!');
    } catch (e) {
      debugPrint('Error saving sale: $e');
      rethrow;
    }
  }

  // Get all sales stream
  Stream<List<SalesModel>> getSales() {
    return _firestore
        .collection('sales')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalesModel.fromMap(doc.data()))
            .toList());
  }

  // Update sale
  Future<void> updateSale(SalesModel sale) async {
    try {
      await _firestore
          .collection('sales')
          .doc(sale.id)
          .update(sale.toMap());
      debugPrint('Sale updated successfully!');
    } catch (e) {
      debugPrint('Error updating sale: $e');
      rethrow;
    }
  }

  // Delete sale
  Future<void> deleteSale(String id) async {
    try {
      await _firestore.collection('sales').doc(id).delete();
      debugPrint('Sale deleted successfully!');
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      rethrow;
    }
  }

  // Get total income
  Stream<double> getTotalIncome() {
    return _firestore
        .collection('sales')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['totalAmount'] ?? 0).toDouble())
            .fold(0.0, (total, amount) => total + amount));
  }

  // Get pending amount
  Stream<double> getPendingAmount() {
    return _firestore
        .collection('sales')
        .where('paymentStatus', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['totalAmount'] ?? 0).toDouble())
            .fold(0.0, (total, amount) => total + amount));
  }
}