import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.totalAmount,
    required this.currentAmount,
    this.deadline,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final int totalAmount;
  final int currentAmount;
  final DateTime? deadline;
  final DateTime? createdAt;

  factory Goal.fromMap(String id, Map<String, dynamic> data) {
    final dl = data['deadline'];
    final ca = data['createdAt'];
    return Goal(
      id: id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toInt() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toInt() ?? 0,
      deadline: dl is Timestamp ? dl.toDate() : null,
      createdAt: ca is Timestamp ? ca.toDate() : null,
    );
  }
}
