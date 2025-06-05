import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const labelStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w500,
    fontSize: 10,
  );

  Widget navBarIcon({
    String? svgPath,
    IconData? iconData,
    required int index,
  }) {
    final color = currentIndex == index
        ? const Color.fromRGBO(0, 87, 248, 1)
        : const Color.fromRGBO(135, 184, 217, 1);

    if (svgPath != null) {
      return Padding(padding: const EdgeInsets.only(bottom: 8),
          child: SvgPicture.asset(
            svgPath,
            color: color,
            width: 20,
            height: 20,
          )
      );
    } else if (iconData != null) {
      return Padding(padding: const EdgeInsets.only(bottom: 8),
        child: Icon(iconData, color: color)
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      selectedItemColor: const Color.fromRGBO(0, 87, 248, 1),
      unselectedItemColor: const Color.fromRGBO(135, 184, 217, 1),
      selectedLabelStyle: labelStyle,
      unselectedLabelStyle: labelStyle,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: navBarIcon(svgPath: 'assets/images/icons/calendar.svg', index: 0),
          label: "Calendario",
        ),
        BottomNavigationBarItem(
          icon: navBarIcon(svgPath: 'assets/images/icons/list.svg', index: 1),
          label: "Recetas",
        ),
        BottomNavigationBarItem(
          icon: navBarIcon(iconData: Icons.settings, index: 2),
          label: "Configuraciones",
        ),
      ],
    );
  }
}
