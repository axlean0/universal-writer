import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/editor/chapter_tree.dart';
import '../../widgets/editor/editor_top_bar.dart';
import '../../widgets/editor/editor_right_panel.dart';
import 'body_outline_page.dart';

class EditorShell extends StatefulWidget {
  final String bookId;
  const EditorShell({super.key, required this.bookId});

  @override
  State<EditorShell> createState() => _EditorShellState();
}

class _EditorShellState extends State<EditorShell> {
  bool _topVisible = true;
  bool _leftVisible = true;
  bool _rightVisible = true;
  bool _readOnly = false;
  bool _quickViewExpanded = false;

  String? _activeChapterId;
  Chapter? get _activeChapter => EditorRepository.i.chapterById(_activeChapterId ?? '');

  // ── Search ──
  final _searchCtrl = TextEditingController();
  List<Chapter> _searchResults = [];

  void _search(String q) {
    if (q.isEmpty) { setState(() => _searchResults = []); return; }
    final results = <Chapter>[];
    for (final v in EditorRepository.i.current.volumes) {
      for (final c in v.chapters) {
        if (c.title.contains(q) || c.body.contains(q)) results.add(c);
      }
    }
    setState(() => _searchResults = results.take(6).toList());
  }

  void _jumpToChapter(Chapter c) {
    setState(() { _activeChapterId = c.id; _searchResults = []; });
    _searchCtrl.clear();
  }

  @override
  void initState() {
    super.initState();
    EditorRepository.i.load(widget.bookId);
    final first = EditorRepository.i.current.volumes.firstOrNull?.chapters.firstOrNull;
    if (first != null) _activeChapterId = first.id;
  }

  void _selectChapter(Chapter c) {
    if (_activeChapter != null && c.id != _activeChapterId) {
      // Auto-save current to memory before switching
      EditorRepository.i.current.volumes
          .expand((v) => v.chapters)
          .firstWhere((ch) => ch.id == _activeChapterId, orElse: () => c)
          .copyWith(); // no-op for mock, real would persist
    }
    setState(() => _activeChapterId = c.id);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // ── Top bar ──
        if (_topVisible)
          EditorTopBar(
            searchCtrl: _searchCtrl,
            searchResults: _searchResults,
            onSearch: _search,
            onJumpTo: _jumpToChapter,
            onToggleCollapse: () => setState(() => _topVisible = false),
          ),
        if (!_topVisible)
          _collapseToggle(Icons.expand_more, () => setState(() => _topVisible = true)),

        // ── Main content ──
        Expanded(
          child: Row(children: [
            // Left: Chapter tree
            if (_leftVisible)
              Stack(clipBehavior: Clip.none, children: [
                ChapterTree(
                  activeChapterId: _activeChapterId,
                  onSelectChapter: _selectChapter,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Positioned(
                  right: -10, top: 0, bottom: 0,
                  child: Center(
                    child: _edgeBtn(Icons.chevron_left, () => setState(() => _leftVisible = false)),
                  ),
                ),
              ]),
            if (!_leftVisible)
              _sideToggle(Icons.chevron_right, () => setState(() => _leftVisible = true)),

            // Center editor
            Expanded(
              child: _activeChapter != null
                  ? BodyOutlinePage(chapter: _activeChapter!, readOnly: _readOnly)
                  : const Center(child: Text('请选择一个章节开始写作',
                      style: TextStyle(color: AppColors.outline, fontSize: 15))),
            ),

            // Right panel
            if (_rightVisible)
              Stack(clipBehavior: Clip.none, children: [
                EditorRightPanel(
                  isReadOnly: _readOnly,
                  quickViewExpanded: _quickViewExpanded,
                  onToggleReadOnly: () => setState(() => _readOnly = !_readOnly),
                  onToggleFullscreen: () {},
                  onToggleFocus: () => setState(() {
                    _topVisible = false; _leftVisible = false; _rightVisible = false;
                  }),
                  onSave: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已保存'), duration: Duration(seconds: 1)),
                    );
                  },
                  onToggleQuickView: () => setState(() => _quickViewExpanded = !_quickViewExpanded),
                ),
                Positioned(
                  left: -10, top: 0, bottom: 0,
                  child: Center(
                    child: _edgeBtn(Icons.chevron_right, () => setState(() => _rightVisible = false)),
                  ),
                ),
              ]),
            if (!_rightVisible)
              _sideToggle(Icons.chevron_left, () => setState(() => _rightVisible = true)),
          ]),
        ),
      ]),
    );
  }

  Widget _collapseToggle(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant)),
    ),
  );

  Widget _sideToggle(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      width: 32,
      color: AppColors.surfaceContainerLow,
      child: Center(child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant)),
    ),
  );

  Widget _edgeBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 2)],
      ),
      child: Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
    ),
  );
}
