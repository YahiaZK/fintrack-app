import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/shell/app_shell.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/home/goals_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_expenses_screen.dart';
import '../screens/onboarding/onboarding_income_screen.dart';
import '../screens/onboarding/onboarding_name_screen.dart';
import '../screens/profile/badges_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/ranks_screen.dart';
import '../screens/quests/quests_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tools/insights_screen.dart';
import '../screens/tools/tools_screen.dart';
import '../screens/tools/transaction_manager_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/auth/sign-in',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/auth/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
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
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
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
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const ProfileScreen(),
                    routes: [
                      GoRoute(
                        path: 'badges',
                        builder: (context, state) => const BadgesScreen(),
                      ),
                      GoRoute(
                        path: 'ranks',
                        builder: (context, state) => const RanksScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
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
                routes: [
                  GoRoute(
                    path: 'transaction-manager',
                    builder: (context, state) =>
                        const TransactionManagerScreen(),
                  ),
                  GoRoute(
                    path: 'insights',
                    builder: (context, state) => const InsightsScreen(),
                  ),
                ],
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _authSub = _ref.listen(
      authStateChangesProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
    _profileSub = _ref.listen(
      userProfileStreamProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription _authSub;
  late final ProviderSubscription _profileSub;

  @override
  void dispose() {
    _authSub.close();
    _profileSub.close();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authStateChangesProvider);
    if (auth.isLoading) return null;

    final user = auth.value;
    final loc = state.matchedLocation;
    final isAuthRoute = loc.startsWith('/auth');
    final isOnboardingRoute = loc.startsWith('/onboarding');

    if (user == null) {
      return isAuthRoute ? null : '/auth/sign-in';
    }

    final profileAsync = _ref.read(userProfileStreamProvider);
    if (profileAsync.isLoading) return null;
    final profile = profileAsync.value;
    final onboardingDone = profile?.onboardingCompleted ?? false;

    if (!onboardingDone) {
      return isOnboardingRoute ? null : '/onboarding/name';
    }

    if (isAuthRoute || isOnboardingRoute) return '/home';
    return null;
  }
}
