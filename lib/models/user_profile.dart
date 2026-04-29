class UserProfile {
  const UserProfile({
    this.name,
    this.email,
    this.monthlyIncome,
    this.monthlyExpenses,
    this.onboardingCompleted = false,
  });

  final String? name;
  final String? email;
  final double? monthlyIncome;
  final double? monthlyExpenses;
  final bool onboardingCompleted;

  UserProfile copyWith({
    String? name,
    String? email,
    double? monthlyIncome,
    double? monthlyExpenses,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
      if (monthlyExpenses != null) 'monthlyExpenses': monthlyExpenses,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] as String?,
      email: data['email'] as String?,
      monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble(),
      monthlyExpenses: (data['monthlyExpenses'] as num?)?.toDouble(),
      onboardingCompleted: (data['onboardingCompleted'] as bool?) ?? false,
    );
  }
}
