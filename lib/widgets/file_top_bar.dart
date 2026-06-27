import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/file_item.dart';

class FileTopBar extends StatefulWidget {
  final List<FileItem> allFiles;
  final List<FileItem> trashedFiles;
  final Function(String) onSearch;
  final Function(FileItem) onRestore;
  final Function(FileItem) onDeleteForever;
  final VoidCallback onClearTrash;
  final VoidCallback onToggleBatchMode;
  final Function(FileItem) onOpenFile;
  final Function(String) onSortChanged;
  final String currentSort; // 'name', 'date', 'size'
  final VoidCallback onImportTap;

  const FileTopBar({
    super.key,
    required this.allFiles,
    required this.trashedFiles,
    required this.onSearch,
    required this.onRestore,
    required this.onDeleteForever,
    required this.onClearTrash,
    required this.onToggleBatchMode,
    required this.onOpenFile,
    required this.onSortChanged,
    required this.currentSort,
    required this.onImportTap,
  });

  @override
  State<FileTopBar> createState() => _FileTopBarState();
}

class _FileTopBarState extends State<FileTopBar> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchOpen = false;

  List<FileItem> get _results {
    final q = _searchController.text;
    if (q.isEmpty) return [];
    return widget.allFiles.where((f) => f.name.contains(q)).take(6).toList();
  }

  void _closeSearch() {
    setState(() => _searchOpen = false);
    _searchFocus.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(204),
        border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Expanded(child: _buildSearchArea()),
            const SizedBox(width: AppSpacing.stackMd),
            _buildTrashBtn(),
            const SizedBox(width: 4),
            _buildHistoryBtn(),
            const SizedBox(width: 4),
            _buildMoreBtn(),
          ]),
        ),
      ),
    );
  }

  // ── Search (simplified: no type chips) ──
  Widget _buildSearchArea() {
    return TapRegion(
      onTapOutside: (_) => _closeSearch(),
      child: Shortcuts(
        shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
        child: Actions(actions: {DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _closeSearch())},
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 38,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 672),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: _searchFocus.hasFocus ? AppColors.primary : AppColors.outline,
                    width: 1.5,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(children: [
                  const Padding(padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search, size: 20, color: AppColors.outline)),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: widget.onSearch,
                      onTap: () => setState(() => _searchOpen = true),
                      style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        hintText: '搜索文件',
                        hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.outline),
                        border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                        filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            if (_searchOpen && _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 672),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))],
                  ),
                  child: _results.isEmpty
                      ? const Padding(padding: EdgeInsets.all(24),
                          child: Text('未找到匹配文件', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
                      : Column(mainAxisSize: MainAxisSize.min,
                          children: _results.map((f) => _buildSearchHit(f)).toList()),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchHit(FileItem f) {
    return InkWell(
      onTap: () { _closeSearch(); widget.onOpenFile(f); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(f.isFolder ? Icons.folder : Icons.description, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              if (f.description.isNotEmpty)
                Text(f.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.outline)),
            ]),
          ),
          const Icon(Icons.near_me, size: 18, color: AppColors.secondary),
        ]),
      ),
    );
  }

  // ── Trash ──
  Widget _buildTrashBtn() {
    return Builder(builder: (ctx) => IconButton(
      onPressed: () => _showPanel(ctx, _buildTrashContent),
      icon: const Icon(Icons.delete_outline, size: 22),
      splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '回收站',
    ));
  }

  Widget _buildTrashContent(BuildContext dialogCtx) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow.withAlpha(80),
            border: const Border(bottom: BorderSide(color: AppColors.outlineVariant))),
          child: const Row(children: [
            Icon(Icons.delete_outline, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text('回收站', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ),
        Flexible(
          child: widget.trashedFiles.isEmpty
              ? const Padding(padding: EdgeInsets.all(32),
                  child: Text('回收站为空', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
              : ListView.separated(
                  shrinkWrap: true, itemCount: widget.trashedFiles.length,
                  separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
                  itemBuilder: (_, i) {
                    final f = widget.trashedFiles[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(f.isFolder ? Icons.folder : Icons.description, size: 18, color: AppColors.outline),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          Text('删除于 ${f.deletedAt != null ? '${DateTime.now().difference(f.deletedAt!).inDays}天前' : '刚刚'}',
                            style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                        ])),
                        IconButton(onPressed: () { widget.onRestore(f); Navigator.of(dialogCtx).pop(); },
                          icon: const Icon(Icons.restore_from_trash, size: 18),
                          splashRadius: 16, color: AppColors.secondary, tooltip: '还原'),
                        IconButton(onPressed: () { widget.onDeleteForever(f); Navigator.of(dialogCtx).pop(); },
                          icon: const Icon(Icons.delete_forever, size: 18),
                          splashRadius: 16, color: AppColors.onSurfaceVariant, tooltip: '彻底删除'),
                      ]),
                    );
                  },
                ),
        ),
        if (widget.trashedFiles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppColors.outlineVariant))),
            child: Center(child: TextButton(
              onPressed: () { widget.onClearTrash(); Navigator.of(dialogCtx).pop(); },
              child: const Text('清空回收站', style: TextStyle(fontSize: 12, color: AppColors.outline)),
            )),
          ),
      ]),
    );
  }

  // ── History ──
  Widget _buildHistoryBtn() {
    return Builder(builder: (ctx) => IconButton(
      onPressed: () => _showPanel(ctx, _buildHistoryContent),
      icon: const Icon(Icons.history, size: 22),
      splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '历史',
    ));
  }

  Widget _buildHistoryContent(BuildContext dialogCtx) {
    final recent = List<FileItem>.from(widget.allFiles)
      ..sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));

    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow.withAlpha(80),
            border: const Border(bottom: BorderSide(color: AppColors.outlineVariant))),
          child: const Row(children: [
            Icon(Icons.history, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text('最近打开', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ),
        Flexible(
          child: recent.isEmpty
              ? const Padding(padding: EdgeInsets.all(32),
                  child: Text('暂无历史记录', style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
              : ListView.separated(
                  shrinkWrap: true, itemCount: recent.length,
                  separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
                  itemBuilder: (_, i) {
                    final f = recent[i];
                    final days = DateTime.now().difference(f.lastModifiedAt).inDays;
                    final ts = days == 0 ? '今天' : days == 1 ? '昨天' : '$days天前';
                    return InkWell(
                      onTap: () { Navigator.of(dialogCtx).pop(); widget.onOpenFile(f); },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Icon(f.isFolder ? Icons.folder : Icons.description, size: 18, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            Text(ts, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                          ])),
                          const Icon(Icons.open_in_new, size: 16, color: AppColors.secondary),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // ── More menu ──
  Widget _buildMoreBtn() {
    return Builder(builder: (ctx) => IconButton(
      onPressed: () => _showPanel(ctx, _buildMoreContent),
      icon: const Icon(Icons.more_vert, size: 22),
      splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '更多',
    ));
  }

  Widget _buildMoreContent(BuildContext dialogCtx) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('排序'),
        _sortOpt('名称', 'name', Icons.sort_by_alpha),
        _sortOpt('最近修改', 'date', Icons.access_time),
        _sortOpt('文件大小', 'size', Icons.data_usage),
        const Divider(color: AppColors.outlineVariant),
        _sectionHeader('管理'),
        _menuAction(Icons.checklist, '批量管理', () { widget.onToggleBatchMode(); Navigator.of(dialogCtx).pop(); }),
        const Divider(color: AppColors.outlineVariant),
        _sectionHeader('导入'),
        _menuAction(Icons.upload_file, '导入文件', () { Navigator.of(dialogCtx).pop(); widget.onImportTap(); }),
      ]),
    );
  }

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        letterSpacing: 0.6, color: AppColors.outline)),
  );

  Widget _sortOpt(String label, String value, IconData icon) {
    final sel = widget.currentSort == value;
    return InkWell(
      onTap: () { widget.onSortChanged(value); Navigator.of(context).pop(); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: sel ? AppColors.secondary : AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: sel ? AppColors.onSurface : AppColors.onSurfaceVariant)),
          const Spacer(),
          if (sel) const Icon(Icons.check_circle, size: 18, color: AppColors.secondary),
        ]),
      ),
    );
  }

  Widget _menuAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.onSurface),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.onSurface)),
        ]),
      ),
    );
  }

  // ── Shared panel overlay helper ──
  void _showPanel(BuildContext btnCtx, Widget Function(BuildContext dialogCtx) contentBuilder) {
    final rb = btnCtx.findRenderObject() as RenderBox;
    final offset = rb.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context, barrierColor: Colors.transparent, barrierDismissible: true,
      barrierLabel: 'panel',
      pageBuilder: (dialogCtx, _, _) => Stack(children: [
        Positioned(
          top: offset.dy + rb.size.height + 8,
          right: screenW - offset.dx - rb.size.width,
          child: Material(elevation: 8, borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Colors.white, child: contentBuilder(dialogCtx)),
        ),
      ]),
    );
  }
}
