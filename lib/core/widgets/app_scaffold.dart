import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_cubit.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Don't show sidebar/topbar on login screen
    if (location == '/login') return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1100;
        final bool isTablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Scaffold(
          drawer: !isDesktop ? Drawer(child: _Sidebar()) : null,
          body: Row(
            children: [
              /// Sidebar - only visible on desktop/tablet
              if (isDesktop) AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 250,
                child: _Sidebar(),
              ),

              /// Main page
              Expanded(
                child: Column(
                  children: [
                    _TopBar(isDesktop: isDesktop),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 20 : 12),
                        color: Theme.of(context).colorScheme.surface,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class _TopBar extends StatelessWidget {
  final bool isDesktop;
  const _TopBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          Text(
            "Product Admin",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Theme toggle
          IconButton(
            tooltip: 'Toggle theme',
            icon: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Icon(
                  state.isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                );
              },
            ),
            onPressed: () => themeCubit.toggleTheme(),
          ),
        ],
      ),
    );
  }
}
class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    Widget navItem({required IconData icon, required String label, required String route}) {
      final selected = currentRoute == route;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: Icon(icon, size: 22),
          title: Text(label),
          selected: selected,
          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () => context.go(route),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard Menu",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          navItem(icon: Icons.grid_view_rounded, label: "Products", route: "/"),
          // navItem(icon: Icons.settings_outlined, label: "Settings", route: "/settings-not-implemented"),
          const Spacer(),
          Text(
            'Logged in as: Admin',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
