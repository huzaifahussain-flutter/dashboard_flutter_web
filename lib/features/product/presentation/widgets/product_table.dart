import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/product_model.dart';

class ProductTable extends StatefulWidget {
  final List<ProductModel> products;
  const ProductTable({super.key, required this.products});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  bool sortAscending = true;
  int? sortColumnIndex;
  List<ProductModel>? _sortedProducts;

  @override
  void didUpdateWidget(ProductTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset sorting when products list changes (e.g., after deletion)
    // Compare by reference, length, and IDs to catch all changes
    final productsChanged = oldWidget.products != widget.products ||
        oldWidget.products.length != widget.products.length ||
        !_listsEqual(oldWidget.products, widget.products);
    
    if (productsChanged) {
      setState(() {
        _sortedProducts = null;
        sortColumnIndex = null;
        sortAscending = true;
      });
    }
  }

  bool _listsEqual(List<ProductModel> a, List<ProductModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  List<ProductModel> get _displayProducts {
    return _sortedProducts ?? widget.products;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    if (!isWide) {
      // Card/grid style for narrow screens
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _displayProducts.length,
        itemBuilder: (context, index) {
          final p = _displayProducts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('${p.category} • \$${p.price.toStringAsFixed(2)}'),
              trailing: Chip(
                label: Text(p.inStock ? 'In stock' : 'Out of stock'),
                color: WidgetStatePropertyAll(
                  p.inStock
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                ),
              ),
              onTap: () {
                context.go('/products/${p.id}');
              },
            ),
          );
        },
      );
    }

    final rows = _displayProducts.map((p) {
      return DataRow(
        cells: [
          DataCell(Text(p.id.toString())),
          DataCell(Text(p.name)),
          DataCell(Text(p.category)),
          DataCell(Text('\$${p.price.toStringAsFixed(2)}')),
          DataCell(
            Text(
              p.inStock ? 'In stock' : 'Out of stock',
              style: TextStyle(
                color: p.inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        onSelectChanged: (_) {
          context.go('/products/${p.id}');
        },
      );
    }).toList();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            columns: [
              DataColumn(
                label: const Text('ID'),
                onSort: (i, asc) => _sort<num>(i, asc, (p) => p.id),
              ),
              DataColumn(
                label: const Text('Name'),
                onSort: (i, asc) => _sort<String>(i, asc, (p) => p.name),
              ),
              DataColumn(
                label: const Text('Category'),
                onSort: (i, asc) => _sort<String>(i, asc, (p) => p.category),
              ),
              DataColumn(
                numeric: true,
                label: const Text('Price'),
                onSort: (i, asc) => _sort<num>(i, asc, (p) => p.price),
              ),
              const DataColumn(label: Text('Stock')),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }

  void _sort<T extends Comparable>(
      int columnIndex, bool ascending, T Function(ProductModel p) getField) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      // Create a new sorted list instead of mutating the original
      _sortedProducts = List<ProductModel>.from(widget.products);
      _sortedProducts!.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    });
  }
}
