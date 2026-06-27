import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/material_item.dart';
import 'search_filter_chips.dart';

class MaterialTopBar extends StatefulWidget {
  final List<MaterialItem> allItems;
  final List<MaterialItem> trashedItems;
  final Function(String) onSearch;
  final Function(MaterialItem) onRestore;
  final Function(MaterialItem) onDeleteForever;
  final VoidCallback onClearTrash;
  final VoidCallback onToggleBatchMode;
  final Function(MaterialItem) onOpenItem;
  final Function(String) onSortChanged;
  final String currentSort;
  final VoidCallback onImportTap;

  const MaterialTopBar({
    super.key,
    required this.allItems, required this.trashedItems,
    required this.onSearch, required this.onRestore,
    required this.onDeleteForever, required this.onClearTrash,
    required this.onToggleBatchMode, required this.onOpenItem,
    required this.onSortChanged, required this.currentSort,
    required this.onImportTap,
  });

  @override
  State<MaterialTopBar> createState() => _MaterialTopBarState();
}

class _MaterialTopBarState extends State<MaterialTopBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _panelOpen = false;
  SearchFilterState _filterState = const SearchFilterState();

  Map<String, int> get _typeCounts {
    final m = <String, int>{};
    for (final t in [MaterialType.document, MaterialType.pdf, MaterialType.image, MaterialType.other]) {
      m[t.label] = widget.allItems.where((i) => i.type == t).length;
    }
    return m;
  }

  List<MaterialItem> get _results {
    final q = _ctrl.text;
    if (q.isEmpty) return [];
    return widget.allItems.where((i) {
      if (!i.name.contains(q)) return false;
      if (_filterState.isAll) return true;
      return _filterState.selectedLabels.contains(i.type.label);
    }).take(6).toList();
  }

  void _close() { setState(() => _panelOpen = false); _focus.unfocus(); }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(204),
        border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: _buildSearchArea()),
          const SizedBox(width: AppSpacing.stackMd),
          _buildBtn(Icons.delete_outline, '回收站', _buildTrashContent),
          const SizedBox(width: 4),
          _buildBtn(Icons.history, '历史', _buildHistoryContent),
          const SizedBox(width: 4),
          _buildBtn(Icons.more_vert, '更多', _buildMoreContent),
        ]),
      )),
    );
  }

  // ── Search with type chips ──
  Widget _buildSearchArea() {
    return TapRegion(
      onTapOutside: (_) => _close(),
      child: Shortcuts(
        shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
        child: Actions(actions: {DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _close())},
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: 38, child: Container(
              constraints: const BoxConstraints(maxWidth: 672),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: _focus.hasFocus ? AppColors.primary : AppColors.outline, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Row(children: [
                const Padding(padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.search, size: 20, color: AppColors.outline)),
                Expanded(child: TextField(
                  controller: _ctrl, focusNode: _focus,
                  onChanged: widget.onSearch,
                  onTap: () => setState(() => _panelOpen = true),
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: '搜索素材',
                    hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.outline),
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                )),
              ]),
            )),
            if (_panelOpen) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 672),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SearchFilterChips(
                      labels: const ['文档', 'PDF', '图片', '其他'],
                      counts: _typeCounts,
                      onChanged: (state) => setState(() => _filterState = state),
                    ),
                  ),
                  if (_ctrl.text.isNotEmpty) ...[
                    if (_results.isEmpty)
                      const Padding(padding: EdgeInsets.all(24),
                          child: Text('未找到匹配素材', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
                    else
                      ..._results.map((i) => InkWell(
                        onTap: () { _close(); widget.onOpenItem(i); },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(children: [
                            Icon(_iconForType(i.type), size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(i.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              Text('${i.type.label} · ${formatMaterialSize(i.size)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                            ])),
                            const Icon(Icons.near_me, size: 18, color: AppColors.secondary),
                          ]),
                        ),
                      )),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Shared button + panel overlay ──
  Widget _buildBtn(IconData icon, String tooltip, Widget Function(BuildContext) content) {
    return Builder(builder: (ctx) => IconButton(
      onPressed: () => _showPanel(ctx, content),
      icon: Icon(icon, size: 22), splashRadius: 20,
      color: AppColors.onSurfaceVariant, tooltip: tooltip,
    ));
  }

  void _showPanel(BuildContext btnCtx, Widget Function(BuildContext) content) {
    final rb = btnCtx.findRenderObject() as RenderBox;
    final off = rb.localToGlobal(Offset.zero);
    final sw = MediaQuery.of(context).size.width;
    showGeneralDialog(
      context: context, barrierColor: Colors.transparent, barrierDismissible: true, barrierLabel: 'p',
      pageBuilder: (c, _, _) => Stack(children: [
        Positioned(top: off.dy + rb.size.height + 8, right: sw - off.dx - rb.size.width,
          child: Material(elevation: 8, borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Colors.white, child: content(c))),
      ]),
    );
  }

  Widget _buildTrashContent(BuildContext c) => _panelShell(
    const Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.primary), SizedBox(width: 8),
      Text('回收站', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))]),
    width: 320, maxH: 400,
    children: widget.trashedItems.isEmpty
        ? const Padding(padding: EdgeInsets.all(32), child: Text('回收站为空', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
        : ListView.separated(shrinkWrap: true, itemCount: widget.trashedItems.length,
            separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
            itemBuilder: (_, i) {
              final item = widget.trashedItems[i];
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Icon(_iconForType(item.type), size: 18, color: AppColors.outline), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text('删除于 ${item.deletedAt != null ? '${DateTime.now().difference(item.deletedAt!).inDays}天前' : '刚刚'}',
                        style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                  ])),
                  IconButton(onPressed: () { widget.onRestore(item); Navigator.of(c).pop(); },
                      icon: const Icon(Icons.restore_from_trash, size: 18), splashRadius: 16, color: AppColors.secondary),
                  IconButton(onPressed: () { widget.onDeleteForever(item); Navigator.of(c).pop(); },
                      icon: const Icon(Icons.delete_forever, size: 18), splashRadius: 16, color: AppColors.onSurfaceVariant),
                ]));
            }),
    footer: widget.trashedItems.isEmpty ? null : TextButton(
      onPressed: () { widget.onClearTrash(); Navigator.of(c).pop(); },
      child: const Text('清空回收站', style: TextStyle(fontSize: 12, color: AppColors.outline)),
    ),
  );

  Widget _buildHistoryContent(BuildContext c) {
    final recent = List<MaterialItem>.from(widget.allItems)
      ..sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    return _panelShell(
      const Row(children: [Icon(Icons.history, size: 18, color: AppColors.primary), SizedBox(width: 8),
        Text('最近打开', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))]),
      width: 300, maxH: 400,
      children: recent.isEmpty
          ? const Padding(padding: EdgeInsets.all(32), child: Text('暂无历史记录', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
          : ListView.separated(shrinkWrap: true, itemCount: recent.length,
              separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
              itemBuilder: (_, i) {
                final item = recent[i];
                final days = DateTime.now().difference(item.lastOpenedAt).inDays;
                final ts = days == 0 ? '今天' : days == 1 ? '昨天' : '$days天前';
                return InkWell(onTap: () { Navigator.of(c).pop(); widget.onOpenItem(item); },
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Icon(_iconForType(item.type), size: 18, color: AppColors.primary), const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        Text(ts, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                      ])),
                      const Icon(Icons.open_in_new, size: 16, color: AppColors.secondary),
                    ])));
              }),
    );
  }

  Widget _buildMoreContent(BuildContext c) => _panelShell(null, width: 256, noHeader: true, children: Column(
    mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _secHdr('排序'),
      _sortOpt('素材类型', 'type', Icons.sort_by_alpha),
      _sortOpt('最近上传', 'date', Icons.access_time),
      _sortOpt('文件大小', 'size', Icons.data_usage),
      const Divider(color: AppColors.outlineVariant),
      _secHdr('管理'),
      _menuAct(Icons.checklist, '批量管理', () { widget.onToggleBatchMode(); Navigator.of(c).pop(); }),
      const Divider(color: AppColors.outlineVariant),
      _secHdr('导入'),
      _menuAct(Icons.upload_file, '上传素材', () { Navigator.of(c).pop(); widget.onImportTap(); }),
    ],
  ));

  // Helpers
  Widget _panelShell(Widget? header, {double width = 320, double maxH = 400, bool noHeader = false,
    Widget? children, Widget? footer}) {
    return Container(width: width, constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!noHeader && header != null)
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow.withAlpha(80),
              border: const Border(bottom: BorderSide(color: AppColors.outlineVariant))),
            child: header),
        if (children != null) Flexible(child: children),
        if (footer != null)
          Container(padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppColors.outlineVariant))),
            child: Center(child: footer)),
      ]),
    );
  }

  Widget _secHdr(String t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)));

  Widget _sortOpt(String label, String val, IconData ic) {
    final sel = widget.currentSort == val;
    return InkWell(onTap: () { widget.onSortChanged(val); Navigator.of(context).pop(); },
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(ic, size: 18, color: sel ? AppColors.secondary : AppColors.onSurfaceVariant), const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: sel ? AppColors.onSurface : AppColors.onSurfaceVariant)),
          const Spacer(),
          if (sel) const Icon(Icons.check_circle, size: 18, color: AppColors.secondary),
        ])));
  }

  Widget _menuAct(IconData ic, String label, VoidCallback onTap) => InkWell(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [Icon(ic, size: 18, color: AppColors.onSurface), const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.onSurface))])));

  static IconData _iconForType(MaterialType t) {
    switch (t) {
      case MaterialType.document: return Icons.description;
      case MaterialType.pdf:      return Icons.picture_as_pdf;
      case MaterialType.image:    return Icons.image;
      case MaterialType.video:    return Icons.videocam;
      case MaterialType.audio:    return Icons.audiotrack;
      case MaterialType.other:    return Icons.insert_drive_file;
    }
  }
}
