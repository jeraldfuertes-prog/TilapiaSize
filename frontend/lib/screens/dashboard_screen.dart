import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/grading_record.dart';
import '../widgets/common.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.history,
    required this.isLoading,
    required this.onNavigate,
  });

  final List<GradingRecord> history;
  final bool isLoading;
  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final largeCount = history
        .where((record) => record.grade == 'Large')
        .length;
    final latestGrade = history.isEmpty ? '—' : history.first.grade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(onNavigate: onNavigate),
        const SizedBox(height: 34),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('Overview'),
                  SizedBox(height: 3),
                  Text(
                    'Today at a glance',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(AppSection.grade),
              child: const Text('New grading →'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 580
                ? 1
                : constraints.maxWidth < 1120
                ? 2
                : 4;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1
                  ? 4.2
                  : (columns == 2 ? 2.8 : 2.15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  icon: Icons.center_focus_strong,
                  value: '${history.length}',
                  label: 'Total gradings',
                ),
                _StatCard(
                  icon: Icons.check_rounded,
                  value: '$largeCount',
                  label: 'Large category',
                ),
                _StatCard(
                  icon: Icons.analytics_outlined,
                  value: latestGrade,
                  label: 'Latest grade',
                ),
                const _StatCard(
                  icon: Icons.bolt_rounded,
                  value: 'Ready',
                  label: 'Analysis workflow',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;
            final recent = _RecentRecordsPanel(
              history: history,
              isLoading: isLoading,
              onSeeAll: () => onNavigate(AppSection.history),
            );
            const workflow = _WorkflowPanel();
            if (stacked) {
              return Column(
                children: [recent, const SizedBox(height: 16), workflow],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 115, child: recent),
                const SizedBox(width: 16),
                const Expanded(flex: 85, child: workflow),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onNavigate});
  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.all(38),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F7EF), Color(0xFFF9FCFA), Color(0xFFE9F8FB)],
          stops: [0, .56, 1],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD7E9E0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hideVisual = constraints.maxWidth < 820;
          final copy = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F0E6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'AI-assisted grading',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Grade tilapia faster from a single image.',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 580 ? 34 : 52,
                  height: 1.02,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Capture or upload a clear fish photo, submit it for analysis, and review the predicted size and grade in one guided flow.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  PrimaryButton(
                    label: 'Grade a tilapia',
                    onPressed: () => onNavigate(AppSection.grade),
                  ),
                  SecondaryButton(
                    label: 'View history',
                    onPressed: () => onNavigate(AppSection.history),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const _HeroProof(),
            ],
          );

          if (hideVisual) return copy;
          return Row(
            children: [
              Expanded(flex: 11, child: copy),
              const SizedBox(width: 32),
              const Expanded(flex: 9, child: _ScanFrame()),
            ],
          );
        },
      ),
    );
  }
}

class _HeroProof extends StatelessWidget {
  const _HeroProof();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('3 steps', 'Capture → Analyze → Review'),
      ('Web-ready', 'Responsive farm workflow'),
      ('Secure flow', 'JWT-ready'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 430;
        final children = items
            .map(
              (item) => Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFC4E1D5), width: 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList();
        return vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i != children.length - 1) const SizedBox(height: 14),
                  ],
                ],
              )
            : Row(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    Expanded(child: children[i]),
                    if (i != children.length - 1) const SizedBox(width: 14),
                  ],
                ],
              );
      },
    );
  }
}

class _ScanFrame extends StatefulWidget {
  const _ScanFrame();

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: .26,
      end: .72,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.14,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFBCDED2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F175443),
                blurRadius: 60,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              FractionallySizedBox(
                widthFactor: .76,
                child: Image.asset(
                  'assets/images/tilapia-illustration.png',
                  fit: BoxFit.contain,
                ),
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => Positioned(
                  left: 34,
                  right: 34,
                  top: _animation.value * 300,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF1B9A78),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B9A78).withValues(alpha: .45),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                bottom: 22,
                child: _ScanTag('Length estimate'),
              ),
              const Positioned(
                right: 20,
                top: 23,
                child: _ScanTag('Size category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTag extends StatelessWidget {
  const _ScanTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1412372E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordsPanel extends StatelessWidget {
  const _RecentRecordsPanel({
    required this.history,
    required this.isLoading,
    required this.onSeeAll,
  });
  final List<GradingRecord> history;
  final bool isLoading;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow('Recent activity'),
                      SizedBox(height: 3),
                      Text(
                        'Latest grading records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(36),
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (history.isEmpty)
            const _EmptyRecent()
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: history
                    .take(4)
                    .map((record) => _RecordRow(record: record))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        children: [
          _EmptyIcon(icon: Icons.radio_button_unchecked),
          SizedBox(height: 12),
          Text(
            'No grading records yet',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Your saved results will appear here.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final GradingRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDF2EF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.memory(
              record.imageBytes,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.lengthCm.toStringAsFixed(1)} cm · ${record.category}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatRecordDate(record.createdAt)} · ${record.confidence}% confidence',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              record.grade,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('How it works'),
            const SizedBox(height: 3),
            const Text(
              'Three simple steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            const _Step(
              number: '01',
              title: 'Capture a clear image',
              description: 'Use the camera or choose a photo from your device.',
            ),
            const SizedBox(height: 16),
            const _Step(
              number: '02',
              title: 'Send it for analysis',
              description: 'The production flow sends the image to FastAPI, then the ML service.',
            ),
            const SizedBox(height: 16),
            const _Step(
              number: '03',
              title: 'Review the grade',
              description: 'See estimated size, category, confidence, and save it to history.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF15778C),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  const _EmptyIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F2),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
