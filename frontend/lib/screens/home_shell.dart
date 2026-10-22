import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/grading_record.dart';
import '../services/history_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import 'dashboard_screen.dart';
import 'grade_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _historyService = HistoryService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _current = AppSection.dashboard;
  List<GradingRecord> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final records = await _historyService.load();
    if (!mounted) return;
    setState(() {
      _history = records;
      _loadingHistory = false;
    });
  }

  Future<void> _addRecord(GradingRecord record) async {
    setState(() {
      _history = [
        record,
        ..._history.where((e) => e.id != record.id),
      ].take(10).toList();
    });
    await _historyService.save(_history);
  }

  Future<void> _deleteRecord(String id) async {
    setState(() => _history = _history.where((e) => e.id != id).toList());
    await _historyService.save(_history);
  }

  Future<void> _clearHistory() async {
    setState(() => _history = []);
    await _historyService.clear();
  }

  void _select(AppSection section) {
    setState(() => _current = section);
    Navigator.of(context).maybePop();
  }

  String get _title => switch (_current) {
    AppSection.dashboard => 'Dashboard',
    AppSection.grade => 'Grade Fish',
    AppSection.history => 'History',
    AppSection.profile => 'Profile',
  };

  Widget _buildScreen() => switch (_current) {
    AppSection.dashboard => DashboardScreen(
      history: _history,
      isLoading: _loadingHistory,
      onNavigate: _select,
    ),
    AppSection.grade => GradeScreen(
      onSaveResult: _addRecord,
      onNavigate: _select,
    ),
    AppSection.history => HistoryScreen(
      history: _history,
      onDelete: _deleteRecord,
      onClear: _clearHistory,
      onNavigate: _select,
    ),
    AppSection.profile => const ProfileScreen(),
  };

  void _showHelp() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x7508231C),
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'TILAPIA SIZE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Text(
                  'About this application',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This web application helps users capture or upload tilapia images, analyze fish size using AI, view grading results, and manage saved grading history through a simple and responsive interface.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth <= 820;
        final compactTopbar = constraints.maxWidth <= 580;
        final sidebarWidth = constraints.maxWidth <= 1120 ? 230.0 : 268.0;

        final content = Column(
          children: [
            AppTopBar(
              title: _title,
              showMenu: mobile,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
              onHelp: _showHelp,
              onProfile: () => _select(AppSection.profile),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  mobile ? (compactTopbar ? 12 : 18) : 34,
                  8,
                  mobile ? (compactTopbar ? 12 : 18) : 34,
                  56,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_current),
                    child: _buildScreen(),
                  ),
                ),
              ),
            ),
          ],
        );

        if (mobile) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            drawer: Drawer(
              width: 268,
              child: AppSidebar(current: _current, onSelect: _select),
            ),
            body: Builder(builder: (_) => content),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              AppSidebar(
                width: sidebarWidth,
                current: _current,
                onSelect: _select,
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}
