import 'package:flutter/material.dart';
import 'router.dart';
void main() {
  runApp(const Cocinando());
}

class Cocinando extends StatelessWidget {
  const Cocinando({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cocinando la Semana: Menú',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // color: Colors.white,
    );
  }
}
