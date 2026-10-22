import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'common.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.onMenu,
    required this.onHelp,
    required this.onProfile,
    required this.showMenu,
  });

  final String title;
  final VoidCallback onMenu;
  final VoidCallback onHelp;
  final VoidCallback onProfile;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth <= 580;
        final horizontalPadding = compact ? 12.0 : (showMenu ? 18.0 : 34.0);
        return Container(
          constraints: BoxConstraints(minHeight: compact ? 78 : 96),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              if (showMenu) ...[
                _IconButton(icon: Icons.menu_rounded, onPressed: onMenu),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compact) const Eyebrow('Automated fish size grading'),
                    if (!compact) const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 20 : 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                _IconButton(
                  icon: Icons.question_mark_rounded,
                  onPressed: onHelp,
                ),
                const SizedBox(width: 10),
              ],
              InkWell(
                onTap: onProfile,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: EdgeInsets.fromLTRB(6, 5, compact ? 6 : 10, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const _Avatar(),
                      if (!compact) ...[
                        const SizedBox(width: 9),
                        const _ProfileCopy(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'FA',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileCopy extends StatelessWidget {
  const _ProfileCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 1),
        Text(
          'Registered user',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}
