part of 'product_cubit.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final String searchQuery;
  final String selectedCategory;
  final bool inStockOnly;
  final String? errorMessage;
  final int version; // Version counter to force state changes

  const ProductState({
    required this.status,
    required this.allProducts,
    required this.filteredProducts,
    required this.searchQuery,
    required this.selectedCategory,
    required this.inStockOnly,
    this.errorMessage,
    this.version = 0,
  });

  const ProductState.initial()
    : status = ProductStatus.initial,
      allProducts = const [],
      filteredProducts = const [],
      searchQuery = '',
      selectedCategory = 'All',
      inStockOnly = false,
      errorMessage = null,
      version = 0;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    String? searchQuery,
    String? selectedCategory,
    bool? inStockOnly,
    String? errorMessage,
    int? version,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      errorMessage: errorMessage ?? this.errorMessage,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allProducts,
    filteredProducts,
    searchQuery,
    selectedCategory,
    inStockOnly,
    errorMessage,
    version,
  ];
}
