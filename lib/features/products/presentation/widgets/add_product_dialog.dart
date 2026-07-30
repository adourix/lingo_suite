import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/categories_provider.dart';
import '../../../../core/providers/suppliers_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/products_repository_provider.dart';
import '../../../../core/providers/products_provider.dart';
import '../../../../core/providers/categories_repository_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Product? product;

  const AddProductDialog({super.key, this.product});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _sku = TextEditingController();
  final _costPrice = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _quantity = TextEditingController();
  final _minimumQuantity = TextEditingController(text: "0");
  final _notes = TextEditingController();
  final _imagePath = TextEditingController();

  int? _categoryId;
  int? _supplierId;

  bool _isActive = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    if (p != null) {
      _name.text = p.name;
      _barcode.text = p.barcode ?? "";
      _sku.text = p.sku ?? "";
      _costPrice.text = p.costPrice.toString();
      _sellingPrice.text = p.sellingPrice.toString();
      _quantity.text = p.quantity.toString();
      _minimumQuantity.text = p.minimumQuantity.toString();

      _notes.text = p.notes ?? "";
      _imagePath.text = p.imagePath ?? "";

      _categoryId = p.categoryId;
      _supplierId = p.supplierId;

      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _barcode.dispose();
    _sku.dispose();
    _costPrice.dispose();
    _sellingPrice.dispose();
    _quantity.dispose();
    _minimumQuantity.dispose();
    _notes.dispose();
    _imagePath.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    final repo = ref.read(categoriesRepositoryProvider);

    final id = await repo.insert(CategoriesCompanion.insert(name: name));

    ref.invalidate(categoriesProvider);

    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _categoryId = id;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final repo = ref.read(productsRepositoryProvider);
    final barcode = _barcode.text.trim();

    if (barcode.isNotEmpty) {
      final existing = await repo.getByBarcode(barcode);

      if (existing != null &&
          (widget.product == null || existing.id != widget.product!.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcode already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() => _loading = false);
        return;
      }
    }
    final companion = ProductsCompanion(
      name: Value(_name.text.trim()),
      barcode: Value(
        _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      ),
      sku: Value(_sku.text.trim().isEmpty ? null : _sku.text.trim()),
      categoryId: Value(_categoryId),
      supplierId: Value(_supplierId),
      costPrice: Value(double.parse(_costPrice.text)),
      sellingPrice: Value(double.parse(_sellingPrice.text)),
      quantity: Value(int.parse(_quantity.text)),
      minimumQuantity: Value(int.parse(_minimumQuantity.text)),
      imagePath: Value(
        _imagePath.text.trim().isEmpty ? null : _imagePath.text.trim(),
      ),
      isActive: Value(_isActive),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      updatedAt: Value(DateTime.now()),
    );

    try {
      if (widget.product == null) {
        await repo.insert(companion);
      } else {
        await repo.update(widget.product!.id, companion);
      }

      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final suppliers = ref.watch(suppliersProvider);
    return AlertDialog(
      title: Text(widget.product == null ? "Add Product" : "Edit Product"),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(label: "Product Name", controller: _name),
                _field(label: "Barcode", controller: _barcode),
                _field(label: "SKU", controller: _sku),
                categories.when(
                  data: (items) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: items.any((e) => e.id == _categoryId)
                                ? _categoryId
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('No Category'),
                              ),
                              ...items.map(
                                (e) => DropdownMenuItem<int?>(
                                  value: e.id,
                                  child: Text(e.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _categoryId = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addCategory,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, _) => const SizedBox(),
                ),
                suppliers.when(
                  data: (items) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<int?>(
                      initialValue: _supplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('No Supplier'),
                        ),
                        ...items.map(
                          (e) => DropdownMenuItem<int?>(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _supplierId = value);
                      },
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, _) => const SizedBox(),
                ),
                _field(
                  label: "Cost Price",
                  controller: _costPrice,
                  keyboardType: TextInputType.number,
                ),
                _field(
                  label: "Selling Price",
                  controller: _sellingPrice,
                  keyboardType: TextInputType.number,
                ),
                _field(
                  label: "Quantity",
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                ),
                _field(label: "Image Path", controller: _imagePath),
                SwitchListTile(
                  value: _isActive,
                  title: const Text("Active"),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                ),
                _field(
                  label: "Minimum Quantity",
                  controller: _minimumQuantity,
                  keyboardType: TextInputType.number,
                ),
                _field(label: "Notes", controller: _notes),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product == null ? "Save" : "Update"),
        ),
      ],
    );
  }
}
