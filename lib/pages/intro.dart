import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  bool _start = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _start = true;
      });
    });

    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Ждём анимацию
    await Future.delayed(const Duration(milliseconds: 1600));

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      context.go('/'); // Первый запуск — показываем Splash
    } else {
      context.go('/calendario/meses'); // Не первый запуск — сразу в календарь
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 87, 248, 1),
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: _start ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final alignment = Alignment.lerp(
            Alignment.bottomCenter,
            Alignment.topCenter,
            value,
          )!;
          final opacity = value;
          final scale = lerpDouble(1.0, 0.67, value)!;

          return Align(
            alignment: alignment,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.only(top: 84.0),
                  child: SvgPicture.asset(
                    'assets/images/logo/splash_logo.svg',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
