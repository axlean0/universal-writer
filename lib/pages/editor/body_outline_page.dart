import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../theme/app_theme.dart';

/// Center editor only — right panel is managed by EditorShell.
class BodyOutlinePage extends StatefulWidget {
  final Chapter chapter;
  final bool readOnly;

  const BodyOutlinePage({super.key, required this.chapter, this.readOnly = false});

  @override
  State<BodyOutlinePage> createState() => _BodyOutlinePageState();
}

class _BodyOutlinePageState extends State<BodyOutlinePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.chapter.title);
    _bodyCtrl = TextEditingController(text: widget.chapter.body);
  }

  @override
  void didUpdateWidget(BodyOutlinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      _titleCtrl.text = widget.chapter.title;
      _bodyCtrl.text = widget.chapter.body;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: _titleCtrl,
              readOnly: widget.readOnly,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 40,
                  fontWeight: FontWeight.w700, height: 48 / 40, letterSpacing: -0.8),
              decoration: const InputDecoration(
                hintText: '在此输入章节标题...',
                hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700,
                    color: AppColors.outlineVariant),
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                filled: false, isDense: true, contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _bodyCtrl,
              readOnly: widget.readOnly,
              maxLines: null,
              style: const TextStyle(fontFamily: 'Source Serif 4', fontSize: 18,
                  fontWeight: FontWeight.w400, height: 1.8, color: AppColors.onSurfaceVariant),
              decoration: const InputDecoration(
                hintText: '开始您的创作之旅...',
                hintStyle: TextStyle(fontFamily: 'Source Serif 4', fontSize: 18,
                    color: AppColors.outlineVariant, height: 1.8),
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                filled: false, isDense: true, contentPadding: EdgeInsets.zero,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
