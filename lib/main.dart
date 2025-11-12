import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/product/data/product_repository.dart';
import 'features/product/presentation/blocs/product_cubit.dart';

void main() {
  // Suppress widget inspector JS debug conversion errors in web debug mode
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('LegacyJavaScriptObject')) {
      // ignore Flutter Web inspector crash spam
      return;
    }
    FlutterError.presentError(details);
  };

  final productRepository = ProductRepositoryImpl();
  runApp(MyApp(productRepository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;

  // ✅ Create router once only
  final _router = createAppRouter();

  MyApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) =>
          ProductCubit(productRepository)..fetchProducts(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Product Dashboard',
            debugShowCheckedModeBanner: false,

            // ✅ Theme changes dynamically
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,

            // ✅ Apply Material 3 here, not in constructor
            theme: AppTheme.lightTheme.copyWith(
              useMaterial3: true,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              useMaterial3: true,
            ),

            routerConfig: _router,
          );
        },
      ),
    );
  }
}
