import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../theme/app_theme.dart';

class EditorRightPanel extends StatefulWidget {
  final VoidCallback? onToggleCollapse;
  final VoidCallback? onToggleReadOnly;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onToggleFocus;
  final VoidCallback? onSave;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onSelectBookOutline;
  final bool isReadOnly;
  final bool quickViewExpanded;
  final VoidCallback? onToggleQuickView;
  final int wordCount;
  final int elapsedSeconds;
  final bool canUndo;
  final bool canRedo;
  final EditorMode editorMode;
  final String outlineContent;
  final List<String> outlineFilterLabels;

  const EditorRightPanel({
    super.key,
    this.onToggleCollapse, this.onToggleReadOnly, this.onToggleFullscreen,
    this.onToggleFocus, this.onSave, this.onUndo, this.onRedo,
    this.onSelectBookOutline,
    this.isReadOnly = false, this.quickViewExpanded = false, this.onToggleQuickView,
    this.wordCount = 0, this.elapsedSeconds = 0,
    this.canUndo = false, this.canRedo = false,
    this.editorMode = EditorMode.body,
    this.outlineContent = '',
    this.outlineFilterLabels = const [],
  });

  @override
  State<EditorRightPanel> createState() => _EditorRightPanelState();
}

class _EditorRightPanelState extends State<EditorRightPanel> {
  int _tabIndex = 0;
  int? _filterIndex;
  final GlobalKey _filterBtnKey = GlobalKey();
  static const _tabs = ['大纲', '卡片', '图谱'];

