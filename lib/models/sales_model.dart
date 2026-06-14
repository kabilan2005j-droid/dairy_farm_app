class SalesModel {
  final String id;
  final String buyerName;
  final String milkType;
  final double quantity;
  final double ratePerLitre;
  final double totalAmount;
  final DateTime date;
  final String session;
  final String paymentStatus; // Paid or Pending
  final String notes;

  SalesModel({
    required this.id,
    required this.buyerName,
    required this.milkType,
    required this.quantity,
    required this.ratePerLitre,
    required this.totalAmount,
    required this.date,
    required this.session,
    required this.paymentStatus,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerName': buyerName,
      'milkType': milkType,
      'quantity': quantity,
      'ratePerLitre': ratePerLitre,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'session': session,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'] ?? '',
      buyerName: map['buyerName'] ?? '',
      milkType: map['milkType'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      ratePerLitre: (map['ratePerLitre'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      session: map['session'] ?? '',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      notes: map['notes'] ?? '',
    );
  }
}