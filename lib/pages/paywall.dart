import 'package:cocinando/pages/subscription_status.dart';
import 'package:cocinando/widgets/button_widgets.dart';
import 'package:cocinando/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _isSubscribed = SubscriptionStatus.instance.value;
    SubscriptionStatus.instance.addListener(_updateSubscriptionStatus);
  }

  void _updateSubscriptionStatus() {
    if (mounted) {
      setState(() {
        _isSubscribed = SubscriptionStatus.instance.value;
      });
    }
  }

  @override
  void dispose() {
    SubscriptionStatus.instance.removeListener(_updateSubscriptionStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            children: [
              Text(
                "Soporte\nNuestra App",
                style: AppTextStyles.title_48,
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_isSubscribed) ...[
                CustomButton(
                  text: "Dona \$0.49",
                  fontSize: 15,
                  color: Colors.white,
                  textColor: const Color.fromRGBO(0, 87, 248, 1),
                  textStyle: AppTextStyles.subtitle_16_bold,
                  onPressed: () async {
                    await SubscriptionStatus.instance.subscribe();
                    setState(() {
                      _isSubscribed = SubscriptionStatus.instance.value;
                    });
                    context.go('/configuraciones');
                  },
                ),
                const SizedBox(height: 8),
              ],
              CustomButton(
                text: "Restaurar",
                fontSize: 15,
                color: const Color.fromRGBO(51, 121, 249, 1),
                textColor: Colors.white,
                textStyle: AppTextStyles.subtitle_16_bold,
                onPressed: () async {
                  await SubscriptionStatus.instance.restore();
                  setState(() {
                    _isSubscribed = SubscriptionStatus.instance.value;
                  });
                },
              ),
            ],
          ),
        ),
        isSmallScreen ? const SizedBox(height: 10) : const Spacer(),
        Image.asset(
          "assets/images/food/food_1.png",
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 25),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 87, 248, 1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/configuraciones'),
          ),
        ),
        body: isSmallScreen ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}
