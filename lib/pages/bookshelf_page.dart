import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/book_card.dart';
import '../widgets/create_dialog.dart';
import '../widgets/batch_bar.dart';
import 'editor/editor_shell.dart';

/// Main bookshelf page — the home screen of Universal Writer.
class BookshelfPage extends StatefulWidget {
  final VoidCallback? onNavigateToFiles;
  final VoidCallback? onNavigateToMaterials;
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToSettings;

  const BookshelfPage({
    super.key,
    this.onNavigateToFiles,
    this.onNavigateToMaterials,
    this.onNavigateToStats,
    this.onNavigateToSettings,
  });

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  List<Book> _books = [];
  List<Book> _trashedBooks = [];
  SortMode _sortMode = SortMode.nameAsc;
  ViewMode _viewMode = ViewMode.multi;
  bool _batchMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  int get _totalWords => _books.fold(0, (sum, b) => sum + b.wordCount);
  int get _todayWords => 1240;
  int get _streakDays => 8;

  List<Book> get _filteredBooks {
    var list = List<Book>.from(_books);
    if (_searchQuery.isNotEmpty) {
      list = list.where((b) => b.title.contains(_searchQuery) || b.description.contains(_searchQuery)).toList();
    }
    switch (_sortMode) {
      case SortMode.nameAsc:    list.sort((a, b) => a.title.compareTo(b.title));
      case SortMode.nameDesc:   list.sort((a, b) => b.title.compareTo(a.title));
      case SortMode.lastEdited: list.sort((a, b) => b.lastEditedAt.compareTo(a.lastEditedAt));
      case SortMode.wordCount:  list.sort((a, b) => b.wordCount.compareTo(a.wordCount));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _addSampleData();
  }

  void _addSampleData() {
    final now = DateTime.now();
    _books = [
      Book(id: '1', title: '创作一号', description: '一部关于冒险与成长的长篇小说', wordCount: 12450,
          group: '长篇小说', createdAt: now.subtract(const Duration(days: 30)),
          lastEditedAt: now.subtract(const Duration(hours: 2))),
      Book(id: '2', title: '诗集草稿', description: '记录日常灵感的诗歌集', wordCount: 4200,
          type: BookType.article, group: '灵感随笔',
          createdAt: now.subtract(const Duration(days: 14)), lastEditedAt: now.subtract(const Duration(days: 1))),
      Book(id: '3', title: '书籍(3)', description: '三部曲的第三部，史诗奇幻', wordCount: 8900,
          group: '长篇小说', createdAt: now.subtract(const Duration(days: 45)),
          lastEditedAt: now.subtract(const Duration(days: 3))),
      Book(id: '4', title: '随笔集', description: '关于生活与思考的随笔', wordCount: 3200,
          type: BookType.article, group: '短篇集',
          createdAt: now.subtract(const Duration(days: 7)), lastEditedAt: now.subtract(const Duration(days: 5))),
      Book(id: '5', title: '森林的呼唤', description: '第一章：在那片被迷雾笼罩的森林深处...', wordCount: 15670,
          group: '长篇小说', createdAt: now.subtract(const Duration(days: 60)),
          lastEditedAt: now.subtract(const Duration(hours: 5))),
    ];
    _trashedBooks = [
      Book(id: 't1', title: '被废弃的大纲 V2', wordCount: 800, group: '灵感随笔',
          createdAt: now.subtract(const Duration(days: 10)),
          lastEditedAt: now.subtract(const Duration(days: 5)), deletedAt: now.subtract(const Duration(days: 3))),
    ];
  }

  void _createWork(Book book) => setState(() => _books.insert(0, book));
  void _deleteBook(Book book) {
    setState(() { _books.removeWhere((b) => b.id == book.id); _trashedBooks.add(book.copyWith(deletedAt: DateTime.now())); });
  }
  void _restoreBook(Book book) => setState(() { _trashedBooks.removeWhere((b) => b.id == book.id); _books.add(book.copyWith(deletedAt: null)); });
  void _deleteForever(Book book) => setState(() => _trashedBooks.removeWhere((b) => b.id == book.id));
  void _clearTrash() => setState(() => _trashedBooks.clear());
  void _toggleBatchMode() => setState(() { _batchMode = !_batchMode; if (!_batchMode) _selectedIds.clear(); });
  void _toggleSelection(String id) => setState(() { if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); } });
  void _batchDelete() {
    setState(() {
      for (final book in _books.where((b) => _selectedIds.contains(b.id)).toList()) {
        _books.removeWhere((b) => b.id == book.id);
        _trashedBooks.add(book.copyWith(deletedAt: DateTime.now()));
      }
      _selectedIds.clear(); _batchMode = false;
    });
  }
  void _showCreateDialog() => showDialog(context: context, builder: (_) => CreateWorkDialog(onCreate: _createWork));
  void _showBookDetail(Book book) {
    showDialog(context: context, builder: (_) => _BookDetailDialog(book: book, onDelete: () => _deleteBook(book)));
  }
  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditorShell(bookId: book.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isDesktop) AppSidebar(
            currentRoute: 'writing',
            onNavigateToFiles: widget.onNavigateToFiles,
            onNavigateToMaterials: widget.onNavigateToMaterials,
            onNavigateToStats: widget.onNavigateToStats,
            onNavigateToSettings: widget.onNavigateToSettings,
          ),
          Expanded(
            child: Column(
              children: [
                AppTopBar(
                  books: _books,
                  trashedBooks: _trashedBooks,
                  onSearch: (q) => setState(() => _searchQuery = q),
                  onRestore: _restoreBook,
                  onDeleteForever: _deleteForever,
                  onClearTrash: _clearTrash,
                  onToggleBatchMode: _toggleBatchMode,
                  currentSort: _sortMode,
                  onSortChanged: (m) => setState(() => _sortMode = m),
                  onImportTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('导入功能即将推出')),
                  ),
                  viewMode: _viewMode,
                  onOpenBook: _openBook,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppSpacing.containerMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: AppSpacing.sectionMargin),
                            _buildBookshelf(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_batchMode) BatchActionBar(
                  selectedCount: _selectedIds.length,
                  onCancel: _toggleBatchMode,
                  onGroupAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('批量分组功能即将推出')),
                  ),
                  onExport: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('批量导出功能即将推出')),
                  ),
                  onDelete: _batchDelete,
                ),
                if (!isDesktop) _buildMobileBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header: welcome + actions on top line, stats below ──
  Widget _buildHeader() {
    final lastBook = _books.isNotEmpty ? _books.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Welcome text | 上次编辑 | 新创作 | 视图
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text('欢迎回来，创作者',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700,
                    height: 48 / 40, letterSpacing: -0.8, color: AppColors.onBackground),
              ),
            ),
            // 上次编辑
            if (lastBook != null) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('上次编辑',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.72, color: AppColors.outline),
                  ),
                  const SizedBox(height: 2),
                  Text(lastBook.title,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
            // 新创作 button
            SizedBox(
              height: 40,
              child: FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('新创作'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 视图 toggle
            IconButton(
              onPressed: () => setState(() {
                _viewMode = ViewMode.values[(_viewMode.index + 1) % ViewMode.values.length];
              }),
              icon: Icon(
                _viewMode == ViewMode.single ? Icons.view_list
                    : _viewMode == ViewMode.multi ? Icons.grid_view : Icons.folder,
                size: 22,
              ),
              splashRadius: 20,
              color: AppColors.onSurfaceVariant,
              tooltip: _viewMode == ViewMode.single ? '单列' : _viewMode == ViewMode.multi ? '多列' : '分组',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Stats
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildStat('作品', '${_filteredBooks.length}'),
            _buildDivider(),
            _buildStat('总字数', _formatCount(_totalWords)),
            _buildDivider(),
            _buildStat('今日', _formatCount(_todayWords)),
            _buildDivider(),
            _buildStat('连续', '$_streakDays 天'),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.72, color: AppColors.outline)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildDivider() => const SizedBox(height: 12, child: VerticalDivider(width: 1, color: AppColors.outlineVariant));

  // ── Bookshelf ──

  Widget _buildBookshelf() {
    final books = _filteredBooks;

    if (_viewMode == ViewMode.single) {
      return Column(
        children: [
          ...books.map((book) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BookCardHorizontal(
              book: book, batchMode: _batchMode,
              selected: _selectedIds.contains(book.id),
              onSelectToggle: () => _toggleSelection(book.id),
              onTap: () => _openBook(book),
              onLongPress: () => _showBookDetail(book),
            ),
          )),
          CreateNewBookRow(onTap: _showCreateDialog),
        ],
      );
    }

    if (_viewMode == ViewMode.grouped) return _buildGroupedView(books);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: AppSpacing.gridGutter,
        crossAxisSpacing: AppSpacing.gridGutter, childAspectRatio: 0.52,
      ),
      itemCount: books.length + 1,
      itemBuilder: (context, index) {
        if (index == books.length) return CreateNewBookCard(onTap: _showCreateDialog);
        final book = books[index];
        return BookCard(
          book: book, batchMode: _batchMode,
          selected: _selectedIds.contains(book.id),
          onSelectToggle: () => _toggleSelection(book.id),
          onTap: () => _openBook(book),
          onLongPress: () => _showBookDetail(book),
        );
      },
    );
  }

  Widget _buildGroupedView(List<Book> books) {
    final grouped = <String, List<Book>>{};
    for (final book in books) { grouped.putIfAbsent(book.group, () => []).add(book); }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.key,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onBackground),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: AppSpacing.gridGutter,
              crossAxisSpacing: AppSpacing.gridGutter, childAspectRatio: 0.52,
            ),
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final book = entry.value[index];
              return BookCard(
                book: book, batchMode: _batchMode,
                selected: _selectedIds.contains(book.id),
                onSelectToggle: () => _toggleSelection(book.id),
                onTap: () => _openBook(book),
                onLongPress: () => _showBookDetail(book),
              );
            },
          ),
        ]),
      )).toList(),
    );
  }

  // ── Mobile bottom nav ──

  Widget _buildMobileBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, -2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildMobileNavItem(Icons.edit, '写作', true),
        _buildMobileNavItem(Icons.add_circle, '创作', false),
        _buildMobileNavItem(Icons.description, '文件', false),
        _buildMobileNavItem(Icons.inventory_2, '素材', false),
        _buildMobileNavItem(Icons.settings, '设置', false),
      ]),
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, bool active) {
    return InkWell(
      onTap: () {},
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
      ]),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}万';
    return count.toString();
  }
}

// ── Book Detail Dialog ──
class _BookDetailDialog extends StatelessWidget {
  final Book book;
  final VoidCallback onDelete;
  const _BookDetailDialog({required this.book, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(left: 48),
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('作品详情', style: TextStyle(fontFamily: 'Manrope', fontSize: 18,
                    fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20),
                    splashRadius: 16, color: AppColors.outline),
              ]),
              const SizedBox(height: 24),
              _detailRow('作品名称', book.title),
              _detailRow('作品类型', book.type == BookType.book ? '书籍' : '文章'),
              _detailRow('占用空间', '${(book.wordCount * 0.5).toStringAsFixed(1)} KB'),
              _detailRow('创建时间', '${book.createdAt.year}-${book.createdAt.month.toString().padLeft(2, '0')}-${book.createdAt.day.toString().padLeft(2, '0')}'),
              _detailRow('存储位置', '本地 / ${book.group}'),
              _detailRow('字数', '${book.wordCount}'),
            ]),
          ),
          const Divider(color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('重命名')),
              const SizedBox(width: 8),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('导出')),
              const SizedBox(width: 8),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('修改')),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () { onDelete(); Navigator.of(context).pop(); },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('删除'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.outline))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface))),
      ]),
    );
  }
}
