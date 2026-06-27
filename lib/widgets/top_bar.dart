import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import 'search_filter_chips.dart';

/// Top bar with search, recycle bin, history, and more menu.
class AppTopBar extends StatefulWidget {
  final List<Book> books;
  final List<Book> trashedBooks;
  final Function(String) onSearch;
  final Function(Book) onRestore;
  final Function(Book) onDeleteForever;
  final VoidCallback onClearTrash;
  final VoidCallback onToggleBatchMode;
  final SortMode currentSort;
  final Function(SortMode) onSortChanged;
  final VoidCallback onImportTap;
  final ViewMode viewMode;
  final Function(Book) onOpenBook;

  const AppTopBar({
    super.key,
    required this.books,
    required this.trashedBooks,
    required this.onSearch,
    required this.onRestore,
    required this.onDeleteForever,
    required this.onClearTrash,
    required this.onToggleBatchMode,
    required this.currentSort,
    required this.onSortChanged,
    required this.onImportTap,
    required this.viewMode,
    required this.onOpenBook,
  });

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchPanelOpen = false;
  SearchFilterState _filterState = const SearchFilterState();

  Map<String, int> get _typeCounts => {
    '作品': widget.books.length,
    '正文': widget.books.fold(0, (s, b) => s + (b.wordCount > 0 ? 3 : 1)),
    '大纲': widget.books.length ~/ 3,
    '卡片': widget.books.fold(0, (s, b) => s + (b.wordCount ~/ 1000)),
    '图谱': 0,
  };

  @override
  void initState() {
    super.initState();
  }

