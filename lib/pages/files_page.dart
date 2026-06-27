import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/file_item.dart';
import '../widgets/sidebar.dart';
import '../widgets/file_top_bar.dart';
import '../widgets/file_card.dart';
import '../widgets/create_file_dialog.dart';
import '../widgets/batch_bar.dart';

enum FileViewMode { list, grid, tree }

class FilesPage extends StatefulWidget {
  final VoidCallback? onNavigateToWriting;
  final VoidCallback? onNavigateToMaterials;
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToSettings;
  const FilesPage({
    super.key,
    this.onNavigateToWriting,
    this.onNavigateToMaterials,
    this.onNavigateToStats,
    this.onNavigateToSettings,
  });

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  List<FileItem> _allFiles = [];
  List<FileItem> _trashedFiles = [];
  FileViewMode _viewMode = FileViewMode.grid;
  String _sortMode = 'name';
  bool _batchMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _addSampleData();
  }

  void _addSampleData() {
    final now = DateTime.now();
    _allFiles = [
      FileItem(id: 'f1', name: '创作一号', type: FileType.book,
        description: '长篇小说', createdAt: now.subtract(const Duration(days: 30)),
        lastModifiedAt: now.subtract(const Duration(hours: 2)),
        children: [
          FileItem(id: 'f1v1', name: '第一卷', type: FileType.folder,
            parentId: 'f1', createdAt: now.subtract(const Duration(days: 30)),
            lastModifiedAt: now.subtract(const Duration(days: 5)),
            children: [
              FileItem(id: 'f1v1c1', name: '第一章.txt', type: FileType.text,
                parentId: 'f1v1', size: 12500, createdAt: now.subtract(const Duration(days: 30)),
                lastModifiedAt: now.subtract(const Duration(hours: 2))),
              FileItem(id: 'f1v1c2', name: '第二章.txt', type: FileType.text,
                parentId: 'f1v1', size: 8900, createdAt: now.subtract(const Duration(days: 25)),
                lastModifiedAt: now.subtract(const Duration(days: 1))),
            ]),
          FileItem(id: 'f1v2', name: '第二卷', type: FileType.folder,
            parentId: 'f1', createdAt: now.subtract(const Duration(days: 20)),
            lastModifiedAt: now.subtract(const Duration(days: 3)),
            children: [
              FileItem(id: 'f1v2c1', name: '第一章.txt', type: FileType.text,
                parentId: 'f1v2', size: 15600, createdAt: now.subtract(const Duration(days: 20)),
                lastModifiedAt: now.subtract(const Duration(hours: 5))),
            ]),
        ]),
      FileItem(id: 'f2', name: '诗集草稿', type: FileType.book,
        description: '灵感随笔', createdAt: now.subtract(const Duration(days: 14)),
        lastModifiedAt: now.subtract(const Duration(days: 1)),
        children: [
          FileItem(id: 'f2c1', name: '正文.txt', type: FileType.text,
            parentId: 'f2', size: 4200, createdAt: now.subtract(const Duration(days: 14)),
            lastModifiedAt: now.subtract(const Duration(days: 1))),
        ]),
      FileItem(id: 'f3', name: '研究笔记', type: FileType.folder,
        description: '资料整理', createdAt: now.subtract(const Duration(days: 60)),
        lastModifiedAt: now.subtract(const Duration(days: 10)),
        children: [
          FileItem(id: 'f3c1', name: '参考文献.txt', type: FileType.text,
            parentId: 'f3', size: 3200, createdAt: now.subtract(const Duration(days: 60)),
            lastModifiedAt: now.subtract(const Duration(days: 10))),
          FileItem(id: 'f3c2', name: '调查数据.txt', type: FileType.text,
            parentId: 'f3', size: 7800, createdAt: now.subtract(const Duration(days: 45)),
            lastModifiedAt: now.subtract(const Duration(days: 5))),
        ]),
      FileItem(id: 'f4', name: '写作技巧总结', type: FileType.text,
        description: '个人心得', size: 5600, createdAt: now.subtract(const Duration(days: 7)),
        lastModifiedAt: now.subtract(const Duration(days: 5))),
    ];

    _trashedFiles = [
      FileItem(id: 't1', name: '被废弃的大纲.txt', type: FileType.text,
        size: 800, createdAt: now.subtract(const Duration(days: 10)),
        lastModifiedAt: now.subtract(const Duration(days: 5)),
        deletedAt: now.subtract(const Duration(days: 3))),
    ];
  }

  List<FileItem> get _filteredFiles {
    var list = List<FileItem>.from(_allFiles);
    if (_searchQuery.isNotEmpty) {
      list = list.where((f) => f.name.contains(_searchQuery) || f.description.contains(_searchQuery)).toList();
    }
    switch (_sortMode) {
      case 'name': list.sort((a, b) => a.name.compareTo(b.name));
      case 'date': list.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));
      case 'size': list.sort((a, b) => b.size.compareTo(a.size));
    }
    return list;
  }

  List<String> get _folderNames => _allFiles.where((f) => f.isFolder).map((f) => f.name).toList();

  int get _folderCount => _allFiles.where((f) => f.isFolder).length;
  int get _textCount => _allFiles.where((f) => f.type == FileType.text).length + _countTexts(_allFiles);
  int _countTexts(List<FileItem> items) {
    int c = 0;
    for (final item in items) {
      if (item.type == FileType.text) c++;
      c += _countTexts(item.children);
    }
    return c;
  }
  int get _totalSize => _allFiles.fold<int>(0, (s, f) => s + _calcSize(f));
  int _calcSize(FileItem item) {
    int s = item.size;
    for (final child in item.children) { s += _calcSize(child); }
    return s;
  }

  void _createFile(FileItem item) => setState(() => _allFiles.insert(0, item));
  void _deleteFile(FileItem item) {
    setState(() {
      _allFiles.removeWhere((f) => f.id == item.id);
      _trashedFiles.add(item.copyWith(deletedAt: DateTime.now()));
    });
  }
  void _restoreFile(FileItem item) {
    setState(() {
      _trashedFiles.removeWhere((f) => f.id == item.id);
      _allFiles.add(item.copyWith(deletedAt: null));
    });
  }
  void _deleteForever(FileItem item) => setState(() => _trashedFiles.removeWhere((f) => f.id == item.id));
  void _clearTrash() => setState(() => _trashedFiles.clear());
  void _toggleBatchMode() => setState(() { _batchMode = !_batchMode; if (!_batchMode) _selectedIds.clear(); });
  void _toggleSelection(String id) {
    setState(() { if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); } });
  }
  void _showCreateDialog() {
    showDialog(context: context, builder: (_) => CreateFileDialog(folders: _folderNames, onCreate: _createFile));
  }
  void _showContextMenu(FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        contentPadding: EdgeInsets.zero,
        children: (item.isFolder
            ? [
                _dialogOpt(Icons.folder_open, '打开', () { Navigator.pop(ctx); _openFile(item); }),
                _dialogOpt(Icons.edit, '重命名', () { Navigator.pop(ctx); }),
                _dialogOpt(Icons.delete_outline, '删除', () { Navigator.pop(ctx); _deleteFile(item); }),
                _dialogOpt(Icons.download, '导出', () { Navigator.pop(ctx); }),
                _dialogOpt(Icons.info_outline, '属性', () { Navigator.pop(ctx); }),
              ]
            : [
                _dialogOpt(Icons.description, '打开', () { Navigator.pop(ctx); _openFile(item); }),
                _dialogOpt(Icons.edit, '重命名', () { Navigator.pop(ctx); }),
                _dialogOpt(Icons.delete_outline, '删除', () { Navigator.pop(ctx); _deleteFile(item); }),
                _dialogOpt(Icons.download, '导出', () { Navigator.pop(ctx); }),
                _dialogOpt(Icons.info_outline, '属性', () { Navigator.pop(ctx); }),
              ]),
      ),
    );
  }

  Widget _dialogOpt(IconData icon, String label, VoidCallback onTap) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(children: [Icon(icon, size: 20, color: AppColors.onSurfaceVariant), const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.onSurface))]),
    );
  }

  void _openFile(FileItem item) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开: ${item.name}')));
  }

  FileItem? get _lastModified {
    if (_allFiles.isEmpty) return null;
    var latest = _allFiles.first;
    for (final f in _allFiles) {
      if (f.lastModifiedAt.isAfter(latest.lastModifiedAt)) latest = f;
    }
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final last = _lastModified;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        if (isDesktop) AppSidebar(
          currentRoute: 'files',
          onNavigateToWriting: widget.onNavigateToWriting,
          onNavigateToFiles: null,
          onNavigateToMaterials: widget.onNavigateToMaterials,
          onNavigateToStats: widget.onNavigateToStats,
          onNavigateToSettings: widget.onNavigateToSettings,
        ),
        Expanded(
          child: Column(children: [
            FileTopBar(
              allFiles: _allFiles, trashedFiles: _trashedFiles,
              onSearch: (q) => setState(() => _searchQuery = q),
              onRestore: _restoreFile, onDeleteForever: _deleteForever, onClearTrash: _clearTrash,
              onToggleBatchMode: _toggleBatchMode, currentSort: _sortMode,
              onSortChanged: (s) => setState(() => _sortMode = s),
              onImportTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导入功能即将推出'))),
              onOpenFile: _openFile,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppSpacing.containerMaxWidth),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildHeader(last),
                      const SizedBox(height: AppSpacing.sectionMargin),
                      _buildContent(),
                    ]),
                  ),
                ),
              ),
            ),
            if (_batchMode) BatchActionBar(
              selectedCount: _selectedIds.length, onCancel: _toggleBatchMode,
              onGroupAction: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('批量移动功能即将推出'))),
              onExport: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('批量导出功能即将推出'))),
              onDelete: () { /* TODO */ },
            ),
            if (!isDesktop) _buildMobileNav(),
          ]),
        ),
      ]),
    );
  }

  Widget _buildHeader(FileItem? last) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Expanded(
          child: Text('管理你的文件',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700,
                height: 48 / 40, letterSpacing: -0.8, color: AppColors.onBackground)),
        ),
        if (last != null) ...[
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('上次修改',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.72, color: AppColors.outline)),
            const SizedBox(height: 2),
            Text(last.name,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(width: 16),
        ],
        SizedBox(height: 40,
          child: FilledButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('新建文件'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 32),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() {
            _viewMode = FileViewMode.values[(_viewMode.index + 1) % FileViewMode.values.length];
          }),
          icon: Icon(_viewMode == FileViewMode.list ? Icons.view_list
              : _viewMode == FileViewMode.grid ? Icons.grid_view : Icons.account_tree,
            size: 22),
          splashRadius: 20, color: AppColors.onSurfaceVariant,
          tooltip: _viewMode == FileViewMode.list ? '列表' : _viewMode == FileViewMode.grid ? '网格' : '树状',
        ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 24, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _buildStat('存储空间', formatFileSize(_totalSize)),
        _buildDivider(),
        _buildStat('文件夹', '$_folderCount'),
        _buildDivider(),
        _buildStat('文本', '$_textCount'),
      ]),
    ]);
  }

  Widget _buildStat(String label, String value) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          letterSpacing: 0.72, color: AppColors.outline)),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
    ]);
  }

  Widget _buildDivider() => const SizedBox(height: 12, child: VerticalDivider(width: 1, color: AppColors.outlineVariant));

  Widget _buildContent() {
    final files = _filteredFiles;
    if (_viewMode == FileViewMode.list) return _buildListView(files);
    if (_viewMode == FileViewMode.tree) return _buildTreeView(files);
    return _buildGridView(files);
  }

  Widget _buildGridView(List<FileItem> files) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: AppSpacing.gridGutter,
        crossAxisSpacing: AppSpacing.gridGutter, childAspectRatio: 0.65,
      ),
      itemCount: files.length + 1,
      itemBuilder: (ctx, i) {
        if (i == files.length) return CreateNewFileGridCard(onTap: _showCreateDialog);
        final f = files[i];
        return FileGridCard(
          item: f, batchMode: _batchMode,
          selected: _selectedIds.contains(f.id),
          onSelectToggle: () => _toggleSelection(f.id),
          onTap: () => _openFile(f),
          onDoubleTap: () => _openFile(f),
          onLongPress: () => _showContextMenu(f),
        );
      },
    );
  }

  Widget _buildListView(List<FileItem> files) {
    return Column(children: [
      ...files.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FileListRow(
          item: f, batchMode: _batchMode,
          selected: _selectedIds.contains(f.id),
          onSelectToggle: () => _toggleSelection(f.id),
          onTap: () => _openFile(f),
          onDoubleTap: () => _openFile(f),
          onLongPress: () => _showContextMenu(f),
        ),
      )),
      CreateNewFileListRow(onTap: _showCreateDialog),
    ]);
  }

  Widget _buildTreeView(List<FileItem> files) {
    return Column(
      children: files.map((f) => FileTreeNode(
        item: f, depth: 0, batchMode: _batchMode,
        selected: _selectedIds.contains(f.id),
        onSelectToggle: () => _toggleSelection(f.id),
        onTap: () => _openFile(f),
        onLongPress: () => _showContextMenu(f),
      )).toList(),
    );
  }

  Widget _buildMobileNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, -2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _mobileItem(Icons.edit, '写作', false, widget.onNavigateToWriting),
        _mobileItem(Icons.add_circle, '新建', false, _showCreateDialog),
        _mobileItem(Icons.folder, '文件', true, null),
        _mobileItem(Icons.inventory_2, '素材', false, widget.onNavigateToMaterials),
        _mobileItem(Icons.settings, '设置', false, widget.onNavigateToSettings),
      ]),
    );
  }

  Widget _mobileItem(IconData icon, String label, bool active, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
      ]),
    );
  }
}
