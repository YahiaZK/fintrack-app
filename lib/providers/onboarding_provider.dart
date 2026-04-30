import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'user_providers.dart';

class OnboardingController extends Notifier<UserProfile> {
  @override
  UserProfile build() => const UserProfile();

  void setName(String name) {
    state = state.copyWith(name: name.trim());
  }

  void setIncome(double income) {
    state = state.copyWith(monthlyIncome: income);
  }

  void setExpenses(double expenses) {
    state = state.copyWith(monthlyExpenses: expenses);
  }

  Future<void> persistStep(UserProfile partial) {
    final service = ref.read(userServiceProvider);
    if (service == null) return Future.value();
    return service.save(partial);
  }

  Future<void> finalize() {
    final service = ref.read(userServiceProvider);
    if (service == null) return Future.value();
    final income = state.monthlyIncome ?? 0;
    final expenses = state.monthlyExpenses ?? 0;
    return service.save(
      state.copyWith(
        onboardingCompleted: true,
        totalNetWorth: income,
        totalSpent: expenses,
        totalSaved: 0,
      ),
    );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, UserProfile>(
  OnboardingController.new,
);
