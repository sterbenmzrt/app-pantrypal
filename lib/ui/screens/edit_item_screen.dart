import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/inventory/inventory_bloc.dart';
import '../../logic/inventory/inventory_event.dart';
import '../../data/models/inventory_item.dart';
import '../../core/utils/date_helpers.dart';

class EditItemScreen extends StatefulWidget {
  final InventoryItem item;

  const EditItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late DateTime _expiryDate;
  late DateTime _purchaseDate;

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
  void initState() {
    super.initState();
    // Pre-populate with existing item data
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text:
          widget.item.quantity.toInt() == widget.item.quantity
              ? widget.item.quantity.toInt().toString()
              : widget.item.quantity.toString(),
    );
    _unitController = TextEditingController(text: widget.item.unit);
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _selectedCategory = widget.item.category;
    _expiryDate = widget.item.expiryDate;
    _purchaseDate = widget.item.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item"),
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
              const SizedBox(height: 24),

              // 5. Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes (optional)",
                  hintText: "Add any notes about this item...",
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
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
          ),
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
      final updatedItem = InventoryItem(
        id: widget.item.id,
        name: _nameController.text,
        category: _selectedCategory,
        quantity: double.tryParse(_quantityController.text) ?? 1.0,
        unit: _unitController.text,
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        addedDate: widget.item.addedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<InventoryBloc>().add(UpdateInventoryItem(updatedItem));
      Navigator.pop(context, true); // Return true to indicate update
    }
  }
}
