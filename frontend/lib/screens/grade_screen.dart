import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_theme.dart';
import '../models/grading_record.dart';
import '../widgets/common.dart';
import '../widgets/sidebar.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({
    super.key,
    required this.onSaveResult,
    required this.onNavigate,
  });

  final Future<void> Function(GradingRecord record) onSaveResult;
  final ValueChanged<AppSection> onNavigate;

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String _imageName = '';
  String _fileMeta = '';
  bool _cameraMode = false;
  bool _analyzing = false;
  bool _saved = false;
  int _progress = 0;
  String _progressLabel = 'Validating image';
  GradingRecord? _result;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2400,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 8 * 1024 * 1024) {
        _toast('Image must be 8 MB or smaller.');
        return;
      }
      final lower = file.name.toLowerCase();
      final mime = file.mimeType?.toLowerCase();
      final supportedMime =
          mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp';
      final supportedExtension =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
      if (!supportedMime && !supportedExtension) {
        _toast('Please choose a JPG, PNG, or WEBP image.');
        return;
      }
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _fileMeta =
            '${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB · Ready to analyze';
        _result = null;
        _saved = false;
        _progress = 0;
      });
    } catch (_) {
      _toast(
        source == ImageSource.camera
            ? 'Camera access is unavailable or was not allowed.'
            : 'Unable to open that image.',
      );
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageName = '';
      _fileMeta = '';
      _result = null;
      _saved = false;
      _analyzing = false;
      _progress = 0;
    });
  }

  ({String grade, String category, String badge}) _categoryFromLength(
    double length,
  ) {
    if (length < 20) {
      return (grade: 'Small', category: 'Juvenile / small', badge: 'S');
    }
    if (length < 30) {
      return (grade: 'Medium', category: 'Growing / medium', badge: 'M');
    }
    return (grade: 'Large', category: 'Market size', badge: 'L');
  }

  Future<void> _analyze() async {
    if (_imageBytes == null || _analyzing) return;
    setState(() {
      _result = null;
      _saved = false;
      _analyzing = true;
      _progress = 8;
    });

    final stages = <(int, String)>[
      (24, 'Validating image'),
      (48, 'Preparing image for inference'),
      (72, 'Running size estimation'),
      (90, 'Applying grading rule'),
      (100, 'Preparing result'),
    ];
    for (final stage in stages) {
      if (!mounted) return;
      setState(() {
        _progress = stage.$1;
        _progressLabel = stage.$2;
      });
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }

    final seed = _imageName.length + DateTime.now().minute;
    final length = 18 + (seed % 17) + ((seed * 7) % 10) / 10;
    final confidence = 88 + (seed % 9);
    final category = _categoryFromLength(length);
    final result = GradingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      imageBytes: _imageBytes!,
      imageName: _imageName,
      lengthCm: double.parse(length.toStringAsFixed(1)),
      confidence: confidence,
      grade: category.grade,
      category: category.category,
    );

    if (!mounted) return;
    setState(() {
      _result = result;
      _analyzing = false;
    });
  }

  Future<void> _save() async {
    final result = _result;
    if (result == null || _saved) return;
    await widget.onSaveResult(result);
    if (!mounted) return;
    setState(() => _saved = true);
    _toast('Result saved to demo history.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(
          eyebrow: 'Core workflow',
          title: 'Grade a tilapia',
          subtitle: 'Upload an image or use your camera.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1120;
            final upload = _buildUploadPanel();
            final analysis = _buildAnalysisPanel();
            if (stacked) {
              return Column(
                children: [upload, const SizedBox(height: 16), analysis],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 115, child: upload),
                const SizedBox(width: 16),
                Expanded(flex: 85, child: analysis),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUploadPanel() {
    return AppPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4F1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'Upload image',
                    active: !_cameraMode,
                    onTap: () => setState(() => _cameraMode = false),
                  ),
                ),
                Expanded(
                  child: _ModeButton(
                    label: 'Live camera',
                    active: _cameraMode,
                    onTap: () => setState(() => _cameraMode = true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!_cameraMode)
            InkWell(
              onTap: () => _pick(ImageSource.gallery),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(minHeight: 300),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFAACBBE),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIcon(icon: Icons.upload_rounded),
                    SizedBox(height: 8),
                    Text(
                      'Choose a tilapia photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Click to browse your device',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'JPG, PNG or WEBP · up to 8 MB',
                      style: TextStyle(color: Color(0xFF8BA098), fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1F1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundIcon(icon: Icons.camera_alt_outlined),
                        SizedBox(height: 8),
                        Text(
                          'Camera capture',
                          style: TextStyle(
                            color: Color(0xFFDCE9E4),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 7),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Open your device camera to capture a fish image.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF97AAA3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Open camera',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => _pick(ImageSource.camera),
                  ),
                ),
              ],
            ),
          if (_imageBytes != null) ...[
            const SizedBox(height: 14),
            _PreviewCard(
              bytes: _imageBytes!,
              name: _imageName,
              meta: _fileMeta,
              onRemove: _clearImage,
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoDot(),
                SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'For best results: ',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'keep the entire fish visible, avoid motion blur, and use good lighting.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _analyzing ? 'Analyzing…' : 'Analyze fish image',
            onPressed: _imageBytes == null || _analyzing ? null : _analyze,
            expand: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPanel() {
    return AppPanel(
      padding: const EdgeInsets.all(26),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 436),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _analyzing
              ? _LoadingAnalysis(progress: _progress, label: _progressLabel)
              : _result != null
              ? _ResultView(
                  result: _result!,
                  saved: _saved,
                  onAnalyzeAnother: _clearImage,
                  onSave: _save,
                )
              : const _IdleAnalysis(),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? AppColors.ink : AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.primary, size: 26),
    );
  }
}

class _InfoDot extends StatelessWidget {
  const _InfoDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFDBECE4),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'i',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.bytes,
    required this.name,
    required this.meta,
    required this.onRemove,
  });
  final Uint8List bytes;
  final String name;
  final String meta;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: 92,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Selected image'),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppColors.danger),
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleAnalysis extends StatelessWidget {
  const _IdleAnalysis();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('idle'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF27A7A5)],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330F8064),
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: const Text(
                'RESULT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your result will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'After you submit a fish image, the AI will analyze it and display the predicted size and grade.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingAnalysis extends StatelessWidget {
  const _LoadingAnalysis({required this.progress, required this.label});
  final int progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('loading'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                backgroundColor: Color(0xFFDCEFE7),
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Analyzing fish image…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simulating image validation, inference, and grading.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFEDF3F0),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.saved,
    required this.onAnalyzeAnother,
    required this.onSave,
  });
  final GradingRecord result;
  final bool saved;
  final VoidCallback onAnalyzeAnother;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final badge = result.grade.isEmpty ? '?' : result.grade[0];
    final hour = result.createdAt.hour % 12 == 0
        ? 12
        : result.createdAt.hour % 12;
    final minute = result.createdAt.minute.toString().padLeft(2, '0');
    final period = result.createdAt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F5EC),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Analysis complete',
                style: TextStyle(
                  color: Color(0xFF116C55),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Simulated UI result',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predicted grade',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.grade,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.8,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 40, color: AppColors.line),
        LayoutBuilder(
          builder: (context, constraints) {
            final oneColumn = constraints.maxWidth < 440;
            final metrics = [
              ('Estimated length', '${result.lengthCm.toStringAsFixed(1)} cm'),
              ('Size category', result.category),
              ('Confidence', '${result.confidence}%'),
              ('Processed', time),
            ];
            if (oneColumn) {
              return Column(
                children: metrics
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _Metric(label: m.$1, value: m.$2),
                      ),
                    )
                    .toList(),
              );
            }
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics
                  .map(
                    (m) => SizedBox(
                      width: (constraints.maxWidth - 10) / 2,
                      child: _Metric(label: m.$1, value: m.$2),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF7F2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 11, height: 1.5),
              children: [
                const TextSpan(
                  text: 'Interpretation\n',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                TextSpan(
                  text:
                      'The detected fish falls in the ${result.grade.toLowerCase()} demonstration category based on the prototype threshold mapping.',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 440) {
              return Column(
                children: [
                  SecondaryButton(
                    label: 'Analyze another',
                    onPressed: onAnalyzeAnother,
                    expand: true,
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: saved ? 'Saved ✓' : 'Save to history',
                    onPressed: saved ? null : onSave,
                    expand: true,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Analyze another',
                    onPressed: onAnalyzeAnother,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: saved ? 'Saved ✓' : 'Save to history',
                    onPressed: saved ? null : onSave,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9F7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
