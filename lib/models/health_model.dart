class HealthModel {
  final String id;
  final String animalId;
  final String animalName;
  final String recordType;
  final String diseaseName;
  final String medicationName;
  final String dosage;
  final String vetName;
  final double cost;
  final DateTime treatmentDate;
  final DateTime? nextAppointmentDate;
  final String status;
  final String notes;

  HealthModel({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.recordType,
    required this.diseaseName,
    required this.medicationName,
    required this.dosage,
    required this.vetName,
    required this.cost,
    required this.treatmentDate,
    this.nextAppointmentDate,
    required this.status,
    required this.notes,
  });

  bool get hasUpcomingAppointment =>
      nextAppointmentDate != null &&
      nextAppointmentDate!.isAfter(DateTime.now());

  int get daysUntilAppointment => nextAppointmentDate != null
      ? nextAppointmentDate!.difference(DateTime.now()).inDays
      : -1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'recordType': recordType,
      'diseaseName': diseaseName,
      'medicationName': medicationName,
      'dosage': dosage,
      'vetName': vetName,
      'cost': cost,
      'treatmentDate': treatmentDate.toIso8601String(),
      'nextAppointmentDate':
          nextAppointmentDate?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory HealthModel.fromMap(Map<String, dynamic> map) {
    return HealthModel(
      id: map['id'] ?? '',
      animalId: map['animalId'] ?? '',
      animalName: map['animalName'] ?? '',
      recordType: map['recordType'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      vetName: map['vetName'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      treatmentDate: DateTime.parse(map['treatmentDate']),
      nextAppointmentDate: map['nextAppointmentDate'] != null
          ? DateTime.parse(map['nextAppointmentDate'])
          : null,
      status: map['status'] ?? 'Completed',
      notes: map['notes'] ?? '',
    );
  }
}