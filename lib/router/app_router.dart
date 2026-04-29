import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/shell/app_shell.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/home/goals_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_expenses_screen.dart';
import '../screens/onboarding/onboarding_income_screen.dart';
import '../screens/onboarding/onboarding_name_screen.dart';
import '../screens/quests/quests_screen.dart';
import '../screens/tools/tools_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/onboarding/name',
    routes: [
      GoRoute(
        path: '/onboarding/name',
        builder: (context, state) => const OnboardingNameScreen(),
      ),
      GoRoute(
        path: '/onboarding/income',
        builder: (context, state) => const OnboardingIncomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/expenses',
        builder: (context, state) => const OnboardingExpensesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'goals',
                    builder: (context, state) => const GoalsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quests',
                builder: (context, state) => const QuestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calculator',
                builder: (context, state) => const CalculatorScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
