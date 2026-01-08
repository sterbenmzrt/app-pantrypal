class ShoppingItem {
  final String id;
  final String listId;
  final String name;
  final bool isChecked;
  final String category;

  const ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    this.isChecked = false,
    this.category = 'Uncategorized',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'isChecked': isChecked ? 1 : 0,
      'category': category,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      listId: map['listId'] as String? ?? '',
      name: map['name'] as String,
      isChecked: (map['isChecked'] as int) == 1,
      category: map['category'] as String,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? listId,
    String? name,
    bool? isChecked,
    String? category,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
    );
  }
}
