import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../widgets/app_scaffold.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'products',
            builder: (context, state) => const ProductListPage(),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProductListPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) {
                    // fallback to list if invalid
                    return const NoTransitionPage(child: ProductListPage());
                  }
                  return NoTransitionPage(child: ProductDetailPage(productId: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/products/:id',
            name: 'product-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(body: Center(child: Text('Invalid product ID')));
              }
              return ProductDetailPage(productId: id);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Simple mock auth: if not "logged in", stay on /login
      // For now we treat any navigation from /login as "logged in"
      final isLoggingIn = state.matchedLocation == '/login';

      // presses "Login".
      return null;
    },
  );
}
