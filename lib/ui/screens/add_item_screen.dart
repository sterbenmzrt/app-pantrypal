import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_event.dart';
import '../../data/models/inventory_item.dart';
import '../../core/utils/date_helpers.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: "1",
  );
  final TextEditingController _unitController = TextEditingController(
    text: "items",
  );

  String _selectedCategory = "Dairy";
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  DateTime _purchaseDate = DateTime.now();

  final List<String> _categories = [
    "Dairy",
    "Meat & Protein",
    "Vegetables",
    "Fruits",
    "Spices & Seasonings",
    "Pantry / Dry Goods",
    "Beverages",
    "Freezer",
    "Other",
  ];

  // Material Icons for each category
  final Map<String, IconData> _categoryIcons = {
    "Dairy": Icons.egg_alt,
    "Meat & Protein": Icons.kebab_dining,
    "Vegetables": Icons.eco,
    "Fruits": Icons.apple,
    "Spices & Seasonings": Icons.scatter_plot,
    "Pantry / Dry Goods": Icons.kitchen,
    "Beverages": Icons.local_drink,
    "Freezer": Icons.ac_unit,
    "Other": Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: const Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  hintText: "e.g., Organic Milk",
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) => value!.isEmpty ? "Can't be empty" : null,
              ),
              const SizedBox(height: 16),

              // 2. Quantity & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity",
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: "Unit",
                        hintText: "items, kg",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Category Chips
              Text("Category", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return FilterChip(
                        avatar: Icon(
                          _categoryIcons[cat],
                          size: 18,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                            // Smart Expiry Logic
                            switch (cat) {
                              case "Dairy":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 7),
                                );
                                break;
                              case "Meat & Protein":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 3),
                                );
                                break;
                              case "Vegetables":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 5),
                                );
                                break;
                              case "Fruits":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 7),
                                );
                                break;
                              case "Spices & Seasonings":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 180),
                                );
                                break;
                              case "Pantry / Dry Goods":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 30),
                                );
                                break;
                              case "Beverages":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 14),
                                );
                                break;
                              case "Freezer":
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 90),
                                );
                                break;
                              case "Other":
                              default:
                                _expiryDate = DateTime.now().add(
                                  const Duration(days: 7),
                                );
                            }
                          });
                        },
                        selectedColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Dates
              _buildDatePicker(
                context,
                "Purchase Date",
                _purchaseDate,
                (date) => setState(() => _purchaseDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                context,
                "Expiry Date",
                _expiryDate,
                (date) => setState(() => _expiryDate = date),
                isExpiry: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onSelect, {
    bool isExpiry = false,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.calendar_today,
            color: isExpiry ? const Color(0xFFFFC107) : null,
          ), // Warning color for expiry
          filled: true,
          fillColor: isExpiry ? const Color(0xFFFFFDE7) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          DateHelpers.formatDate(date),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = InventoryItem(
        id: const Uuid().v4(),
        name: _nameController.text,
        category: _selectedCategory,
        quantity: double.tryParse(_quantityController.text) ?? 1.0,
        unit: _unitController.text,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        addedDate: DateTime.now(),
        notes: "",
      );

      context.read<InventoryBloc>().add(AddInventoryItem(item));
      Navigator.pop(context);
    }
  }
}
