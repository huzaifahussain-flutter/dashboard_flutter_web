import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../model/product_model.dart';
import '../blocs/product_cubit.dart';
import '../widgets/product_form_modal.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final cubit = context.read<ProductCubit>();
        final product = cubit.getById(widget.productId);

        // If product not found → redirect back
        if (product == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/products');
          });
          return const SizedBox.shrink();
        }

        return LayoutBuilder(builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE + ACTIONS BAR
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => context.pop(),
                            ),
                            Text(
                              "Product Details",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Wrap(
                              spacing: 10,
                              children: [
                                FilledButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit"),
                                  onPressed: () async {
                                    final updated = await showProductFormModal(
                                      context,
                                      existing: product,
                                    );
                                    if (updated != null) {
                                      await cubit.updateProduct(updated);
                                    }
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  label: const Text("Delete"),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Delete Product"),
                                        content: const Text(
                                            "Are you sure you want to delete this product?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && context.mounted) {
                                      await cubit.deleteProduct(product.id);
                                      context.pop();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// CARD SECTION
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: Column(
                                    children: [
                                      _InfoRow(label: "ID", value: product.id.toString()),
                                      _InfoRow(label: "Name", value: product.name),
                                      _InfoRow(label: "Category", value: product.category),
                                      _InfoRow(
                                        label: "Price",
                                        value: "\$${product.price.toStringAsFixed(2)}",
                                      ),
                                      _InfoRow(
                                        label: "Stock status",
                                        value: product.inStock
                                            ? "✅ In stock"
                                            : "❌ Out of stock",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

/// ✅ Improved InfoRow with better spacing and typography
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
