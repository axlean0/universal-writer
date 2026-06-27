import 'package:flutter/material.dart' hide MaterialType;
import '../theme/app_theme.dart';
import '../models/material_item.dart';
import '../widgets/sidebar.dart';
import '../widgets/material_top_bar.dart';
import '../widgets/material_card.dart';
import '../widgets/upload_material_dialog.dart';
import '../widgets/batch_bar.dart';

enum MaterialViewMode { list, grid, grouped, type }

class MaterialsPage extends StatefulWidget {
  final VoidCallback? onNavigateToWriting;
  final VoidCallback? onNavigateToFiles;
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToSettings;

  const MaterialsPage({
    super.key,
    this.onNavigateToWriting, this.onNavigateToFiles,
    this.onNavigateToStats, this.onNavigateToSettings,
  });

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  List<MaterialItem> _items = [];
  List<MaterialItem> _trash = [];
  MaterialViewMode _viewMode = MaterialViewMode.grid;
  String _sortMode = 'date';
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
    _items = [
      MaterialItem(id: 'm1', name: '世界观设定集', type: MaterialType.document,
        description: '关于异世界的完整世界观设定', size: 25600, group: '世界观素材',
        uploadedAt: now.subtract(const Duration(days: 60)), lastOpenedAt: now.subtract(const Duration(hours: 5))),
      MaterialItem(id: 'm2', name: '角色插画.png', type: MaterialType.image,
        description: '主人公设定图', size: 2048000, group: '角色素材',
        uploadedAt: now.subtract(const Duration(days: 45)), lastOpenedAt: now.subtract(const Duration(days: 2))),
      MaterialItem(id: 'm3', name: '古代地图参考.pdf', type: MaterialType.pdf,
        description: '唐代长安城地图', size: 5120000, group: '考据资料',
        uploadedAt: now.subtract(const Duration(days: 30)), lastOpenedAt: now.subtract(const Duration(days: 1))),
      MaterialItem(id: 'm4', name: '主题曲demo.mp3', type: MaterialType.audio,
        description: '作品主题曲小样', size: 4096000, group: '音频素材',
        uploadedAt: now.subtract(const Duration(days: 20)), lastOpenedAt: now.subtract(const Duration(days: 7))),
      MaterialItem(id: 'm5', name: '场景概念视频.mp4', type: MaterialType.video,
        description: '关键场景概念动画', size: 25600000, group: '视觉素材',
        uploadedAt: now.subtract(const Duration(days: 14)), lastOpenedAt: now.subtract(const Duration(days: 3))),
      MaterialItem(id: 'm6', name: '参考资料合集.zip', type: MaterialType.other,
        description: '各类型写作参考', size: 10240000, group: '考据资料',
        uploadedAt: now.subtract(const Duration(days: 7)), lastOpenedAt: now.subtract(const Duration(days: 1))),
    ];

