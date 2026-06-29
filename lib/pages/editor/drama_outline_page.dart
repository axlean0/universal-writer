import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';

/// 剧作编辑区 — auto-switches between 总纲/卷纲/章纲 based on selection.
class DramaOutlinePage extends StatefulWidget {
  final Chapter? chapter;
  final Volume? volume;
  final bool readOnly;

  const DramaOutlinePage({
    super.key,
    this.chapter,
    this.volume,
    this.readOnly = false,
  });

  @override
  State<DramaOutlinePage> createState() => _DramaOutlinePageState();
}

class _DramaOutlinePageState extends State<DramaOutlinePage> {
  late TextEditingController _ctrl;

  String get _title {
    if (widget.chapter != null) return '${widget.chapter!.title} · 章纲';
    if (widget.volume != null) return '${widget.volume!.title} · 卷纲';
    return '作品总纲';
  }

  String get _content {
    if (widget.chapter != null) return widget.chapter!.dramaOutline;
    if (widget.volume != null) return widget.volume!.dramaOutline;
    return EditorRepository.i.current.dramaOutline;
  }

  void _saveContent() {
    final text = _ctrl.text;
    if (widget.chapter != null) {
      widget.chapter!.dramaOutline = text;
    } else if (widget.volume != null) {
      widget.volume!.dramaOutline = text;
    } else {
      EditorRepository.i.current.dramaOutline = text;
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _content);
  }

  @override
  void didUpdateWidget(DramaOutlinePage old) {
    super.didUpdateWidget(old);
    if (old.chapter?.id != widget.chapter?.id || old.volume?.id != widget.volume?.id) {
      _saveContent();
      _ctrl.text = _content;
    }
  }

  @override
  void dispose() {
    _saveContent();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Title
            Text(_title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 28,
                fontWeight: FontWeight.w700, height: 36 / 28, color: AppColors.primary)),
            const SizedBox(height: 24),
            // Content area
            TextField(
              controller: _ctrl,
              readOnly: widget.readOnly,
              maxLines: null,
              style: const TextStyle(fontFamily: 'Source Serif 4', fontSize: 18,
                  fontWeight: FontWeight.w400, height: 1.8, color: AppColors.onSurfaceVariant),
              decoration: const InputDecoration(
                hintText: '在此编写大纲...',
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
