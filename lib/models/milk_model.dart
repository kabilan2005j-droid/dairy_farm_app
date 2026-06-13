class MilkModel {
  final String id;
  final String animalId;
  final String animalName;
  final double morningAmount;
  final double eveningAmount;
  final double totalAmount;
  final DateTime date;
  final String session; // Morning or Evening
  final double fatPercentage;
  final double snfPercentage;
  final double ratePerLitre;
  final double totalAmount2;
  final String dskCode;
  final String dskName;
  final String fidName;
  final String milkType;
  final String notes;

  MilkModel({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.morningAmount,
    required this.eveningAmount,
    required this.totalAmount,
    required this.date,
    required this.session,
    required this.fatPercentage,
    required this.snfPercentage,
    required this.ratePerLitre,
    required this.totalAmount2,
    required this.dskCode,
    required this.dskName,
    required this.fidName,
    required this.milkType,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'morningAmount': morningAmount,
      'eveningAmount': eveningAmount,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'session': session,
      'fatPercentage': fatPercentage,
      'snfPercentage': snfPercentage,
      'ratePerLitre': ratePerLitre,
      'totalAmount2': totalAmount2,
      'dskCode': dskCode,
      'dskName': dskName,
      'fidName': fidName,
      'milkType': milkType,
      'notes': notes,
    };
  }

  factory MilkModel.fromMap(Map<String, dynamic> map) {
    return MilkModel(
      id: map['id'] ?? '',
      animalId: map['animalId'] ?? '',
      animalName: map['animalName'] ?? '',
      morningAmount: (map['morningAmount'] ?? 0).toDouble(),
      eveningAmount: (map['eveningAmount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      session: map['session'] ?? '',
      fatPercentage: (map['fatPercentage'] ?? 0).toDouble(),
      snfPercentage: (map['snfPercentage'] ?? 0).toDouble(),
      ratePerLitre: (map['ratePerLitre'] ?? 0).toDouble(),
      totalAmount2: (map['totalAmount2'] ?? 0).toDouble(),
      dskCode: map['dskCode'] ?? '',
      dskName: map['dskName'] ?? '',
      fidName: map['fidName'] ?? '',
      milkType: map['milkType'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
