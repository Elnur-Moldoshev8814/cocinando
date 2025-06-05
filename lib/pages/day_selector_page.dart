import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/text_styles.dart';

class DaySelectorPage extends StatelessWidget {
  final int year, month;

  const DaySelectorPage({required this.year, required this.month, super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final weekdayLabels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // или нужный цвет
        statusBarIconBrightness: Brightness.dark, // светлые иконки
        statusBarBrightness: Brightness.light, // для iOS
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/calendario/meses'),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 17, color: Color(0xFF0057F8)),
                        const SizedBox(width: 6),
                        Text(
                          '$year',
                          style: AppTextStyles.appbarTitle_blue,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getMonthName(month),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _getFormattedDay(year, month),
                    style: AppTextStyles.appbarTitle_blue,
                  ),
                ],
              ),
            ),
          )
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 11),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // совпадает с GridView
            child: Row(
              children: weekdayLabels.map((label) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 16) / 7, // ширина экрана минус padding
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 0,
                        fontFamily: 'SF Pro',
                        color: Color.fromRGBO(175, 175, 175, 1),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;
                final rows = (_getGridItemCount(year, month) / 7).ceil();
                final itemHeight = totalHeight / rows;
                final itemWidth = constraints.maxWidth / 7;
                final aspectRatio = itemWidth / itemHeight;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: _getGridItemCount(year, month),
                  itemBuilder: (context, index) {
                    final firstWeekday = DateTime(year, month, 1).weekday;
                    final isPadding = index < ((firstWeekday + 6) % 7);
                    if (isPadding) return const SizedBox();
                    final day = index - ((firstWeekday + 6) % 7) + 1;
                    final today = DateTime.now();
                    final isToday = today.year == year && today.month == month && today.day == day;

                    return GestureDetector(
                      onTap: () => context.go('/calendario/tareas/$year/$month/$day'),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        color: isToday
                            ? const Color.fromRGBO(229, 238, 255, 1)
                            : const Color.fromRGBO(242, 242, 242, 1),
                        child: Padding(
                          padding: isSmallScreen ? const EdgeInsets.symmetric(vertical: 3) : const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$day', style: AppTextStyles.subtitle_15),
                              Column(
                                children: [
                                  FutureBuilder<int>(
                                    future: getTaskCount(year, month, day),
                                    builder: (context, snapshot) {
                                      return Column(
                                        children: [
                                          // Отображение количества задач
                                          if (snapshot.connectionState == ConnectionState.waiting)
                                            isSmallScreen ? const SizedBox() : const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          else if (snapshot.hasError)
                                            Text('!', style: AppTextStyles.subtitle_15)
                                          else
                                            Text(
                                              snapshot.hasData && snapshot.data! > 0 ? '${snapshot.data}' : '',
                                              style: AppTextStyles.subtitle_15_blue,
                                            ),
                                          // Отображение кружка, если есть задачи
                                          if (snapshot.hasData && snapshot.data! > 0)
                                            Padding(
                                              padding: isSmallScreen ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 8),
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(0, 87, 248, 1),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  int _getGridItemCount(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingEmptySlots = (firstWeekday + 6) % 7;
    return daysInMonth + leadingEmptySlots;
  }

  Future<int> getTaskCount(int year, int month, int day) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('tasks-$year-$month-$day');
    if (jsonStr == null) return 0;
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.length;
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }

  String _getFormattedDay(int year, int month) {
    final now = DateTime.now();
    final date = (now.year == year && now.month == month) ? now : DateTime(year, month, 1);
    const weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final weekday = weekdays[(date.weekday + 6) % 7];
    return '${_capitalize(weekday)}, ${date.day}';
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}