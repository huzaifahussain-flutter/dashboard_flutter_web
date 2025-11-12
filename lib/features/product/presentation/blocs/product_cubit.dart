import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// 👇 use "model" (singular) to match your folder name
import '../../data/product_repository.dart';
import '../../model/product_model.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit(this.repository) : super(const ProductState.initial());

  Future<void> fetchProducts() async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await repository.fetchProducts();
      emit(
        state.copyWith(
          status: ProductStatus.success,
          allProducts: products,
          filteredProducts: products,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }

  void search(String query) {
    final q = query.toLowerCase();
    final filtered = state.allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.id.toString().contains(q);
    }).toList();

    emit(state.copyWith(searchQuery: query, filteredProducts: filtered));
  }

  void filter({String? category, bool? inStockOnly}) {
    List<ProductModel> list = List.from(state.allProducts);

    // Category filter
    final newCategory = (category != null && category.isNotEmpty)
        ? category
        : state.selectedCategory;
    if (newCategory != 'All') {
      list = list.where((p) => p.category == newCategory).toList();
    }

    // In-stock filter
    final newInStockOnly = inStockOnly ?? state.inStockOnly;
    if (newInStockOnly) {
      list = list.where((p) => p.inStock).toList();
    }

    // Apply active search
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.id.toString().contains(q);
      }).toList();
    }

    emit(
      state.copyWith(
        selectedCategory: category ?? state.selectedCategory,
        inStockOnly: newInStockOnly,
        filteredProducts: list,
      ),
    );
  }

  Future<void> addProduct(ProductModel product) async {
    if (isClosed) return;

    final created = await repository.addProduct(product);
    final updatedAll = <ProductModel>[...state.allProducts, created];

    // Apply current filters to the updated list
    var filtered = <ProductModel>[];
    for (final p in updatedAll) {
      // Category filter
      if (state.selectedCategory != 'All' && p.category != state.selectedCategory) {
        continue;
      }

      // In-stock filter
      if (state.inStockOnly && !p.inStock) {
        continue;
      }

      // Search filter
      if (state.searchQuery.isNotEmpty) {
        final q = state.searchQuery.toLowerCase();
        final matches =
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.id.toString().contains(q);
        if (!matches) {
          continue;
        }
      }

      filtered.add(p);
    }

    // Emit new state with incremented version
    emit(
      ProductState(
        status: state.status,
        allProducts: updatedAll,
        filteredProducts: filtered,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        inStockOnly: state.inStockOnly,
        errorMessage: state.errorMessage,
        version: state.version + 1,
      ),
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    final updated = await repository.updateProduct(product);
    if (isClosed) return; // ✅ guard
    final updatedAll = state.allProducts.map((p) => p.id == updated.id ? updated : p).toList();
    emit(state.copyWith(allProducts: updatedAll, filteredProducts: updatedAll));
  }

  Future<void> deleteProduct(int id) async {
    await repository.deleteProduct(id);
    if (isClosed) return; // ✅ prevent emits after dispose

    // Remove product from allProducts - create new list instance
    final updatedAll = <ProductModel>[];
    for (final product in state.allProducts) {
      if (product.id != id) {
        updatedAll.add(product);
      }
    }

    // Apply current filters to the updated list
    var filtered = <ProductModel>[];
    for (final product in updatedAll) {
      // Category filter
      if (state.selectedCategory != 'All' && product.category != state.selectedCategory) {
        continue;
      }

      // In-stock filter
      if (state.inStockOnly && !product.inStock) {
        continue;
      }

      // Search filter
      if (state.searchQuery.isNotEmpty) {
        final q = state.searchQuery.toLowerCase();
        final matches =
            product.name.toLowerCase().contains(q) ||
            product.category.toLowerCase().contains(q) ||
            product.id.toString().contains(q);
        if (!matches) {
          continue;
        }
      }

      filtered.add(product);
    }

    // Emit new state with completely new list instances and incremented version
    emit(
      ProductState(
        status: state.status,
        allProducts: updatedAll,
        filteredProducts: filtered,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        inStockOnly: state.inStockOnly,
        errorMessage: state.errorMessage,
        version: state.version + 1, // Increment version to force state change
      ),
    );
  }

  ProductModel? getById(int id) {
    try {
      return state.allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
