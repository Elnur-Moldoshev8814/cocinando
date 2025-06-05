import 'package:cocinando/pages/calendar.dart';
import 'package:cocinando/pages/day_selector_page.dart';
import 'package:cocinando/pages/intro.dart';
import 'package:cocinando/pages/task_page.dart';
import 'package:go_router/go_router.dart';
import 'package:cocinando/layout/main_layout.dart';
import 'package:cocinando/pages/splash.dart';
import 'package:cocinando/pages/paywall.dart';
import 'package:cocinando/pages/settings.dart';
import 'package:cocinando/pages/recipes.dart';
import 'package:cocinando/pages/recipe_list.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const Intro(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const Splash(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const Paywall(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainLayout(child: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendario/meses',
              builder: (context, state) => const MonthSelectorPage(),
            ),
            GoRoute(
              path: '/calendario/dias/:year/:month',
              builder: (context, state) {
                final year = int.parse(state.pathParameters['year']!);
                final month = int.parse(state.pathParameters['month']!);
                return DaySelectorPage(year: year, month: month);
              },
            ),
            GoRoute(
              path: '/calendario/tareas/:year/:month/:day',
              builder: (context, state) {
                final year = int.parse(state.pathParameters['year']!);
                final month = int.parse(state.pathParameters['month']!);
                final day = int.parse(state.pathParameters['day']!);
                return TaskPage(year: year, month: month, day: day);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recetas',
              builder: (context, state) => const Recipes(),
              routes: [
                GoRoute(
                  path: ':name', // <-- именно так!
                  builder: (context, state) {
                    final category = state.pathParameters['name']!;
                    return RecipeListPage(category: category);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/configuraciones',
              builder: (context, state) => const Settings(),
            ),
          ],
        ),
      ],
    ),
  ],
);
