import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_model.dart';
import '../services/feed_service.dart';

// Feed service provider
final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService();
});

// All feeds stream provider
final feedsProvider = StreamProvider<List<FeedModel>>((ref) {
  return ref.watch(feedServiceProvider).getFeeds();
});

// Total feed cost provider
final totalFeedCostProvider = StreamProvider<double>((ref) {
  return ref.watch(feedServiceProvider).getTotalFeedCost();
});

// Low stock feeds provider
final lowStockFeedsProvider = StreamProvider<List<FeedModel>>((ref) {
  return ref.watch(feedServiceProvider).getLowStockFeeds();
});