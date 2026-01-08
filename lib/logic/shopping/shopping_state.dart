import 'package:equatable/equatable.dart';
import '../../data/models/shopping_list.dart';
import '../../data/models/shopping_item.dart';

enum ShoppingStatus { initial, loading, loaded, error }

enum ShoppingDetailStatus { initial, loading, loaded, error }

enum ArchiveStatus { initial, loading, loaded, error }

class ShoppingState extends Equatable {
  final ShoppingStatus status;
  final List<ShoppingList> shoppingLists;
  final Map<String, int> itemCounts;
  final Map<String, int> checkedCounts;
  final String? errorMessage;

  // Detail view state
  final ShoppingDetailStatus detailStatus;
  final ShoppingList? currentList;
  final List<ShoppingItem> currentListItems;

  // Archive state
  final ArchiveStatus archiveStatus;
  final List<ShoppingList> archivedLists;

  const ShoppingState({
    this.status = ShoppingStatus.initial,
    this.shoppingLists = const [],
    this.itemCounts = const {},
    this.checkedCounts = const {},
    this.errorMessage,
    this.detailStatus = ShoppingDetailStatus.initial,
    this.currentList,
    this.currentListItems = const [],
    this.archiveStatus = ArchiveStatus.initial,
    this.archivedLists = const [],
  });

  ShoppingState copyWith({
    ShoppingStatus? status,
    List<ShoppingList>? shoppingLists,
    Map<String, int>? itemCounts,
    Map<String, int>? checkedCounts,
    String? errorMessage,
    ShoppingDetailStatus? detailStatus,
    ShoppingList? currentList,
    List<ShoppingItem>? currentListItems,
    ArchiveStatus? archiveStatus,
    List<ShoppingList>? archivedLists,
  }) {
    return ShoppingState(
      status: status ?? this.status,
      shoppingLists: shoppingLists ?? this.shoppingLists,
      itemCounts: itemCounts ?? this.itemCounts,
      checkedCounts: checkedCounts ?? this.checkedCounts,
      errorMessage: errorMessage ?? this.errorMessage,
      detailStatus: detailStatus ?? this.detailStatus,
      currentList: currentList ?? this.currentList,
      currentListItems: currentListItems ?? this.currentListItems,
      archiveStatus: archiveStatus ?? this.archiveStatus,
      archivedLists: archivedLists ?? this.archivedLists,
    );
  }

  @override
  List<Object?> get props => [
    status,
    shoppingLists,
    itemCounts,
    checkedCounts,
    errorMessage,
    detailStatus,
    currentList,
    currentListItems,
    archiveStatus,
    archivedLists,
  ];
}
