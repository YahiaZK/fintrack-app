import 'package:flutter/material.dart';

class RankData {
  const RankData({
    required this.name,
    required this.level,
    required this.icon,
    required this.color,
    required this.xpRequired,
  });

  final String name;
  final int level;
  final IconData icon;
  final Color color;
  final int xpRequired;
}

const List<RankData> kRanks = <RankData>[
  RankData(
    name: 'Bronze I',
    level: 1,
    icon: Icons.savings_rounded,
    color: Color(0xFFB77B4B),
    xpRequired: 1000,
  ),
  RankData(
    name: 'Bronze II',
    level: 2,
    icon: Icons.savings_rounded,
    color: Color(0xFFB77B4B),
    xpRequired: 2000,
  ),
  RankData(
    name: 'Bronze III',
    level: 3,
    icon: Icons.savings_rounded,
    color: Color(0xFFB77B4B),
    xpRequired: 3000,
  ),
  RankData(
    name: 'Silver I',
    level: 4,
    icon: Icons.verified_rounded,
    color: Color(0xFFC0CED7),
    xpRequired: 4000,
  ),
  RankData(
    name: 'Silver II',
    level: 5,
    icon: Icons.verified_rounded,
    color: Color(0xFFC0CED7),
    xpRequired: 5000,
  ),
  RankData(
    name: 'Silver III',
    level: 6,
    icon: Icons.verified_rounded,
    color: Color(0xFFC0CED7),
    xpRequired: 6000,
  ),
  RankData(
    name: 'Gold I',
    level: 7,
    icon: Icons.shield_rounded,
    color: Color(0xFFEF9F27),
    xpRequired: 7000,
  ),
  RankData(
    name: 'Gold II',
    level: 8,
    icon: Icons.shield_rounded,
    color: Color(0xFFEF9F27),
    xpRequired: 8000,
  ),
  RankData(
    name: 'Gold III',
    level: 9,
    icon: Icons.shield_rounded,
    color: Color(0xFFEF9F27),
    xpRequired: 9000,
  ),
  RankData(
    name: 'Platinum I',
    level: 10,
    icon: Icons.military_tech_rounded,
    color: Color(0xFFB8D0DC),
    xpRequired: 10000,
  ),
  RankData(
    name: 'Platinum II',
    level: 11,
    icon: Icons.military_tech_rounded,
    color: Color(0xFFB8D0DC),
    xpRequired: 11000,
  ),
  RankData(
    name: 'Platinum III',
    level: 12,
    icon: Icons.military_tech_rounded,
    color: Color(0xFFB8D0DC),
    xpRequired: 12000,
  ),
  RankData(
    name: 'Diamond I',
    level: 13,
    icon: Icons.diamond_rounded,
    color: Color(0xFF78D6F5),
    xpRequired: 13000,
  ),
  RankData(
    name: 'Diamond II',
    level: 14,
    icon: Icons.diamond_rounded,
    color: Color(0xFF78D6F5),
    xpRequired: 14000,
  ),
  RankData(
    name: 'Diamond III',
    level: 15,
    icon: Icons.diamond_rounded,
    color: Color(0xFF78D6F5),
    xpRequired: 15000,
  ),
  RankData(
    name: 'Crown',
    level: 16,
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFFE7C860),
    xpRequired: 16000,
  ),
];

RankData rankForLevel(int level) {
  final clamped = level.clamp(1, kRanks.length);
  return kRanks[clamped - 1];
}
