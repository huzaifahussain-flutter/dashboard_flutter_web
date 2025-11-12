import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_cubit.dart';
import '../widgets/product_form_modal.dart';
import '../widgets/product_table.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductCubit, ProductState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (context, state) {
        // ✅ Update text only when Cubit searchQuery changes (not every build)
        _searchController.text = state.searchQuery;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      },

      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProductStatus.failure) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          final cubit = context.read<ProductCubit>();
          final categories = <String>{'All', ...state.allProducts.map((e) => e.category)}.toList();

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Padding(
              key: ValueKey(state.filteredProducts.length),
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ FILTER PANEL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // ✅ Search TextField (fixed)
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 200,
                            maxWidth: 400
                          ),
                          // width: 280,

                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by ID, name, category...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: cubit.search,
                          ),
                        ),

                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: state.selectedCategory,
                              items: categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (value) => cubit.filter(
                                category: value ?? 'All',
                                inStockOnly: state.inStockOnly,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: state.inStockOnly,
                              onChanged: (value) => cubit.filter(
                                category: state.selectedCategory,
                                inStockOnly: value ?? false,
                              ),
                            ),
                            const Text("In stock only"),
                          ],
                        ),

                        // ✅ Add Product button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            onPressed: () async {
                              final product = await showProductFormModal(context);
                              if (product != null) {
                                await cubit.addProduct(product);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Animated Table Section
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: 1,
                      child: ProductTable(
                        key: ValueKey(state.filteredProducts.map((p) => p.id).join(',')),
                        products: state.filteredProducts,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
