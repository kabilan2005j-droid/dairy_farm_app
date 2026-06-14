import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milk_model.dart';
import '../services/milk_service.dart';

// Milk service provider
final milkServiceProvider = Provider<MilkService>((ref) {
  return MilkService();
});

// All milk records stream provider
final milkRecordsProvider = StreamProvider<List<MilkModel>>((ref) {
  return ref.watch(milkServiceProvider).getMilkRecords();
});

// Today's total milk provider
final todayTotalMilkProvider = StreamProvider<double>((ref) {
  return ref.watch(milkServiceProvider).getTodayTotalMilk();
});