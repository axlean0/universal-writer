import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../theme/app_theme.dart';

class BodyOutlinePage extends StatefulWidget {
  final Chapter chapter;
  final bool readOnly;
  final ValueChanged<int>? onWordCountChanged;
  final ValueChanged<bool>? onUndoRedoChanged;

  const BodyOutlinePage({
    super.key,
    required this.chapter,
    this.readOnly = false,
    this.onWordCountChanged,
    this.onUndoRedoChanged,
  });

  @override
  State<BodyOutlinePage> createState() => BodyOutlinePageState();
}

class BodyOutlinePageState extends State<BodyOutlinePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  final List<_TextSnapshot> _undoStack = [];
  final List<_TextSnapshot> _redoStack = [];
  DateTime _lastSnapshot = DateTime.now();
  bool _suppressSnapshots = false;

  bool get _canUndo => _undoStack.isNotEmpty;
  bool get _canRedo => _redoStack.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.chapter.title);
    _bodyCtrl = TextEditingController(text: widget.chapter.body);
    _bodyCtrl.addListener(_onTextChanged);
    _notifyStats();
  }

  @override
  void didUpdateWidget(BodyOutlinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      _titleCtrl.text = widget.chapter.title;
      _bodyCtrl.text = widget.chapter.body;
      _undoStack.clear();
      _redoStack.clear();
      _notifyStats();
      _notifyUndoRedo();
    }
  }

  void _onTextChanged() {
    if (_suppressSnapshots) return;
    final now = DateTime.now();
    if (now.difference(_lastSnapshot).inSeconds >= 3) {
      _takeSnapshot();
      _lastSnapshot = now;
    }
    _notifyStats();
  }

  void _takeSnapshot() {
    _undoStack.add(_TextSnapshot(_titleCtrl.text, _bodyCtrl.text));
    if (_undoStack.length > 50) _undoStack.removeAt(0);
    _redoStack.clear();
    _notifyUndoRedo();
  }

  void undo() {
    if (!_canUndo) return;
    _suppressSnapshots = true;
    _redoStack.add(_TextSnapshot(_titleCtrl.text, _bodyCtrl.text));
    final snap = _undoStack.removeLast();
    _applySnapshot(snap);
    _suppressSnapshots = false;
    _lastSnapshot = DateTime.now();
    _notifyStats();
    _notifyUndoRedo();
  }

  void redo() {
    if (!_canRedo) return;
    _suppressSnapshots = true;
    _undoStack.add(_TextSnapshot(_titleCtrl.text, _bodyCtrl.text));
    final snap = _redoStack.removeLast();
    _applySnapshot(snap);
    _suppressSnapshots = false;
    _lastSnapshot = DateTime.now();
    _notifyStats();
    _notifyUndoRedo();
  }

  void _applySnapshot(_TextSnapshot snap) {
    _titleCtrl.text = snap.title;
    _bodyCtrl.text = snap.body;
    widget.chapter.title = snap.title;
    widget.chapter.body = snap.body;
  }

  void _notifyStats() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onWordCountChanged?.call(_wordCount);
    });
  }

  void _notifyUndoRedo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onUndoRedoChanged?.call(_canUndo || _canRedo);
    });
  }

  int get _wordCount {
    final text = _bodyCtrl.text;
    if (text.isEmpty) return 0;
    int count = 0;
    bool inWord = false;
    for (int i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == ' ' || c == '\n' || c == '\t') {
        if (inWord) { count++; inWord = false; }
      } else if (c.codeUnitAt(0) > 127) {
        count++;
        inWord = false;
      } else {
        inWord = true;
      }
    }
    if (inWord) count++;
    return count;
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onTextChanged);
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
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

  void handleUndo() => undo();
  void handleRedo() => redo();
  bool get canUndo => _canUndo;
  bool get canRedo => _canRedo;
  int get wordCount => _wordCount;
}

class _TextSnapshot {
  final String title;
  final String body;
  _TextSnapshot(this.title, this.body);
}
