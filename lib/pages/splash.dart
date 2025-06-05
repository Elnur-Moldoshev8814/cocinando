import 'package:cocinando/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/button_widgets.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 87, 247, 1.0),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 95),
                        Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/images/logo/splash_logo.svg',
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 44),
                              Column(
                                children: [
                                  const Text(
                                    "Cocinando\nla Semana",
                                    style: AppTextStyles.title_64,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  SvgPicture.asset('assets/images/icons/Menu_text.svg'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            CustomButton(
                              icon: Icons.arrow_forward,
                              textColor: const Color.fromRGBO(0, 87, 248, 1),
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              onPressed: () {
                                context.go('/calendario/meses');
                              },
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: "Términos de Uso",
                                    color: const Color.fromRGBO(51, 121, 249, 1),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomButton(
                                    text: "Política de Privacidad",
                                    color: const Color.fromRGBO(51, 121, 249, 1),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 34),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