  void _closeSearch() {
    setState(() => _searchPanelOpen = false);
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
          child: Row(
            children: [
              Expanded(child: _buildSearchArea()),
              const SizedBox(width: AppSpacing.stackMd),
              _buildTrashButton(),
              const SizedBox(width: 4),
              _buildHistoryButton(),
              const SizedBox(width: 4),
              _buildMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────── Search ────────────

  Widget _buildSearchArea() {
    return TapRegion(
      onTapOutside: (_) => _closeSearch(),
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) => _closeSearch(),
            ),
          },
          child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Single pill container — no nesting
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
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.search, size: 20, color: AppColors.outline),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: widget.onSearch,
                    onTap: () => setState(() => _searchPanelOpen = true),
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      hintText: '开始查找',
                      hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.outline),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_searchPanelOpen) _buildSearchPanel(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSearchPanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 672),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchFilterChips(
                labels: const ['作品', '正文', '大纲', '卡片', '图谱'],
                counts: _typeCounts,
                onChanged: (state) => setState(() => _filterState = state),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              ...widget.books
                  .where((b) => (_filterState.isAll || _filterState.selectedLabels.contains('作品')) &&
                      (b.title.contains(_searchController.text) ||
                       b.description.contains(_searchController.text)))
                  .take(5)
                  .map(_buildSearchResult),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult(Book book) {
    return InkWell(
      onTap: _closeSearch,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('《${book.title}》',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              if (book.description.isNotEmpty)
                Text(book.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.outline)),
            ]),
          ),
          const Icon(Icons.near_me, size: 20, color: AppColors.secondary),
        ]),
      ),
    );
  }

  // ──────────── Trash ────────────

  Widget _buildTrashButton() {
    return Builder(
      builder: (ctx) => IconButton(
        onPressed: () => _showTrashPanel(ctx),
        icon: const Icon(Icons.delete_outline, size: 22),
        splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '回收站',
      ),
    );
  }

  void _showTrashPanel(BuildContext buttonContext) {
    final rb = buttonContext.findRenderObject() as RenderBox;
    final offset = rb.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'trash',
      pageBuilder: (dialogCtx, _, _) => Stack(children: [
        Positioned(
          top: offset.dy + rb.size.height + 8,
          right: screenW - offset.dx - rb.size.width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Colors.white,
            child: _buildTrashPanelContent(dialogCtx),
          ),
        ),
      ]),
    );
  }

  Widget _buildTrashPanelContent(BuildContext dialogCtx) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withAlpha(80),
            border: const Border(bottom: BorderSide(color: AppColors.outlineVariant)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('回收站', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            Row(children: [
              Text('自动清理: 30天', style: TextStyle(fontSize: 10, color: AppColors.outline.withAlpha(180))),
              const SizedBox(width: 4),
              Column(children: [
                InkWell(onTap: () {}, child: const Icon(Icons.expand_less, size: 12, color: AppColors.outline)),
                InkWell(onTap: () {}, child: const Icon(Icons.expand_more, size: 12, color: AppColors.outline)),
              ]),
            ]),
          ]),
        ),
        Flexible(
          child: widget.trashedBooks.isEmpty
              ? const Padding(padding: EdgeInsets.all(32), child: Text('回收站为空',
                  style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.trashedBooks.length,
                  separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
                  itemBuilder: (_, index) {
                    final book = widget.trashedBooks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(book.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            const SizedBox(height: 2),
                            Text('删除于 ${book.deletedAt != null ? "${DateTime.now().difference(book.deletedAt!).inDays}天前" : "刚刚"}',
                              style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                          ]),
                        ),
                        IconButton(
                          onPressed: () { widget.onRestore(book); Navigator.of(dialogCtx).pop(); },
                          icon: const Icon(Icons.restore_from_trash, size: 18),
                          splashRadius: 16, color: AppColors.secondary, tooltip: '还原',
                        ),
                        IconButton(
                          onPressed: () { widget.onDeleteForever(book); Navigator.of(dialogCtx).pop(); },
                          icon: const Icon(Icons.delete_forever, size: 18),
                          splashRadius: 16, color: AppColors.onSurfaceVariant, tooltip: '彻底删除',
                        ),
                      ]),
                    );
                  },
                ),
        ),
        if (widget.trashedBooks.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Center(
              child: TextButton(
                onPressed: () { widget.onClearTrash(); Navigator.of(dialogCtx).pop(); },
                child: const Text('清空回收站', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              ),
            ),
          ),
      ]),
    );
  }

  // ──────────── History ────────────

  Widget _buildHistoryButton() {
    return Builder(
      builder: (ctx) => IconButton(
        onPressed: () => _showHistoryPanel(ctx),
        icon: const Icon(Icons.history, size: 22),
        splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '历史',
      ),
    );
  }

  void _showHistoryPanel(BuildContext buttonContext) {
    final rb = buttonContext.findRenderObject() as RenderBox;
    final offset = rb.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;
    final recent = List<Book>.from(widget.books)
      ..sort((a, b) => b.lastEditedAt.compareTo(a.lastEditedAt));

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'history',
      pageBuilder: (dialogCtx, _, _) => Stack(children: [
        Positioned(
          top: offset.dy + rb.size.height + 8,
          right: screenW - offset.dx - rb.size.width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Colors.white,
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withAlpha(80),
                    border: const Border(bottom: BorderSide(color: AppColors.outlineVariant)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.history, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('最近打开', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                ),
                Flexible(
                  child: recent.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Text('暂无历史记录',
                          style: TextStyle(fontSize: 14, color: AppColors.outline), textAlign: TextAlign.center))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: recent.length,
                          separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
                          itemBuilder: (_, index) {
                            final book = recent[index];
                            final days = DateTime.now().difference(book.lastEditedAt).inDays;
                            final timeStr = days == 0
                                ? '今天 ${book.lastEditedAt.hour}:${book.lastEditedAt.minute.toString().padLeft(2, '0')}'
                                : days == 1 ? '昨天' : '$days天前';
                            return InkWell(
                              onTap: () {
                                Navigator.of(dialogCtx).pop();
                                widget.onOpenBook(book);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(book.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                                      const SizedBox(height: 2),
                                      Text(timeStr, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                                    ]),
                                  ),
                                  const Icon(Icons.open_in_new, size: 16, color: AppColors.secondary),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ──────────── More Menu ────────────

  Widget _buildMoreButton() {
    return Builder(
      builder: (ctx) => IconButton(
        onPressed: () => _showMoreMenu(ctx),
        icon: const Icon(Icons.more_vert, size: 22),
        splashRadius: 20, color: AppColors.onSurfaceVariant, tooltip: '更多',
      ),
    );
  }

  void _showMoreMenu(BuildContext buttonContext) {
    final rb = buttonContext.findRenderObject() as RenderBox;
    final offset = rb.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'more',
      pageBuilder: (ctx, _, _) => Stack(children: [
        Positioned(
          top: offset.dy + rb.size.height + 8,
          right: screenW - offset.dx - rb.size.width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: Colors.white,
            child: _buildMoreMenuContent(),
          ),
        ),
      ]),
    );
  }

  Widget _buildMoreMenuContent() {
    final isGroupedView = widget.viewMode == ViewMode.grouped;

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('排序', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
        ),
        _buildSortOption('名称 A-Z', SortMode.nameAsc, Icons.sort_by_alpha),
        _buildSortOption('最近编辑', SortMode.lastEdited, Icons.access_time),
        _buildSortOption('字数最多', SortMode.wordCount, Icons.data_usage),
        const Divider(color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('管理', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
        ),
        _buildMenuAction(Icons.checklist, '批量管理', onTap: () {
          widget.onToggleBatchMode();
          Navigator.of(context).pop();
        }),
        const SizedBox(height: 4),
        if (isGroupedView)
          const _DisabledMenuAction(
            icon: Icons.account_tree, label: '管理分组', tooltip: '分组视图下不可使用',
          )
        else
          _buildMenuAction(Icons.account_tree, '管理分组', onTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('管理分组功能即将推出')),
            );
          }),
        const Divider(color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('导入', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: InkWell(
            onTap: () { Navigator.of(context).pop(); widget.onImportTap(); },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.outlineVariant, width: 2, strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: const Column(children: [
                Icon(Icons.upload_file, color: AppColors.outline, size: 24),
                SizedBox(height: 8),
                Text('支持 txt, epub, pdf, docx',
                  style: TextStyle(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSortOption(String label, SortMode mode, IconData icon) {
    final selected = widget.currentSort == mode;
    return InkWell(
      onTap: () { widget.onSortChanged(mode); Navigator.of(context).pop(); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: selected ? AppColors.secondary : AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant)),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle, size: 18, color: AppColors.secondary),
        ]),
      ),
    );
  }

  Widget _buildMenuAction(IconData icon, String label, {VoidCallback? onTap}) {
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
}

class _DisabledMenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  const _DisabledMenuAction({required this.icon, required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.outline)),
        ]),
      ),
    );
  }
}
