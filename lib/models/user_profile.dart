class UserProfile {
  const UserProfile({
    this.name,
    this.monthlyIncome,
    this.monthlyExpenses,
  });

  final String? name;
  final double? monthlyIncome;
  final double? monthlyExpenses;

  UserProfile copyWith({
    String? name,
    double? monthlyIncome,
    double? monthlyExpenses,
  }) {
    return UserProfile(
      name: name ?? this.name,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
      if (monthlyExpenses != null) 'monthlyExpenses': monthlyExpenses,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] as String?,
      monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble(),
      monthlyExpenses: (data['monthlyExpenses'] as num?)?.toDouble(),
    );
  }
}
