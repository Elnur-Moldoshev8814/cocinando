import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/text_styles.dart';

class MonthSelectorPage extends StatelessWidget {
  const MonthSelectorPage({super.key});

  String _weekdayName(int weekday) => [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ][(weekday + 6) % 7]; // начинаем с понедельника


  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear + i);
    final now = DateTime.now();
    final currentDay = now.day;
    final currentWeekday = _weekdayName(now.weekday);
    final currentMonthName = monthName(now.month);
    final currentMonth = now.month;
    final thisYear = now.year;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView.builder(
          itemCount: years.length,
          itemBuilder: (context, i) {
            final year = years[i];
            final isFirst = i == 0;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с годом и датой только у первого
                  isFirst
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromRGBO(153, 153, 153, 1),
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$currentMonthName ',
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(0, 87, 248, 1),
                              ),
                            ),
                            TextSpan(
                              text: '$currentWeekday, $currentDay',
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(102, 156, 255, 1), // чуть светлее
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                      : Text(
                    '$year',
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color.fromRGBO(153, 153, 153, 1),
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(4, (rowIndex) {
                      return Row(
                        children: List.generate(3, (colIndex) {
                          final month = rowIndex * 3 + colIndex + 1;
                          if (month > 12) return Expanded(child: SizedBox());
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (year == thisYear && month == currentMonth)
                                      ? const Color.fromRGBO(229, 238, 255, 1)
                                      : const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => context.go('/calendario/dias/$year/$month'),
                                child: Text(
                                  monthName(month),
                                  style: AppTextStyles.subtitle_15_,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  String monthName(int month) => [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ][month - 1];
}
