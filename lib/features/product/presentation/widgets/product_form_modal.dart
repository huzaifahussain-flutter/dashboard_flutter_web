import 'package:flutter/material.dart';
import '../../model/product_model.dart';

Future<ProductModel?> showProductFormModal(
    BuildContext context, {
      ProductModel? existing,
    }) {
  return showGeneralDialog<ProductModel>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Product Form',
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (ctx, anim1, anim2) => Center(
      child: _ProductFormModal(existing: existing),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(scale: anim1, child: child),
      );
    },
  );
}

class _ProductFormModal extends StatefulWidget {
  final ProductModel? existing;
  const _ProductFormModal({this.existing});

  @override
  State<_ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<_ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _priceCtrl;
  bool _inStock = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _categoryCtrl = TextEditingController(text: widget.existing?.category ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existing?.price != null
          ? widget.existing!.price.toInt().toString()
          : '',
    );
    _inStock = widget.existing?.inStock ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _handleCancel() => Navigator.of(context, rootNavigator: true).pop(null);

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final price = int.parse(_priceCtrl.text.trim()).toDouble();
      final base = widget.existing ??
          ProductModel(id: 0, name: '', category: '', price: 0, inStock: true);

      final product = base.copyWith(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        price: price,
        inStock: _inStock,
      );

      Navigator.of(context, rootNavigator: true).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Edit Product' : 'Add Product',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameCtrl, 'Name *'),
                      const SizedBox(height: 12),
                      _buildTextField(_categoryCtrl, 'Category *'),
                      const SizedBox(height: 12),
                      _buildTextField(_priceCtrl, 'Price *', isInteger: true),
                      const SizedBox(height: 20),
                      _buildInStockSwitch(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _handleCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: _handleSave,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: Text(isEdit ? 'Save' : 'Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isInteger = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: isInteger ? TextInputType.number : TextInputType.text,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (isInteger) {
          final value = int.tryParse(v);
          if (value == null || value <= 0) return 'Enter valid number';
        }
        return null;
      },
    );
  }

  Widget _buildInStockSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'In Stock',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Switch(
          value: _inStock,
          onChanged: (val) => setState(() => _inStock = val),
          activeColor: Colors.green[400],
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[300],
        ),
      ],
    );
  }
}
