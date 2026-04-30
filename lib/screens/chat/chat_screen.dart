import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onClose: () {
                if (context.canPop()) context.pop();
              },
            ),
            const Expanded(child: _ChatBody()),
            const _Composer(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF101622),
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Row(
        children: [
          _StreakChip(days: 5),
          const Spacer(),
          const Text(
            'AI Assistant',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              '\$',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days streak',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.warning,
            size: 15,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat Body
// ---------------------------------------------------------------------------

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080B10),
      alignment: Alignment.center,
      child: const Text(
        'Ask about your budget, savings, or next quest.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF667086),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composer
// ---------------------------------------------------------------------------

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF080B10),
        border: Border(top: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF121B31),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF32425F)),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Record your expense...',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 18),
                Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF8090AD),
                  size: 25,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.background,
                      size: 20,
                    ),
                    label: const Text(
                      'Send',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08C789),
                      elevation: 12,
                      shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2A44),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF34425E)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: Color(0xFFB7C5D9),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
