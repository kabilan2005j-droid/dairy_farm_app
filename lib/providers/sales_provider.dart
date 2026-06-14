import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_model.dart';
import '../services/sales_service.dart';

// Sales service provider
final salesServiceProvider = Provider<SalesService>((ref) {
  return SalesService();
});

// All sales stream provider
final salesProvider = StreamProvider<List<SalesModel>>((ref) {
  return ref.watch(salesServiceProvider).getSales();
});

// Total income provider
final totalIncomeProvider = StreamProvider<double>((ref) {
  return ref.watch(salesServiceProvider).getTotalIncome();
});

// Pending amount provider
final pendingAmountProvider = StreamProvider<double>((ref) {
  return ref.watch(salesServiceProvider).getPendingAmount();
});