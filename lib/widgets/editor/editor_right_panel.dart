import 'package:flutter/material.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';

class EditorRightPanel extends StatefulWidget {
  final VoidCallback? onToggleReadOnly;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onToggleFocus;
  final VoidCallback? onSave;
  final bool isReadOnly;
  final bool quickViewExpanded;
  final VoidCallback? onToggleQuickView;

  const EditorRightPanel({
    super.key,
    this.onToggleReadOnly, this.onToggleFullscreen,
    this.onToggleFocus, this.onSave, this.isReadOnly = false,
    this.quickViewExpanded = false, this.onToggleQuickView,
  });

  @override
  State<EditorRightPanel> createState() => _EditorRightPanelState();
}

class _EditorRightPanelState extends State<EditorRightPanel> {
  int _tabIndex = 0; // 0=大纲, 1=卡片, 2=图谱

  static const _tabs = ['大纲', '卡片', '图谱'];

  @override
  Widget build(BuildContext context) {
    final book = EditorRepository.i.current;
    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 0.3)),
      ),
      child: Column(children: [
        // Segmented control
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
        // Quick view
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('快速查看', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                letterSpacing: 0.6, color: AppColors.outline)),
            Row(children: [
              InkWell(onTap: () {}, borderRadius: BorderRadius.circular(4),
                child: const Padding(padding: EdgeInsets.all(2),
                    child: Icon(Icons.filter_list, size: 18, color: AppColors.outline))),
              InkWell(onTap: widget.onToggleQuickView, borderRadius: BorderRadius.circular(4),
                child: Padding(padding: const EdgeInsets.all(2),
                  child: Icon(widget.quickViewExpanded ? Icons.close_fullscreen : Icons.open_in_full,
                      size: 18, color: AppColors.outline))),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        // Outline preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: widget.quickViewExpanded ? null : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.3),
                ),
                child: SingleChildScrollView(
                  child: Text(book.outlinePreview,
                    style: const TextStyle(fontFamily: 'Source Serif 4', fontSize: 13,
                        height: 1.6, color: AppColors.onSurfaceVariant)),
                ),
              ),
            ),
          ),
        ),
        // Function grid
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.3))),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 2.2,
            children: [
              _fnBtn(Icons.fullscreen, '全屏', widget.onToggleFullscreen),
              _fnBtn(Icons.self_improvement, '专注', widget.onToggleFocus),
              _fnBtn(Icons.undo, '撤销', null),
              _fnBtn(Icons.redo, '重做', null),
              _fnBtn(Icons.visibility, '显示', null),
              _fnBtn(Icons.lock, widget.isReadOnly ? '只读✓' : '只读', widget.onToggleReadOnly),
              _fnBtn(Icons.save, '保存', widget.onSave),
              _fnBtn(Icons.more_horiz, '更多', null),
              _fnBtn(Icons.text_fields, '1,240 字', null),
              _fnBtn(Icons.timer, '00:45', null),
            ],
          ),
        ),
        // Settings
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

  Widget _fnBtn(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: onTap != null ? AppColors.onSurfaceVariant : AppColors.outline),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: onTap != null ? AppColors.onSurfaceVariant : AppColors.outline)),
        ]),
      ),
    );
  }
}
