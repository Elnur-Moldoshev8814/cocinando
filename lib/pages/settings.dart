import 'package:cocinando/pages/subscription_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/button_widgets.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool status = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchValue(); // загружаем сохранённое значение
  }

  void _loadSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      status = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  void _saveSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // или нужный цвет
        statusBarIconBrightness: Brightness.dark, // светлые иконки
        statusBarBrightness: Brightness.light, // для iOS
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: SubscriptionStatus.instance,
                    builder: (context, isSubscribed, _) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: BigButton(
                              text: isSubscribed ? "Gracias\nPor el apoyo" : "Soporte\nNuestra App",
                              isBlue: true,
                              onPressed: () {
                                context.go('/paywall');
                              },
                            ),
                          ),
                          Positioned(
                            width: 235,
                            right: -70,
                            bottom: -25,
                            child: IgnorePointer(
                              child: RotationTransition(
                                turns: const AlwaysStoppedAnimation(315 / 360),
                                child: Image.asset(
                                  isSubscribed
                                      ? "assets/images/food/food_2.png"
                                      : "assets/images/food/food_1.png",
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color.fromRGBO(242, 242, 242, 1),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notificaciones',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontFamily: 'SF Pro',
                              letterSpacing: -0.43,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CupertinoSwitch(
                            value: status,
                            onChanged: (bool value) {
                              setState(() {
                                status = value;
                              });
                              _saveSwitchValue(value); // сохраняем при изменении
                            },
                            activeTrackColor: Color.fromRGBO(52, 199, 89, 1),
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: BigButton(text: "Términos de Uso", onPressed: () {})),
              Expanded(child: BigButton(text: "Política de Privacidad", onPressed: () {})),
            ],
          ),
        ),
      ),
    ));
  }
}
