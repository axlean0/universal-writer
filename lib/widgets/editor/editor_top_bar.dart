import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/editor_models.dart';
import '../../theme/app_theme.dart';

class EditorTopBar extends StatefulWidget {
  final TextEditingController searchCtrl;
  final List<Chapter> searchResults;
  final ValueChanged<String> onSearch;
  final ValueChanged<Chapter> onJumpTo;
  final VoidCallback? onToggleCollapse;

  const EditorTopBar({
    super.key,
    required this.searchCtrl,
    required this.searchResults,
    required this.onSearch,
    required this.onJumpTo,
    this.onToggleCollapse,
  });

  @override
  State<EditorTopBar> createState() => _EditorTopBarState();
}

class _EditorTopBarState extends State<EditorTopBar> {
  final _findCtrl = TextEditingController();
  final _replaceCtrl = TextEditingController();
  final _focus = FocusNode();
  bool _panelOpen = false;
  bool _findReplaceMode = false;

  void _close() { setState(() => _panelOpen = false); _focus.unfocus(); }

  @override
  void dispose() { _findCtrl.dispose(); _replaceCtrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.background.withAlpha(204),
        border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5))),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          if (widget.onToggleCollapse != null)
            Padding(padding: const EdgeInsets.only(right: 12),
              child: InkWell(onTap: widget.onToggleCollapse, borderRadius: BorderRadius.circular(4),
                child: const Padding(padding: EdgeInsets.all(4),
                    child: Icon(Icons.expand_less, size: 18, color: AppColors.onSurfaceVariant)))),
          Expanded(child: _buildSearch()),
          const SizedBox(width: AppSpacing.stackMd),
          InkWell(
            onTap: () => setState(() => _findReplaceMode = !_findReplaceMode),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _findReplaceMode ? AppColors.primary : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999)),
              child: Text(_findReplaceMode ? '替换' : '查找',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _findReplaceMode ? Colors.white : AppColors.onSurfaceVariant)),
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          _iconBtn(Icons.delete_outline, '回收站'),
          const SizedBox(width: 4),
          _iconBtn(Icons.history, '历史'),
          const SizedBox(width: 4),
          _iconBtn(Icons.more_vert, '更多'),
        ]),
      )),
    );
  }

  Widget _buildSearch() {
    final hasResults = widget.searchResults.isNotEmpty;
    return TapRegion(
      onTapOutside: (_) => _close(),
      child: Shortcuts(
        shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
        child: Actions(actions: {DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _close())},
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: 38, child: Container(
              constraints: const BoxConstraints(maxWidth: 672),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: _focus.hasFocus ? AppColors.primary : AppColors.outline, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1))]),
              child: Row(children: [
                const Padding(padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.search, size: 20, color: AppColors.outline)),
                Expanded(child: TextField(
                  controller: widget.searchCtrl, focusNode: _focus,
                  onTap: () => setState(() => _panelOpen = true),
                  onChanged: widget.onSearch,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: '查找跳转', hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.outline),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                )),
              ]),
            )),
            // Search results
            if (_panelOpen && hasResults)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 672),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))]),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: widget.searchResults.map((c) => InkWell(
                      onTap: () { _close(); widget.onJumpTo(c); },
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(children: [
                          const Icon(Icons.article, size: 18, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            if (c.body.isNotEmpty)
                              Text(c.body.substring(0, c.body.length > 50 ? 50 : c.body.length),
                                style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                          ])),
                          const Icon(Icons.near_me, size: 16, color: AppColors.secondary),
                        ])),
                    )).toList()),
                ),
              ),
            // Replace sub-bar
            if (_panelOpen && _findReplaceMode)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 672),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))]),
                  child: Column(children: [
                    Row(children: [
                      const SizedBox(width: 60, child: Text('替换为', style: TextStyle(fontSize: 13, color: AppColors.outline))),
                      Expanded(child: TextField(
                        controller: _replaceCtrl, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15),
                        decoration: const InputDecoration(hintText: '替换文本', border: InputBorder.none, isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      _chip('替换', AppColors.primary, AppColors.onPrimary),
                      const SizedBox(width: 8),
                      _chip('全部替换', AppColors.primary, AppColors.onPrimary),
                      const SizedBox(width: 8),
                      _chip('上一个', AppColors.surfaceContainerLow, AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      _chip('下一个', AppColors.surfaceContainerLow, AppColors.onSurfaceVariant),
                    ]),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String t) =>
      IconButton(onPressed: () {}, icon: Icon(icon, size: 22), splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: t);

  Widget _chip(String label, Color bg, Color fg) => GestureDetector(
    onTap: () {},
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg))),
  );
}
