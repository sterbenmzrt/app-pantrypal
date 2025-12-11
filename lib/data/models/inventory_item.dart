import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final DateTime addedDate;
  final String? notes;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    required this.addedDate,
    this.notes,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    DateTime? addedDate,
    String? notes,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      unit: map['unit'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      addedDate: DateTime.parse(map['addedDate']),
      notes: map['notes'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    quantity,
    unit,
    purchaseDate,
    expiryDate,
    addedDate,
    notes,
  ];
}
