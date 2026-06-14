class FeedModel {
  final String id;
  final String feedName;
  final String feedType;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalCost;
  final double lowStockThreshold;
  final String supplierName;
  final DateTime purchaseDate;
  final String notes;

  FeedModel({
    required this.id,
    required this.feedName,
    required this.feedType,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalCost,
    required this.lowStockThreshold,
    required this.supplierName,
    required this.purchaseDate,
    required this.notes,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feedName': feedName,
      'feedType': feedType,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalCost': totalCost,
      'lowStockThreshold': lowStockThreshold,
      'supplierName': supplierName,
      'purchaseDate': purchaseDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory FeedModel.fromMap(Map<String, dynamic> map) {
    return FeedModel(
      id: map['id'] ?? '',
      feedName: map['feedName'] ?? '',
      feedType: map['feedType'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'kg',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      lowStockThreshold: (map['lowStockThreshold'] ?? 10).toDouble(),
      supplierName: map['supplierName'] ?? '',
      purchaseDate: DateTime.parse(map['purchaseDate']),
      notes: map['notes'] ?? '',
    );
  }
}