    _trash = [
      MaterialItem(id: 't1', name: '废弃参考图.png', type: MaterialType.image,
        size: 512000, group: '角色素材',
        uploadedAt: now.subtract(const Duration(days: 10)), lastOpenedAt: now.subtract(const Duration(days: 5)),
        deletedAt: now.subtract(const Duration(days: 3))),
    ];
  }

  List<MaterialItem> get _filtered {
    var list = List<MaterialItem>.from(_items);
    if (_searchQuery.isNotEmpty) { list = list.where((i) => i.name.contains(_searchQuery) || i.description.contains(_searchQuery)).toList(); }
    switch (_sortMode) {
      case 'name': list.sort((a, b) => a.name.compareTo(b.name));
      case 'date': list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      case 'size': list.sort((a, b) => b.size.compareTo(a.size));
      case 'type': list.sort((a, b) => a.type.label.compareTo(b.type.label));
    }
    return list;
  }

  List<String> get _groupNames => _items.map((i) => i.group).toSet().toList();
  int _countByType(MaterialType t) => _items.where((i) => i.type == t).length;
  int get _docCount => _countByType(MaterialType.document);
  int get _pdfCount => _countByType(MaterialType.pdf);
  int get _imgCount => _countByType(MaterialType.image);
  int get _otherCount => _countByType(MaterialType.video) + _countByType(MaterialType.audio) + _countByType(MaterialType.other);

  MaterialItem? get _lastUsed {
    if (_items.isEmpty) return null;
    var latest = _items.first;
    for (final i in _items) { if (i.lastOpenedAt.isAfter(latest.lastOpenedAt)) latest = i; }
    return latest;
  }

  void _upload(MaterialItem item) => setState(() => _items.insert(0, item));
  void _delete(MaterialItem item) {
    setState(() { _items.removeWhere((i) => i.id == item.id); _trash.add(item.copyWith(deletedAt: DateTime.now())); });
  }
  void _restore(MaterialItem item) {
    setState(() { _trash.removeWhere((i) => i.id == item.id); _items.add(item.copyWith(deletedAt: null)); });
  }
  void _deleteForever(MaterialItem item) => setState(() => _trash.removeWhere((i) => i.id == item.id));
  void _clearTrash() => setState(() => _trash.clear());
  void _toggleBatch() => setState(() { _batchMode = !_batchMode; if (!_batchMode) _selectedIds.clear(); });
  void _toggleSel(String id) => setState(() { if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); } });
  void _batchDelete() {
    setState(() {
      for (final item in _items.where((i) => _selectedIds.contains(i.id)).toList()) {
        _items.removeWhere((i) => i.id == item.id);
        _trash.add(item.copyWith(deletedAt: DateTime.now()));
      }
      _selectedIds.clear(); _batchMode = false;
    });
  }
  void _openItem(MaterialItem item) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开: ${item.name}')));
  void _showUpload() => showDialog(context: context, builder: (_) => UploadMaterialDialog(groups: _groupNames, onUpload: _upload));

  void _showContextMenu(MaterialItem item) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        contentPadding: EdgeInsets.zero,
        children: [
          _ctxOpt(Icons.open_in_new, '打开', () { Navigator.pop(ctx); _openItem(item); }),
          _ctxOpt(Icons.edit, '重命名', () => Navigator.pop(ctx)),
          _ctxOpt(Icons.delete_outline, '删除', () { Navigator.pop(ctx); _delete(item); }),
          _ctxOpt(Icons.download, '导出', () => Navigator.pop(ctx)),
          _ctxOpt(Icons.content_copy, '复制路径', () => Navigator.pop(ctx)),
          _ctxOpt(Icons.info_outline, '属性', () => Navigator.pop(ctx)),
        ]),
    );
  }

  Widget _ctxOpt(IconData icon, String label, VoidCallback onTap) => SimpleDialogOption(
    onPressed: onTap,
    child: Row(children: [Icon(icon, size: 20, color: AppColors.onSurfaceVariant), const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.onSurface))]));

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final last = _lastUsed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        if (isDesktop) AppSidebar(
          currentRoute: 'materials',
          onNavigateToWriting: widget.onNavigateToWriting,
          onNavigateToFiles: widget.onNavigateToFiles,
          onNavigateToStats: widget.onNavigateToStats,
          onNavigateToSettings: widget.onNavigateToSettings,
        ),
        Expanded(child: Column(children: [
          MaterialTopBar(
            allItems: _items, trashedItems: _trash,
            onSearch: (q) => setState(() => _searchQuery = q),
            onRestore: _restore, onDeleteForever: _deleteForever, onClearTrash: _clearTrash,
            onToggleBatchMode: _toggleBatch, currentSort: _sortMode,
            onSortChanged: (s) => setState(() => _sortMode = s),
            onImportTap: _showUpload, onOpenItem: _openItem,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.containerMaxWidth),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(last),
                  const SizedBox(height: AppSpacing.sectionMargin),
                  _buildContent(),
                ]),
              )),
            ),
          ),
          if (_batchMode) BatchActionBar(
            selectedCount: _selectedIds.length, onCancel: _toggleBatch,
            onGroupAction: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('批量移动即将推出'))),
            onExport: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('批量导出即将推出'))),
            onDelete: _batchDelete,
          ),
          if (!isDesktop) _buildMobileNav(),
        ])),
      ]),
    );
  }

  Widget _buildHeader(MaterialItem? last) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Expanded(child: Text('管理你的素材',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700,
              height: 48 / 40, letterSpacing: -0.8, color: AppColors.onBackground))),
        if (last != null) ...[
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('最近使用', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.72, color: AppColors.outline)),
            const SizedBox(height: 2),
            Text(last.name, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(width: 16),
        ],
        SizedBox(height: 40, child: FilledButton.icon(
          onPressed: _showUpload, icon: const Icon(Icons.add, size: 20), label: const Text('上传素材'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 32)),
        )),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() { _viewMode = MaterialViewMode.values[(_viewMode.index + 1) % 4]; }),
          icon: Icon(_viewMode == MaterialViewMode.list ? Icons.view_list
              : _viewMode == MaterialViewMode.grid ? Icons.grid_view
              : _viewMode == MaterialViewMode.grouped ? Icons.folder
              : Icons.category, size: 22),
          splashRadius: 20, color: AppColors.onSurfaceVariant,
          tooltip: ['列表', '网格', '分组', '分类'][_viewMode.index],
        ),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 24, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _stat('素材', '${_items.length}'),
        _divider(),
        _stat('文档', '$_docCount'),
        _divider(),
        _stat('PDF', '$_pdfCount'),
        _divider(),
        _stat('图片', '$_imgCount'),
        _divider(),
        _stat('其他', '$_otherCount'),
      ]),
    ]);
  }

  Widget _stat(String label, String val) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.72, color: AppColors.outline)),
    const SizedBox(width: 8),
    Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
  ]);
  Widget _divider() => const SizedBox(height: 12, child: VerticalDivider(width: 1, color: AppColors.outlineVariant));

  Widget _buildContent() {
    final items = _filtered;
    switch (_viewMode) {
      case MaterialViewMode.list:    return _buildList(items);
      case MaterialViewMode.grid:    return _buildGrid(items);
      case MaterialViewMode.grouped: return _buildGrouped(items);
      case MaterialViewMode.type:    return _buildType(items);
    }
  }

  Widget _buildGrid(List<MaterialItem> items) {
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: AppSpacing.gridGutter,
        crossAxisSpacing: AppSpacing.gridGutter, childAspectRatio: 0.65),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == items.length) return UploadNewMaterialGridCard(onTap: _showUpload);
        final item = items[i];
        return MaterialGridCard(item: item,
          batchMode: _batchMode, selected: _selectedIds.contains(item.id),
          onSelectToggle: () => _toggleSel(item.id),
          onTap: () => _openItem(item), onDoubleTap: () => _openItem(item),
          onLongPress: () => _showContextMenu(item));
      });
  }

  Widget _buildList(List<MaterialItem> items) {
    return Column(children: [
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12),
        child: MaterialListRow(item: item,
          batchMode: _batchMode, selected: _selectedIds.contains(item.id),
          onSelectToggle: () => _toggleSel(item.id),
          onTap: () => _openItem(item), onDoubleTap: () => _openItem(item),
          onLongPress: () => _showContextMenu(item)))),
      UploadNewMaterialListRow(onTap: _showUpload),
    ]);
  }

  Widget _buildGrouped(List<MaterialItem> items) {
    final groups = <String, List<MaterialItem>>{};
    for (final i in items) { groups.putIfAbsent(i.group, () => []).add(i); }
    return Column(children: groups.entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MaterialGroupCard(groupName: e.key, count: e.value.length,
        onTap: () {}, onLongPress: () {}),
    )).toList());
  }

  Widget _buildType(List<MaterialItem> items) {
    return Column(children: MaterialTypeX.systemCategories.where((t) => items.any((i) => i.type == t)).map((t) {
      final catItems = items.where((i) => i.type == t).toList();
      return MaterialTypeSection(
        materialType: t, items: catItems,
        onItemTap: _openItem, onItemLongPress: _showContextMenu);
    }).toList());
  }

  Widget _buildMobileNav() {
    return Container(height: 64,
      decoration: BoxDecoration(color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, -2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _mobItem(Icons.edit, '写作', false, widget.onNavigateToWriting),
        _mobItem(Icons.add_circle, '新建', false, _showUpload),
        _mobItem(Icons.folder, '文件', false, widget.onNavigateToFiles),
        _mobItem(Icons.inventory_2, '素材', true, null),
        _mobItem(Icons.settings, '设置', false, widget.onNavigateToSettings),
      ]));
  }

  Widget _mobItem(IconData icon, String label, bool active, VoidCallback? onTap) => InkWell(onTap: onTap,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
    ]));
}
