import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/screens/onboarding_expenses_screen.dart';
import '../features/onboarding/screens/onboarding_income_screen.dart';
import '../features/onboarding/screens/onboarding_name_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
