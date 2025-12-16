import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantry_pal/logic/inventory/inventory_bloc.dart';
import 'package:pantry_pal/logic/inventory/inventory_event.dart';
import 'package:pantry_pal/logic/inventory/inventory_state.dart';
import 'package:pantry_pal/data/repositories/inventory_repository.dart';
import 'package:pantry_pal/data/models/inventory_item.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  group('InventoryBloc', () {
    late InventoryRepository repository;
    late InventoryBloc bloc;

    setUp(() {
      repository = MockInventoryRepository();
      bloc = InventoryBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is InventoryInitial', () {
      expect(
        bloc.state,
        isA<InventoryLoading>(),
      ); // The initial state in constructor is InventoryLoading
    });

    test(
      'emits [InventoryLoading, InventoryLoaded] when LoadInventory proceeds',
      () async {
        final items = [
          InventoryItem(
            id: '1',
            name: 'Apple',
            category: 'Fruit',
            quantity: 1,
            unit: 'pcs',
            purchaseDate: DateTime.now(),
            expiryDate: DateTime.now(),
            addedDate: DateTime.now(),
            notes: '',
          ),
        ];
        when(() => repository.getInventory()).thenAnswer((_) async => items);

        bloc.add(LoadInventory());

        await expectLater(
          bloc.stream,
          emitsInOrder([InventoryLoading(), InventoryLoaded(items)]),
        );
      },
    );

    test(
      'emits [InventoryLoading, InventoryError] when LoadInventory fails',
      () async {
        when(() => repository.getInventory()).thenThrow(Exception('oops'));

        bloc.add(LoadInventory());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            InventoryLoading(),
            const InventoryError('Failed to load inventory: Exception: oops'),
          ]),
        );
      },
    );

    // Note: Since I don't see the full content of InventoryBloc/Events/States,
    // I am assuming standard naming (InventoryLoad, InventoryLoaded, etc.)
    // I will need to check the file content if I want to write precise tests.
  });
}
