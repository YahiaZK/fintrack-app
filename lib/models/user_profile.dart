class UserProfile {
  const UserProfile({
    this.name,
    this.email,
    this.monthlyIncome,
    this.monthlyExpenses,
    this.totalNetWorth,
    this.totalSpent,
    this.totalSaved,
    this.xp = 100,
    this.onboardingCompleted = false,
  });

  final String? name;
  final String? email;
  final double? monthlyIncome;
  final double? monthlyExpenses;
  final double? totalNetWorth;
  final double? totalSpent;
  final double? totalSaved;
  final int xp;
  final bool onboardingCompleted;

  UserProfile copyWith({
    String? name,
    String? email,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? totalNetWorth,
    double? totalSpent,
    double? totalSaved,
    int? xp,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      totalNetWorth: totalNetWorth ?? this.totalNetWorth,
      totalSpent: totalSpent ?? this.totalSpent,
      totalSaved: totalSaved ?? this.totalSaved,
      xp: xp ?? this.xp,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
      if (monthlyExpenses != null) 'monthlyExpenses': monthlyExpenses,
      if (totalNetWorth != null) 'totalNetWorth': totalNetWorth,
      if (totalSpent != null) 'totalSpent': totalSpent,
      if (totalSaved != null) 'totalSaved': totalSaved,
      'xp': xp,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] as String?,
      email: data['email'] as String?,
      monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble(),
      monthlyExpenses: (data['monthlyExpenses'] as num?)?.toDouble(),
      totalNetWorth: (data['totalNetWorth'] as num?)?.toDouble(),
      totalSpent: (data['totalSpent'] as num?)?.toDouble(),
      totalSaved: (data['totalSaved'] as num?)?.toDouble(),
      xp: (data['xp'] as num?)?.toInt() ?? 100,
      onboardingCompleted: (data['onboardingCompleted'] as bool?) ?? false,
    );
  }
}