  void _showFilterMenu() {
    if (widget.outlineFilterLabels.isEmpty) return;
    final box = _filterBtnKey.currentContext!.findRenderObject() as RenderBox;
    final off = box.localToGlobal(Offset.zero);
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
          off.dx - 80, off.dy + box.size.height + 4,
          off.dx + box.size.width, off.dy + box.size.height + 4),
      elevation: 8, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant)),
      items: [
        PopupMenuItem(value: 0, height: 36,
          child: Row(children: [
            Icon(_filterIndex == 0 ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('总纲', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
        ...widget.outlineFilterLabels.asMap().entries.where((e) => e.key > 0).map((e) {
          final isChapter = e.value.contains('章纲');
          return PopupMenuItem(value: e.key, height: 36,
            child: Row(children: [
              Icon(_filterIndex == e.key ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 18, color: _filterIndex == e.key ? AppColors.primary : AppColors.outline),
              const SizedBox(width: 10),
              if (isChapter) Padding(padding: const EdgeInsets.only(left: 20),
                  child: Text(e.value, style: TextStyle(fontSize: 13, color: _filterIndex == e.key ? AppColors.primary : AppColors.outline))),
              if (!isChapter) Text(e.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: _filterIndex == e.key ? AppColors.primary : AppColors.outline)),
            ]));
        }),
      ],
    ).then((v) { if (v != null && mounted) setState(() => _filterIndex = v < 0 ? null : v); });
  }

  Widget _quickViewHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('快速查看', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            letterSpacing: 0.6, color: AppColors.outline)),
          InkWell(
            key: _filterBtnKey,
            onTap: _showFilterMenu,
            borderRadius: BorderRadius.circular(4),
            child: Padding(padding: const EdgeInsets.all(2),
                child: Icon(Icons.filter_list, size: 18,
                    color: _filterIndex != null ? AppColors.secondary : AppColors.outline)),
          ),
      ]),
    );
  }

  Widget _outlinePreview() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(children: [
          Container(
            width: double.infinity, height: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.outlineVariant, width: 0.3),
            ),
            child: SingleChildScrollView(
              child: Text(widget.outlineContent,
                style: const TextStyle(fontFamily: 'Source Serif 4', fontSize: 13,
                    height: 1.6, color: AppColors.onSurfaceVariant)),
            ),
          ),
          Positioned(right: 4, bottom: 4,
            child: InkWell(
              onTap: widget.onToggleQuickView,
              borderRadius: BorderRadius.circular(4),
              child: Padding(padding: const EdgeInsets.all(4),
                child: Icon(widget.quickViewExpanded ? Icons.close_fullscreen : Icons.open_in_full,
                    size: 16, color: AppColors.outline)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _cardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: List.generate(6, (i) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.outlineVariant, width: 0.3),
            ),
          )),
        ),
        Positioned(right: 4, bottom: 4,
          child: InkWell(
            onTap: widget.onToggleQuickView,
            borderRadius: BorderRadius.circular(4),
            child: Padding(padding: const EdgeInsets.all(4),
              child: Icon(widget.quickViewExpanded ? Icons.close_fullscreen : Icons.open_in_full,
                  size: 16, color: AppColors.outline)),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 0.3)),
      ),
      child: Column(children: [
        if (widget.onToggleCollapse != null)
          InkWell(
            onTap: widget.onToggleCollapse,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.3))),
              child: const Center(child: Icon(Icons.chevron_right, size: 16, color: AppColors.onSurfaceVariant)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(999)),
            child: Row(children: List.generate(3, (i) {
              final sel = i == _tabIndex;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: sel ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 2)] : null,
                  ),
                  child: Text(_tabs[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w700, color: sel ? AppColors.primary : AppColors.onSurfaceVariant)),
                ),
              ));
            })),
          ),
        ),
        // Mode-specific top button
        if (widget.editorMode == EditorMode.drama && _tabIndex == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: widget.onSelectBookOutline,
              icon: const Icon(Icons.account_tree, size: 20),
              label: const Text('总纲', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              style: _primaryBtnStyle(),
            )),
          ),
        if (_tabIndex == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text('新建卡片', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              style: _primaryBtnStyle(),
            )),
          ),
        // Tab content
        if (_tabIndex == 0) ...[
          _quickViewHeader(),
          const SizedBox(height: 8),
          Expanded(child: _outlinePreview()),
        ],
        if (_tabIndex == 1) ...[
          _quickViewHeader(),
          const SizedBox(height: 8),
          Expanded(child: _cardGrid()),
        ],
        if (_tabIndex == 2)
          Expanded(
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.hub, size: 48, color: AppColors.outline.withAlpha(60)),
              const SizedBox(height: 8),
              Text('图谱显示框', style: TextStyle(fontSize: 12, color: AppColors.outline.withAlpha(120))),
            ])),
          ),
        // Function grid
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: widget.quickViewExpanded
              ? const SizedBox.shrink()
              : Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.3))),
            child: GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 2.2,
              children: [
                _fnBtn(Icons.fullscreen, '全屏', widget.onToggleFullscreen),
                _fnBtn(Icons.self_improvement, '专注', widget.onToggleFocus),
                _fnBtn(Icons.undo, '撤销', widget.canUndo ? widget.onUndo : null),
                _fnBtn(Icons.redo, '重做', widget.canRedo ? widget.onRedo : null),
                _fnBtn(Icons.visibility, '显示', null),
                _fnBtn(Icons.lock, '只读', widget.onToggleReadOnly, active: widget.isReadOnly),
                _fnBtn(Icons.save, '保存', widget.onSave),
                _fnBtn(Icons.more_horiz, '更多', null),
                _fnBtn(Icons.text_fields, '${widget.wordCount} 字', null),
                _fnBtn(Icons.timer, _fmtTime(widget.elapsedSeconds), null),
              ],
            ),
          ),
          ]),
        ),
        Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.3))),
          child: InkWell(
            onTap: () {},
            child: const Padding(padding: EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.settings, size: 20, color: AppColors.onSurfaceVariant),
                SizedBox(width: 8),
                Text('设置', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  String _fmtTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  ButtonStyle _primaryBtnStyle() => FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    padding: const EdgeInsets.symmetric(vertical: 10),
  );

  Widget _fnBtn(IconData icon, String label, VoidCallback? onTap, {bool active = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
              color: active ? AppColors.secondary : (onTap != null ? AppColors.onSurfaceVariant : AppColors.outline)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: active ? AppColors.onSurfaceVariant : (onTap != null ? AppColors.onSurfaceVariant : AppColors.outline))),
        ]),
      ),
    );
  }
}
