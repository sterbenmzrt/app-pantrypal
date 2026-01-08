class ShoppingList {
  final String id;
  final String title;
  final DateTime shoppingDate;
  final DateTime createdAt;
  final bool isArchived;
  final DateTime? archivedAt;

  const ShoppingList({
    required this.id,
    required this.title,
    required this.shoppingDate,
    required this.createdAt,
    this.isArchived = false,
    this.archivedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'shoppingDate': shoppingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] as String,
      title: map['title'] as String,
      shoppingDate: DateTime.parse(map['shoppingDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as int?) == 1,
      archivedAt:
          map['archivedAt'] != null
              ? DateTime.parse(map['archivedAt'] as String)
              : null,
    );
  }

  ShoppingList copyWith({
    String? id,
    String? title,
    DateTime? shoppingDate,
    DateTime? createdAt,
    bool? isArchived,
    DateTime? archivedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      title: title ?? this.title,
      shoppingDate: shoppingDate ?? this.shoppingDate,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
