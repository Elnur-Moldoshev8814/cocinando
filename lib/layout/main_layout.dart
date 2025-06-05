import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cocinando/widgets/custom_nav_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  static final List<String> _routes = [
    '/calendario/meses',
    '/recetas',
    '/configuraciones'
  ];

  int _getCurrentIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith('/calendario')) return 0;
    if (uri.startsWith('/recetas')) return 1;
    if (uri.startsWith('/configuraciones')) return 2;
    return 0; // по умолчанию календарь
  }


  void _onItemTapped(BuildContext context, int index) {
    final selectedRoute = _routes[index];
    context.go(selectedRoute); // используем go для замены текущего маршрута
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // или нужный цвет
        statusBarIconBrightness: Brightness.dark, // светлые иконки
        statusBarBrightness: Brightness.light, // для iOS
    ),
    child: Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
      ),
    ));
  }
}
