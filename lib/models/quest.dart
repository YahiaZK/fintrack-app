import 'package:cloud_firestore/cloud_firestore.dart';

class Quest {
  const Quest({
    required this.id,
    required this.name,
    required this.xp,
    required this.category,
    required this.frequency,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int xp;
  final String category;
  final String? frequency;
  final DateTime? createdAt;

  factory Quest.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return Quest(
      id: id,
      name: (data['name'] as String?) ?? '',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      category: (data['category'] as String?) ?? '',
      frequency: data['frequency'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
