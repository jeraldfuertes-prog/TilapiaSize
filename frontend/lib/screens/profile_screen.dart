import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'User');
  final _emailController = TextEditingController(text: 'farmer@example.com');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Prototype preferences saved locally for this session.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(eyebrow: 'Account', title: 'Profile'),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;
            final profile = _buildProfileCard();
            const security = _SecurityCard();
            if (stacked) {
              return Column(
                children: [profile, const SizedBox(height: 16), security],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 12, child: profile),
                const SizedBox(width: 16),
                const Expanded(flex: 8, child: security),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return AppPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _LargeAvatar(),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Registered TilapiaSize user',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 40, color: AppColors.line),
          LayoutBuilder(
            builder: (context, constraints) {
              final oneColumn = constraints.maxWidth < 600;
              final fields = [
                _LabeledField(
                  label: 'Display name',
                  child: TextField(controller: _nameController),
                ),
                _LabeledField(
                  label: 'Email',
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const _LabeledField(
                  label: 'Role',
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(hintText: 'User'),
                  ),
                ),
                const _LabeledField(
                  label: 'Preferred result unit',
                  child: _UnitDropdown(),
                ),
              ];
              if (oneColumn) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      fields[i],
                      if (i != fields.length - 1) const SizedBox(height: 14),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: fields
                    .map(
                      (field) => SizedBox(
                        width: (constraints.maxWidth - 14) / 2,
                        child: field,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(label: 'Save preferences', onPressed: _save),
          ),
        ],
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  const _LargeAvatar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'FA',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _UnitDropdown extends StatefulWidget {
  const _UnitDropdown();

  @override
  State<_UnitDropdown> createState() => _UnitDropdownState();
}

class _UnitDropdownState extends State<_UnitDropdown> {
  String value = 'Centimeters (cm)';
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: const [
        DropdownMenuItem(
          value: 'Centimeters (cm)',
          child: Text('Centimeters (cm)'),
        ),
      ],
      onChanged: (next) => setState(() => value = next ?? value),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Validate image format and file size for usability.',
      'Store only safe client state.',
      'Send authenticated HTTPS requests.',
      'Never store database credentials or raw SQL.',
      'Server remains responsible for final authorization and validation.',
    ];
    return AppPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Security boundary'),
          const SizedBox(height: 4),
          const Text(
            'Client-side responsibilities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primaryDark,
                    size: 10,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}
