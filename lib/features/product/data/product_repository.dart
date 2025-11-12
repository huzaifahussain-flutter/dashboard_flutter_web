import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> fetchProducts();
  Future<void> deleteProduct(int id);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
}

class ProductRepositoryImpl implements ProductRepository {
  List<ProductModel> _cache = [];

  @override
  Future<List<ProductModel>> fetchProducts() async {
    if (_cache.isNotEmpty) return _cache;

    final response = await http
        .get(Uri.parse('https://dummyjson.com/products?limit=40'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final productsJson = decoded['products'] as List<dynamic>;
      _cache = productsJson
          .map((e) => ProductModel.fromDummyJson(e as Map<String, dynamic>))
          .toList();
      return _cache;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    _cache.removeWhere((p) => p.id == id);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final newId = (_cache.map((e) => e.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
    final newProduct = product.copyWith(id: newId);
    _cache.add(newProduct);
    return newProduct;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final index = _cache.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _cache[index] = product;
      return product;
    } else {
      throw Exception('Product not found');
    }
  }
}
