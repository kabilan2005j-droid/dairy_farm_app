import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add feed
  Future<void> addFeed(FeedModel feed) async {
    try {
      await _firestore
          .collection('feed_inventory')
          .doc(feed.id)
          .set(feed.toMap());
      debugPrint('Feed saved successfully!');
    } catch (e) {
      debugPrint('Error saving feed: $e');
      rethrow;
    }
  }

  // Get all feeds stream
  Stream<List<FeedModel>> getFeeds() {
    return _firestore
        .collection('feed_inventory')
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedModel.fromMap(doc.data()))
            .toList());
  }

  // Update feed
  Future<void> updateFeed(FeedModel feed) async {
    try {
      await _firestore
          .collection('feed_inventory')
          .doc(feed.id)
          .update(feed.toMap());
      debugPrint('Feed updated successfully!');
    } catch (e) {
      debugPrint('Error updating feed: $e');
      rethrow;
    }
  }

  // Delete feed
  Future<void> deleteFeed(String id) async {
    try {
      await _firestore
          .collection('feed_inventory')
          .doc(id)
          .delete();
      debugPrint('Feed deleted successfully!');
    } catch (e) {
      debugPrint('Error deleting feed: $e');
      rethrow;
    }
  }

  // Get total feed cost
  Stream<double> getTotalFeedCost() {
    return _firestore
        .collection('feed_inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['totalCost'] ?? 0).toDouble())
            .fold(0.0, (total, cost) => total + cost));
  }

  // Get low stock feeds
  Stream<List<FeedModel>> getLowStockFeeds() {
    return getFeeds().map((feeds) =>
        feeds.where((feed) => feed.isLowStock).toList());
  }
}