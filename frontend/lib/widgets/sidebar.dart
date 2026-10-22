import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'common.dart';

enum AppSection { dashboard, grade, history, profile }

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.current,
    required this.onSelect,
    this.width = 268,
  });

  final AppSection current;
  final ValueChanged<AppSection> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.sidebar,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 28),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      'assets/images/logo-mark.png',
                      width: 48,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TilapiaSize',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Aquaculture AI',
                          style: TextStyle(
                            color: Color(0xFFB9D4CB),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Dashboard',
              active: current == AppSection.dashboard,
              onTap: () => onSelect(AppSection.dashboard),
            ),
            _NavItem(
              icon: Icons.center_focus_strong_outlined,
              label: 'Grade Fish',
              active: current == AppSection.grade,
              onTap: () => onSelect(AppSection.grade),
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'History',
              active: current == AppSection.history,
              onTap: () => onSelect(AppSection.history),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              active: current == AppSection.profile,
              onTap: () => onSelect(AppSection.profile),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                border: Border.all(color: Colors.white.withValues(alpha: .10)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Quick tip'),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture one tilapia at a time in good lighting and keep the full fish visible.',
                    style: TextStyle(
                      color: Color(0xFFC9DDD6),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => onSelect(AppSection.grade),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xFF9CE1C9),
                    ),
                    child: const Text(
                      'Start grading →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: .11)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: active
                  ? const Border(
                      left: BorderSide(color: Color(0xFF80D6B9), width: 3),
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Icon(
                    icon,
                    color: active ? Colors.white : const Color(0xFFC8DDD6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFFC8DDD6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
