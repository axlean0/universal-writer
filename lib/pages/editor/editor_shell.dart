import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/editor/chapter_tree.dart';
import '../../widgets/editor/editor_top_bar.dart';
import '../../widgets/editor/editor_right_panel.dart';
import 'body_outline_page.dart';
import 'drama_outline_page.dart';
import 'drama_card_page.dart';

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
  EditorMode _editorMode = EditorMode.body;
  int _rightPanelTab = 0; // 0=大纲, 1=卡片, 2=图谱

  String? _activeChapterId;
  String? _activeVolumeId; // for drama mode — volume selection independent of chapter
  Chapter? get _activeChapter => EditorRepository.i.chapterById(_activeChapterId ?? '');
  Volume? get _activeVolume {
    if (_activeVolumeId != null) return EditorRepository.i.current.volumes.firstWhere((v) => v.id == _activeVolumeId);
    if (_activeChapter != null) {
      for (final v in EditorRepository.i.current.volumes) {
        if (v.chapters.any((c) => c.id == _activeChapterId)) return v;
      }
    }
    return null;
  }

  void _selectChapter(Chapter c) => setState(() {
    _activeChapterId = c.id; _activeVolumeId = null;
  });
  void _selectVolume(Volume v) => setState(() {
    _activeVolumeId = v.id; _activeChapterId = null;
  });
  void _selectBook() => setState(() {
    _activeChapterId = null; _activeVolumeId = null;
  });

  Widget _buildCenterEditor() {
    // 剧作 + 卡片 tab → card manager
    if (_editorMode == EditorMode.drama && _rightPanelTab == 1) {
      return const DramaCardPage();
    }
    // 正文 → text editor
    if (_editorMode == EditorMode.body) {
      if (_activeChapter != null) {
        return BodyOutlinePage(
          key: _editorKey,
          chapter: _activeChapter!,
          readOnly: _readOnly,
          onWordCountChanged: (c) => setState(() => _wordCount = c),
          onUndoRedoChanged: (v) => setState(() {
            _canUndo = _editorKey.currentState?.canUndo ?? false;
            _canRedo = _editorKey.currentState?.canRedo ?? false;
          }),
        );
      }
      return const Center(child: Text('请选择一个章节开始写作',
          style: TextStyle(color: AppColors.outline, fontSize: 15)));
    }
    // 剧作 + 其他 → drama outline
    return DramaOutlinePage(
      chapter: _activeChapter, volume: _activeVolume, readOnly: _readOnly,
    );
  }

  // Stats passed from BodyOutlinePage to RightPanel
  int _wordCount = 0;
  int _elapsedTime = 0;
  bool _canUndo = false;
  bool _canRedo = false;
  final GlobalKey<BodyOutlinePageState> _editorKey = GlobalKey();

  // Global timer — starts on editor entry, never resets
  Timer? _timer;

  // Quick view content — synced with current selection
  String get _outlineContent {
    final book = EditorRepository.i.current;
    if (_editorMode == EditorMode.drama) {
      if (_activeChapter != null) return _activeChapter!.dramaOutline;
      if (_activeVolume != null) return _activeVolume!.dramaOutline;
      return book.dramaOutline;
    }
    return book.outlinePreview;
  }

  List<String> get _outlineFilterLabels {
    final book = EditorRepository.i.current;
    final labels = <String>['总纲'];
    for (final v in book.volumes) {
      labels.add('${v.title}·卷纲');
      for (final c in v.chapters) {
        labels.add('${c.title}·章纲');
      }
    }
    return labels;
  }

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedTime++);
    });
  }

  @override
  void dispose() { _timer?.cancel(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // ── Main Row (bottom layer) ──
        Row(children: [
          if (_leftVisible)
            SizedBox(
              width: AppSpacing.sidebarWidth,
              child: ChapterTree(
                activeChapterId: _activeChapterId,
                activeVolumeId: _activeVolumeId,
                initialMode: _editorMode,
                onSelectChapter: _selectChapter,
                onSelectVolume: _selectVolume,
                onBack: () => Navigator.of(context).pop(),
                onChanged: () => setState(() {}),
                onModeChanged: (mode) => setState(() => _editorMode = mode),
              ),
            ),
          if (!_leftVisible)
            const SizedBox(width: 8),

          Expanded(
            child: Column(children: [
              if (_topVisible)
                EditorTopBar(
                  searchCtrl: _searchCtrl, searchResults: _searchResults,
                  onSearch: _search, onJumpTo: _jumpToChapter,
                  onToggleCollapse: () => setState(() => _topVisible = false),
                ),
              if (!_topVisible)
                _collapseToggle(Icons.expand_more, () => setState(() => _topVisible = true)),

              Expanded(
                child: Row(children: [
                  Expanded(
                    child: _buildCenterEditor(),
                  ),
                  if (_rightVisible)
                    SizedBox(
                      width: AppSpacing.sidebarWidth,
                      child: EditorRightPanel(
                        isReadOnly: _readOnly, quickViewExpanded: _quickViewExpanded,
                        wordCount: _wordCount, elapsedSeconds: _elapsedTime,
                        canUndo: _canUndo, canRedo: _canRedo,
                        editorMode: _editorMode,
                        outlineContent: _outlineContent,
                        outlineFilterLabels: _outlineFilterLabels,
                        onSelectBookOutline: _selectBook,
                        onTabChanged: (i) => setState(() => _rightPanelTab = i),
                        onUndo: () { _editorKey.currentState?.handleUndo(); },
                        onRedo: () { _editorKey.currentState?.handleRedo(); },
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
                    ),
                ]),
              ),
            ]),
          ),
        ]),
        // ── Collapse/expand buttons (top layer — renders above Row) ──
        if (_leftVisible)
          Positioned(
            left: AppSpacing.sidebarWidth - 12, top: 0, bottom: 0,
            child: Center(
              child: _edgeBtn(Icons.chevron_left, () => setState(() => _leftVisible = false)),
            ),
          ),
        if (!_leftVisible)
          Positioned(
            left: -4, top: 0, bottom: 0,
            child: Center(
              child: _edgeBtn(Icons.chevron_right, () => setState(() => _leftVisible = true)),
            ),
          ),
        if (_rightVisible)
          Positioned(
            right: AppSpacing.sidebarWidth - 12, top: 0, bottom: 0,
            child: Center(
              child: _edgeBtn(Icons.chevron_right, () => setState(() => _rightVisible = false)),
            ),
          ),
        if (!_rightVisible)
          Positioned(
            right: -4, top: 0, bottom: 0,
            child: Center(
              child: _edgeBtn(Icons.chevron_left, () => setState(() => _rightVisible = true)),
            ),
          ),
      ]),
    );
  }

  Widget _collapseToggle(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 5),
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
