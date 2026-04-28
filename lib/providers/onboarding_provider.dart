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
    return ref.read(userServiceProvider).save(partial);
  }

  Future<void> finalize() {
    return ref.read(userServiceProvider).save(state);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, UserProfile>(
  OnboardingController.new,
);
