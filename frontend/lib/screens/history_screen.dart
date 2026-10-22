import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/grading_record.dart';
import '../widgets/common.dart';
import '../widgets/sidebar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.history,
    required this.onDelete,
    required this.onClear,
    required this.onNavigate,
  });

  final List<GradingRecord> history;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function() onClear;
  final ValueChanged<AppSection> onNavigate;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GradingRecord> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    return widget.history.where((record) {
      final haystack =
          '${record.grade} ${record.category} ${formatRecordDate(record.createdAt)} ${record.lengthCm}'
              .toLowerCase();
      return (_filter == 'all' || record.grade == _filter) &&
          haystack.contains(query);
    }).toList();
  }

  Future<void> _clearAll() async {
    if (widget.history.isEmpty) {
      _toast('Demo history is already empty.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('Clear all locally saved demo grading records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onClear();
      if (mounted) _toast('Demo history cleared.');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          eyebrow: 'Saved records',
          title: 'History',
          trailing: PrimaryButton(
            label: '+ New grading',
            onPressed: () => widget.onNavigate(AppSection.grade),
          ),
        ),
        const SizedBox(height: 16),
        AppPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 680;
                  final search = TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search by grade or date',
                      prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    ),
                  );
                  final filter = DropdownButtonFormField<String>(
                    initialValue: _filter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All grades')),
                      DropdownMenuItem(value: 'Small', child: Text('Small')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Large', child: Text('Large')),
                    ],
                    onChanged: (value) =>
                        setState(() => _filter = value ?? 'all'),
                    decoration: const InputDecoration(),
                  );
                  final clear = SecondaryButton(
                    label: 'Clear demo history',
                    onPressed: _clearAll,
                  );
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        search,
                        const SizedBox(height: 10),
                        filter,
                        const SizedBox(height: 10),
                        clear,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: 10),
                      SizedBox(width: 150, child: filter),
                      const SizedBox(width: 10),
                      clear,
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              if (widget.history.isEmpty)
                _EmptyHistory(
                  onGrade: () => widget.onNavigate(AppSection.grade),
                )
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(36),
                  child: Text(
                    'No records match your search.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 760) {
                      return Column(
                        children: filtered
                            .map(
                              (record) => _HistoryCard(
                                record: record,
                                onDelete: () => widget.onDelete(record.id),
                              ),
                            )
                            .toList(),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          color: Color(0xFF80948B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        dataTextStyle: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                        ),
                        columns: const [
                          DataColumn(label: Text('IMAGE')),
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('LENGTH')),
                          DataColumn(label: Text('GRADE')),
                          DataColumn(label: Text('CONFIDENCE')),
                          DataColumn(label: Text('')),
                        ],
                        rows: filtered
                            .map(
                              (record) => DataRow(
                                cells: [
                                  DataCell(
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        record.imageBytes,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(formatRecordDate(record.createdAt)),
                                  ),
                                  DataCell(
                                    Text(
                                      '${record.lengthCm.toStringAsFixed(1)} cm',
                                    ),
                                  ),
                                  DataCell(_GradeChip(record.grade)),
                                  DataCell(Text('${record.confidence}%')),
                                  DataCell(
                                    TextButton(
                                      onPressed: () =>
                                          widget.onDelete(record.id),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Color(0xFFAA6666),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip(this.grade);
  final String grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.onDelete});
  final GradingRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDF2EF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              record.imageBytes,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GradeChip(record.grade),
                    const SizedBox(width: 8),
                    Text(
                      '${record.lengthCm.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(record.category, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  '${formatRecordDate(record.createdAt)} · ${record.confidence}%',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onGrade});
  final VoidCallback onGrade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5F2),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'No saved grading records',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Save a result from the Grade Fish page to populate this table.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Grade a tilapia', onPressed: onGrade),
        ],
      ),
    );
  }
}
