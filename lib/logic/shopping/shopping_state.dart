import 'package:equatable/equatable.dart';
import '../../data/models/shopping_item.dart';

enum ShoppingStatus { initial, loading, loaded, error }

class ShoppingState extends Equatable {
  final ShoppingStatus status;
  final List<ShoppingItem> items;
  final List<ShoppingItem> suggestions;
  final String? errorMessage;

  const ShoppingState({
    this.status = ShoppingStatus.initial,
    this.items = const [],
    this.suggestions = const [],
    this.errorMessage,
  });

  ShoppingState copyWith({
    ShoppingStatus? status,
    List<ShoppingItem>? items,
    List<ShoppingItem>? suggestions,
    String? errorMessage,
  }) {
    return ShoppingState(
      status: status ?? this.status,
      items: items ?? this.items,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, suggestions, errorMessage];
}
