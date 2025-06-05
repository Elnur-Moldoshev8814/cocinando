import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/button_widgets.dart';

class Recipes extends StatelessWidget {
  const Recipes({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "Dietético",
      "Vegetariano",
      "Rápido y Fácil",
      "Casero Clásico",
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
      statusBarColor: const Color.fromRGBO(255, 255, 255, 0),
      statusBarIconBrightness: Brightness.dark, // светлые иконки
      statusBarBrightness: Brightness.light, // для iOS
    ),
    child: Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: categories
                .map((category) => Expanded(
              child: BigButton(
                text: category,
                onPressed: () => context.go('/recetas/$category'), // заменили на go
              ),
            ))
                .toList(),
          ),
        ),
      ),
    )
    );
  }
}
