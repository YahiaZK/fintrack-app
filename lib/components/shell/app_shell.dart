import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <_NavItem>[
    _NavItem(
      label: 'Home',
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
    ),
    _NavItem(
      label: 'Quests',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
    ),
    _NavItem(
      label: 'Tools',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItem(
      label: 'Calculator',
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate,
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Color(0xFF20232C), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < 2; i++)
                      _NavButton(
                        item: _items[i],
                        active: i == current,
                        onTap: () => _onTap(i),
                      ),
                    const SizedBox(width: 72),
                    for (var i = 2; i < _items.length; i++)
                      _NavButton(
                        item: _items[i],
                        active: i == current,
                        onTap: () => _onTap(i),
                      ),
                  ],
                ),
                Positioned(
                  top: -12,
                  child: _ChatButton(onTap: () => context.push('/chat')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textPrimary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? item.activeIcon : item.icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF08C789),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: AppColors.background,
          size: 34,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
