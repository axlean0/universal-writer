import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onNavigateToWriting;
  final VoidCallback? onNavigateToFiles;
  final VoidCallback? onNavigateToMaterials;
  final VoidCallback? onNavigateToStats;

  const SettingsPage({
    super.key,
    this.onNavigateToWriting, this.onNavigateToFiles,
    this.onNavigateToMaterials, this.onNavigateToStats,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _tabIndex = 5; // default: 关于
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  // ── Editor ──
  String _fontFamily = 'Source Serif 4';
  double _fontSize = 18;
  double _lineHeight = 1.6;
  double _pageWidth = 800;

  // ── Storage ──
  bool _autoSave = true;
  String _saveInterval = '30秒';
  bool _idleSave = true;
  bool _showSaveStatus = true;
  bool _autoBackup = true;
  String _backupFreq = '1小时';
  String _backupCount = '10份';
  bool _exitBackup = true;

  // ── Appearance ──
  int _themeIndex = 0; // 0=浅色 1=深色 2=护眼 3=跟随系统
  double _zoom = 100;

  // ── General ──
  String _language = '简体中文';
  String _startPage = '写作/统筹';
  bool _securityLock = false;
  int _trashDays = 30;
  int _historyCount = 50;
  late final TextEditingController _trashCtrl;
  late final TextEditingController _historyCtrl;

  // ── Tab definitions ──
  static final _tabs = [
    ('编辑器', Icons.edit_note),
    ('存储', Icons.storage),
    ('外观', Icons.palette),
    ('快捷键', Icons.keyboard),
    ('通用', Icons.tune),
    ('关于', Icons.info),
  ];

  // ── Search logic ──
  static const _searchIndex = <String, int>{
    '编辑器': 0, '编辑': 0, '字体': 0, '字号': 0, '行间距': 0, '页面宽度': 0,
    '存储': 1, '备份': 1, '保存': 1, '路径': 1, '云端': 1, '恢复': 1,
    '外观': 2, '主题': 2, '深色': 2, '浅色': 2, '护眼': 2, '缩放': 2,
    '快捷键': 3, 'Ctrl': 3, '组合键': 3,
    '通用': 4, '语言': 4, '启动': 4, '安全锁': 4, '密码': 4, '回收站': 4, '历史记录': 4, '缓存': 4,
    '关于': 5, '版本': 5, '更新': 5,
  };

  List<String> get _searchResults {
    if (_query.isEmpty) return [];
    return _searchIndex.keys.where((k) => k.contains(_query)).take(8).toList();
  }

  void _searchAndGo(String keyword) {
    final idx = _searchIndex[keyword];
    if (idx != null) {
      setState(() { _tabIndex = idx; _query = ''; _searchCtrl.clear(); });
      _searchFocus.unfocus();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _trashCtrl = TextEditingController(text: '$_trashDays');
    _historyCtrl = TextEditingController(text: '$_historyCount');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _trashCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        if (isDesktop) AppSidebar(
          currentRoute: 'settings',
          onNavigateToWriting: widget.onNavigateToWriting,
          onNavigateToFiles: widget.onNavigateToFiles,
          onNavigateToMaterials: widget.onNavigateToMaterials,
          onNavigateToStats: widget.onNavigateToStats,
        ),
        Expanded(child: Column(children: [
          _buildTopBar(),
          Expanded(child: _buildBody(isDesktop)),
        ])),
        if (!isDesktop) _buildMobileNav(),
      ]),
    );
  }

  // ──────────── Top bar with working search ────────────
  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(color: AppColors.background.withAlpha(204),
        border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5))),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(child: TapRegion(
            onTapOutside: (_) { _searchFocus.unfocus(); setState(() => _query = ''); },
            child: Shortcuts(
              shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
              child: Actions(actions: {DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) { _searchFocus.unfocus(); setState(() => _query = ''); })},
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(height: 38, child: Container(
                    constraints: const BoxConstraints(maxWidth: 672),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: _searchFocus.hasFocus ? AppColors.primary : AppColors.outline, width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 1))]),
                    child: Row(children: [
                      const Padding(padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(Icons.search, size: 20, color: AppColors.outline)),
                      Expanded(child: TextField(
                        controller: _searchCtrl, focusNode: _searchFocus,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          hintText: '搜索设置',
                          hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.outline),
                          border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                          filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      )),
                    ]),
                  )),
                  if (_query.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 672),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.outlineVariant),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))]),
                        child: _searchResults.isEmpty
                            ? const Padding(padding: EdgeInsets.all(24), child: Text('未找到匹配设置', style: TextStyle(fontSize: 14, color: AppColors.outline)))
                            : Column(mainAxisSize: MainAxisSize.min,
                                children: _searchResults.map((k) => InkWell(
                                  onTap: () => _searchAndGo(k),
                                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(children: [
                                      const Icon(Icons.settings, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(k, style: const TextStyle(fontSize: 14, color: AppColors.onSurface))),
                                      const Icon(Icons.near_me, size: 18, color: AppColors.secondary),
                                    ])),
                                )).toList()),
                      ),
                    ),
                ]),
              ),
            ),
          )),
        ]),
      )),
    );
  }

  // ──────────── Body ────────────
  Widget _buildBody(bool showSidebar) {
    if (!showSidebar) return _buildContent();

    return Row(children: [
      // Settings sidebar
      Container(
        width: 256,
        color: AppColors.surfaceContainerLow,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.all(24),
            child: Text('设置', style: TextStyle(fontFamily: 'Manrope', fontSize: 22,
                fontWeight: FontWeight.w700, color: AppColors.onSurface))),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8),
              children: List.generate(_tabs.length, (i) {
                final sel = i == _tabIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: sel ? AppColors.surfaceContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => setState(() => _tabIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: sel ? const Border(left: BorderSide(color: AppColors.secondary, width: 4)) : null,
                        ),
                        child: Row(children: [
                          Icon(_tabs[i].$2, size: 20, color: sel ? AppColors.primary : AppColors.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(_tabs[i].$1, style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? AppColors.primary : AppColors.onSurfaceVariant)),
                        ]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ]),
      ),
      const VerticalDivider(width: 1, color: AppColors.outlineVariant),
      Expanded(child: _buildContent()),
    ]);
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 8, 40, 40),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720),
        child: _buildCurrentTab(),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabIndex) {
      case 0: return _buildEditorTab();
      case 1: return _buildStorageTab();
      case 2: return _buildAppearanceTab();
      case 3: return _buildShortcutsTab();
      case 4: return _buildGeneralTab();
      default: return _buildAboutTab();
    }
  }

  // ════════════ EDITOR TAB ════════════
  Widget _buildEditorTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('编辑器设置', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 32),
      LayoutBuilder(builder: (_, c) {
        final wide = c.maxWidth > 500;
        final controls = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('字体', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.outlineVariant)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(isExpanded: true, value: _fontFamily,
                items: ['Source Serif 4', 'Manrope', 'System Mono']
                    .map((s) => DropdownMenuItem<String>(value: s, child: Text(s, style: const TextStyle(fontSize: 15)))).toList(),
                onChanged: (v) => setState(() => _fontFamily = v ?? 'Source Serif 4')),
            ),
          ),
          const SizedBox(height: 24),
          _slider('字号', _fontSize, 12, 32, 1, 'px', (v) => setState(() => _fontSize = v)),
          const SizedBox(height: 24),
          _slider('行间距', _lineHeight, 1.0, 2.5, 0.1, 'x', (v) => setState(() => _lineHeight = v)),
        ]);
        final preview = Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outlineVariant)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('实时预览', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.outlineVariant)),
              constraints: BoxConstraints(maxWidth: _pageWidth),
              child: Text(
                '避风港是一个专为创作者设计的宁静空间。在这里，您可以远离尘世的喧嚣……',
                style: TextStyle(fontFamily: _fontFamily, fontSize: _fontSize, height: _lineHeight, color: AppColors.onSurface)),
            ),
          ]),
        );
        if (wide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: controls),
            const SizedBox(width: 40),
            Expanded(flex: 4, child: preview),
          ]);
        }
        return Column(children: [controls, const SizedBox(height: 24), preview]);
      }),
    ]);
  }

  // ════════════ STORAGE TAB ════════════
  Widget _buildStorageTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('存储与备份', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 32),
      _sec('本地存储路径', [
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: const Text('C:\\Users\\User\\Documents\\WriterSanctuary',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
          )),
          const SizedBox(width: 12),
          FilledButton(onPressed: () {}, style: _btnStyle(),
            child: const Text('更改', style: TextStyle(fontSize: 14))),
          const SizedBox(width: 8),
          OutlinedButton.icon(onPressed: () {}, style: _outlineStyle(),
            icon: const Icon(Icons.folder_open, size: 18), label: const Text('打开文件夹', style: TextStyle(fontSize: 13))),
        ]),
      ]),
      const SizedBox(height: 32),
      _sec('自动保存', [
        _toggle('自动保存您的所有修改', _autoSave, (v) => setState(() => _autoSave = v)),
        if (_autoSave) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dropdown('保存间隔', ['10秒', '30秒', '1分钟', '3分钟', '5分钟', '10分钟'], _saveInterval, (v) => setState(() => _saveInterval = v)),
              const SizedBox(height: 14),
              _check('空闲时自动保存', _idleSave, (v) => setState(() => _idleSave = v)),
              const SizedBox(height: 8),
              _check('显示保存状态', _showSaveStatus, (v) => setState(() => _showSaveStatus = v)),
            ])),
        ],
      ]),
      const SizedBox(height: 32),
      _sec('自动备份', [
        _toggle('定期在后台创建完整的数据库备份', _autoBackup, (v) => setState(() => _autoBackup = v)),
        if (_autoBackup) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dropdown('备份频率', ['30分钟', '1小时'], _backupFreq, (v) => setState(() => _backupFreq = v)),
              const SizedBox(height: 14),
              _dropdown('备份保留数量', ['5份', '10份', '20份', '30份', '无限'], _backupCount, (v) => setState(() => _backupCount = v)),
              const SizedBox(height: 14),
              _check('退出软件时备份', _exitBackup, (v) => setState(() => _exitBackup = v)),
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: () {}, style: _outlineStyle(),
                icon: const Icon(Icons.history, size: 18), label: const Text('历史备份管理', style: TextStyle(fontSize: 13))),
            ])),
        ],
      ]),
      const SizedBox(height: 32),
      _sec('云端与恢复', [
        Row(children: [
          SizedBox(width: 180, child: FilledButton.icon(
            onPressed: () {}, style: _btnStyle(),
            icon: const Icon(Icons.cloud_upload, size: 20), label: const Text('上传云端', style: TextStyle(fontSize: 15)),
          )),
          const SizedBox(width: 16),
          OutlinedButton.icon(onPressed: () {}, style: _outlineStyle(),
            icon: const Icon(Icons.medical_services, size: 18), label: const Text('崩溃恢复', style: TextStyle(fontSize: 13))),
          const SizedBox(width: 12),
          OutlinedButton.icon(onPressed: () {}, style: _outlineStyle(),
            icon: const Icon(Icons.restore, size: 18), label: const Text('恢复历史版本', style: TextStyle(fontSize: 13))),
        ]),
      ]),
    ]);
  }

  // ════════════ APPEARANCE TAB ════════════
  Widget _buildAppearanceTab() {
    final themes = [
      ('浅色', AppColors.background),
      ('深色', const Color(0xFF1a1c2e)),
      ('护眼', const Color(0xFFf2e6d9)),
      ('跟随系统', AppColors.background),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('外观设置', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 32),
      const Text('主题模式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      // Manual row of 4 theme cards — avoids GridView gesture conflicts
      LayoutBuilder(builder: (_, c) {
        final w = (c.maxWidth - 36) / 4; // 3 gaps of 12px
        return Row(children: List.generate(4, (i) {
          final (label, color) = themes[i];
          final sel = i == _themeIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
            child: SizedBox(width: w,
              child: GestureDetector(
                onTap: () => setState(() => _themeIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.outlineVariant, width: sel ? 2 : 1)),
                  child: AspectRatio(aspectRatio: 1, child: Column(children: [
                    Expanded(child: Container(decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(AppRadius.normal),
                      border: Border.all(color: AppColors.outlineVariant)))),
                    const SizedBox(height: 8),
                    Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? AppColors.primary : AppColors.onSurfaceVariant)),
                  ])),
                ),
              ),
            ),
          );
        }));
      }),
      const SizedBox(height: 32),
      _slider('界面缩放', _zoom, 80, 150, 5, '%', (v) => setState(() => _zoom = v)),
      const SizedBox(height: 4),
      Text('调整系统图标、文字和间距的整体大小。', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant.withAlpha(180))),
    ]);
  }

  // ════════════ SHORTCUTS TAB ════════════
  Widget _buildShortcutsTab() {
    const items = [
      ('保存文档', 'Ctrl + S'), ('新建文档', 'Ctrl + N'), ('全屏聚焦模式', 'F11'),
      ('查找替换', 'Ctrl + F'), ('插入图片', 'Ctrl + Shift + I'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('快捷键', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 32),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant)),
        clipBehavior: Clip.antiAlias,
        child: Table(columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)}, children: [
          TableRow(decoration: BoxDecoration(color: AppColors.surfaceContainerHigh), children: [
            _td('操作命令', bold: true), _td('组合键', bold: true),
          ]),
          ...items.map((s) => TableRow(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.3))),
            children: [
              _td(s.$1),
              Padding(padding: const EdgeInsets.all(16), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.normal), border: Border.all(color: AppColors.outlineVariant)),
                child: Text(s.$2, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.onSurface)),
              )),
            ],
          )),
        ]),
      ),
    ]);
  }

  static Widget _td(String t, {bool bold = false}) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(t, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)));

  // ════════════ GENERAL TAB ════════════
  Widget _buildGeneralTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('通用设置', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26)),
      const SizedBox(height: 32),
      // Language + Startup page
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _dropdown('软件语言', ['简体中文', '繁體中文', 'English'], _language, (v) => setState(() => _language = v))),
        const SizedBox(width: 24),
        Expanded(child: _dropdown('默认启动页', ['书架', '写作/统筹', '文件', '统计'], _startPage, (v) => setState(() => _startPage = v))),
      ]),
      const SizedBox(height: 48),
      // Security lock
      const Text('安全锁', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      const SizedBox(height: 6),
      Text('启动软件时需要输入密码', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 12),
      Row(children: [
        TextButton(
          onPressed: () {},
          child: const Text('设置密码', style: TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline, fontSize: 14)),
        ),
        const Spacer(),
        _toggleSmall(_securityLock, () => setState(() => _securityLock = !_securityLock)),
      ]),
      const SizedBox(height: 48),
      // Trash settings
      const Text('回收站设置', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('文件保留时间', style: TextStyle(fontSize: 15)),
        Row(children: [
          SizedBox(width: 80, child: TextField(
            controller: _trashCtrl,
            keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true),
            onChanged: (v) => setState(() => _trashDays = int.tryParse(v) ?? _trashDays),
          )),
          const SizedBox(width: 8),
          const Text('天', style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant)),
        ]),
      ]),
      const SizedBox(height: 4),
      Text('自动永久删除超过指定天数的文件。', style: TextStyle(fontSize: 12, color: AppColors.outline)),
      const SizedBox(height: 40),
      // History settings
      const Text('历史设置', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('历史记录保留条数', style: TextStyle(fontSize: 15)),
        Row(children: [
          SizedBox(width: 80, child: TextField(
            controller: _historyCtrl,
            keyboardType: TextInputType.number, style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true),
            onChanged: (v) => setState(() => _historyCount = int.tryParse(v) ?? _historyCount),
          )),
          const SizedBox(width: 8),
          const Text('条', style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant)),
        ]),
      ]),
      const SizedBox(height: 4),
      Text('每篇文档保留的历史编辑版本上限。', style: TextStyle(fontSize: 12, color: AppColors.outline)),
      const SizedBox(height: 48),
      OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        icon: const Icon(Icons.delete_sweep, size: 20),
        label: const Text('清理缓存', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
      ),
    ]);
  }

  // ════════════ ABOUT TAB ════════════
  Widget _buildAboutTab() {
    return Column(children: [
      const SizedBox(height: 40),
      Container(width: 96, height: 96,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(30), blurRadius: 20, offset: const Offset(0, 8))]),
        child: const Icon(Icons.auto_stories, size: 48, color: Colors.white)),
      const SizedBox(height: 24),
      const Text('universal writer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('版本 v1.2.0 (Stable Build)', style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant.withAlpha(200))),
      const SizedBox(height: 40),
      _aboutLink('关于软件'),
      const SizedBox(height: 12),
      _aboutLink('检查更新'),
      const SizedBox(height: 48),
      Text('© 2026 universal writer Team. 保留所有权利。\n用爱心与代码为全球创作者打造的宁静之所。',
          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant.withAlpha(120)), textAlign: TextAlign.center),
    ]);
  }

  Widget _aboutLink(String label) => SizedBox(width: 400, child: Material(
    color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.xl),
    child: InkWell(borderRadius: BorderRadius.circular(AppRadius.xl), onTap: () {},
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.outlineVariant)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ])),
    ),
  ));

  // ──────────── Shared widgets ────────────
  Widget _sec(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12), ...children,
    ]);
  }

  Widget _slider(String label, double val, double min, double max, double step, String unit, ValueChanged<double> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text('${step < 1 ? val.toStringAsFixed(1) : val.toInt()}$unit', style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ]),
      SliderTheme(data: SliderThemeData(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
        child: Slider(value: val, min: min, max: max, divisions: ((max - min) / step).round(),
          activeColor: AppColors.primary, inactiveColor: AppColors.surfaceContainerHigh, onChanged: onChange)),
    ]);
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChange) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
      GestureDetector(
        onTap: () => onChange(!value),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
          width: 44, height: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
            color: value ? AppColors.secondary : AppColors.surfaceContainerHighest),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.all(2),
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _toggleSmall(bool value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        width: 44, height: 24,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          color: value ? AppColors.secondary : AppColors.surfaceContainerHighest),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(2),
        child: Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChange) {
    return GestureDetector(
      onTap: () => onChange(!value),
      child: Row(children: [
        Icon(value ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _dropdown(String label, List<String> options, String value, ValueChanged<String> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.outlineVariant)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(isExpanded: true, value: value,
            items: options.map((o) => DropdownMenuItem<String>(value: o, child: Text(o, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (v) { if (v != null) onChange(v); }),
        ),
      ),
    ]);
  }

  ButtonStyle _btnStyle() => FilledButton.styleFrom(
    backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)));
  ButtonStyle _outlineStyle() => OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColors.outline), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)));

  // ── Mobile nav ──
  Widget _buildMobileNav() {
    return Container(height: 64,
      decoration: BoxDecoration(color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, -2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _mob(Icons.edit, '写作', false, widget.onNavigateToWriting),
        _mob(Icons.folder, '文件', false, widget.onNavigateToFiles),
        _mob(Icons.inventory_2, '素材', false, widget.onNavigateToMaterials),
        _mob(Icons.insights, '统计', false, widget.onNavigateToStats),
        _mob(Icons.settings, '设置', true, null),
      ]));
  }

  Widget _mob(IconData i, String l, bool a, VoidCallback? t) => InkWell(onTap: t,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(i, size: 22, color: a ? AppColors.primary : AppColors.onSurfaceVariant),
      const SizedBox(height: 4),
      Text(l, style: TextStyle(fontSize: 10, fontWeight: a ? FontWeight.w600 : FontWeight.w400, color: a ? AppColors.primary : AppColors.onSurfaceVariant)),
    ]));
}
