import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_model.dart';
import '../services/health_service.dart';

// Health service provider
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

// All health records provider
final healthRecordsProvider =
    StreamProvider<List<HealthModel>>((ref) {
  return ref.watch(healthServiceProvider).getHealthRecords();
});

// Upcoming appointments provider
final upcomingAppointmentsProvider =
    StreamProvider<List<HealthModel>>((ref) {
  return ref
      .watch(healthServiceProvider)
      .getUpcomingAppointments();
});

// Total health cost provider
final totalHealthCostProvider = StreamProvider<double>((ref) {
  return ref.watch(healthServiceProvider).getTotalHealthCost();
});