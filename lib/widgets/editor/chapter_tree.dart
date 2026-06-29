import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';

String _toCn(int n) {
  if (n <= 0) return '零';
  const d = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  const t = ['', '十', '二十', '三十', '四十', '五十', '六十', '七十', '八十', '九十'];
  if (n < 10) return d[n];
  if (n < 100) return '${t[n ~/ 10]}${d[n % 10]}';
  return '$n';
}

class ChapterTree extends StatefulWidget {
  final String? activeChapterId;
  final String? activeVolumeId;
  final EditorMode initialMode;
  final ValueChanged<Chapter> onSelectChapter;
  final ValueChanged<Volume>? onSelectVolume;
  final VoidCallback onBack;
  final VoidCallback? onChanged;
  final ValueChanged<EditorMode>? onModeChanged;

  const ChapterTree({
    super.key,
    this.activeChapterId,
    this.activeVolumeId,
    this.initialMode = EditorMode.body,
    required this.onSelectChapter,
    this.onSelectVolume,
    required this.onBack,
    this.onChanged,
    this.onModeChanged,
  });

  @override
  State<ChapterTree> createState() => _ChapterTreeState();
}

class _ChapterTreeState extends State<ChapterTree> {
  late EditorMode _mode;
  final Set<String> _expandedVolumeIds = {};
  final GlobalKey _newBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _showNewMenu() {
    final RenderBox box = _newBtnKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final btnWidth = box.size.width;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + box.size.height + 4,
          offset.dx + btnWidth, offset.dy + box.size.height + 4),
      constraints: BoxConstraints(minWidth: btnWidth),
      elevation: 8, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant)),
      items: const [
        PopupMenuItem(value: 'volume', height: 40,
          child: Row(children: [Icon(Icons.create_new_folder, size: 20, color: AppColors.primary), SizedBox(width: 12),
            Text('新建卷', style: TextStyle(fontFamily: 'Manrope', fontSize: 15))])),
        PopupMenuItem(value: 'chapter', height: 40,
          child: Row(children: [Icon(Icons.note_add, size: 20, color: AppColors.primary), SizedBox(width: 12),
            Text('新建章', style: TextStyle(fontFamily: 'Manrope', fontSize: 15))])),
      ],
    ).then((v) {
      if (v == null || !mounted) return;
      final book = EditorRepository.i.current;
      final isVol = v == 'volume';
      final nextNum = isVol
          ? book.volumes.length + 1
          : book.volumes.firstWhere((x) => _expandedVolumeIds.contains(x.id),
              orElse: () => book.volumes.isNotEmpty ? book.volumes.first : book.volumes.last)
              .chapters.length + 1;
      final numStr = '第${_toCn(nextNum)}${isVol ? '卷' : '章'}';

      _showCreateDialog(isVol ? '新建卷' : '新建章', numStr, (name) {
        final full = '$numStr $name';
        if (isVol) {
          EditorRepository.i.addVolume(full);
          _expandedVolumeIds.add(book.volumes.last.id);
        } else {
          final vid = book.volumes.firstWhere((x) => _expandedVolumeIds.contains(x.id),
              orElse: () => book.volumes.first).id;
          EditorRepository.i.addChapter(vid, full);
          _expandedVolumeIds.add(vid);
          widget.onSelectChapter(book.volumes.firstWhere((x) => x.id == vid).chapters.last);
        }
        setState(() {});
        widget.onChanged?.call();
      });
    });
  }

  void _showCreateDialog(String title, String numPrefix, ValueChanged<String> onConfirm) {
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Number display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Row(children: [
                  const Icon(Icons.tag, size: 16, color: AppColors.outline),
                  const SizedBox(width: 8),
                  Text('编号：$numPrefix', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                autofocus: true, maxLength: 15,
                decoration: const InputDecoration(hintText: '名称（必填，≤15字符）', counterText: ''),
                validator: (v) => (v == null || v.trim().isEmpty) ? '名称不能为空' : null,
                onChanged: (_) => setDlg(() {}),
              ),
              if (nameCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Row(children: [
                    const Icon(Icons.visibility, size: 16, color: AppColors.outline),
                    const SizedBox(width: 8),
                    Expanded(child: Text('$numPrefix ${nameCtrl.text}', style: const TextStyle(fontSize: 14, color: AppColors.primary))),
                  ]),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onConfirm(nameCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeMenu(Volume v) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(150, 400, 250, 400),
      items: [
        _menuItem(Icons.edit, '重命名', 'rename'),
        _menuItem(Icons.delete_outline, '删除', 'delete'),
      ],
      elevation: 8, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant)),
    ).then((action) {
      if (action == null || !mounted) return;
      if (action == 'delete') {
        setState(() => EditorRepository.i.deleteVolume(v.id));
        widget.onChanged?.call();
      } else if (action == 'rename') {
        _showRenameDialog('重命名卷', v.title, (newName) {
          EditorRepository.i.renameVolume(v.id, newName);
          setState(() {});
          widget.onChanged?.call();
        });
      }
    });
  }

  void _showChapterMenu(Chapter c) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(180, 450, 280, 450),
      items: [
        _menuItem(Icons.edit, '重命名', 'rename'),
        _menuItem(Icons.delete_outline, '删除', 'delete'),
      ],
      elevation: 8, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant)),
    ).then((action) {
      if (action == null || !mounted) return;
      if (action == 'delete') {
        setState(() => EditorRepository.i.deleteChapter(c.id));
        widget.onChanged?.call();
      } else if (action == 'rename') {
        _showRenameDialog('重命名章节', c.title, (newName) {
          EditorRepository.i.renameChapter(c.id, newName);
          setState(() {});
          widget.onChanged?.call();
        });
      }
    });
  }

  void _showRenameDialog(String title, String current, ValueChanged<String> onConfirm) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () {
            if (ctrl.text.trim().isNotEmpty) {
              onConfirm(ctrl.text.trim());
              Navigator.pop(ctx);
            }
          }, child: const Text('确定')),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label, String value) =>
      PopupMenuItem<String>(value: value, height: 36,
        child: Row(children: [Icon(icon, size: 18, color: AppColors.onSurfaceVariant), const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontFamily: 'Manrope', fontSize: 14))]));

  @override
  Widget build(BuildContext context) {
    final book = EditorRepository.i.current;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            InkWell(onTap: widget.onBack, borderRadius: BorderRadius.circular(999),
              child: const Padding(padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back, size: 24, color: AppColors.onSurfaceVariant))),
            const SizedBox(width: 12),
            Expanded(child: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 20,
                  fontWeight: FontWeight.w700, color: AppColors.onSurface))),
          ]),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              _switcherBtn('正文', EditorMode.body),
              _switcherBtn('剧作', EditorMode.drama),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(key: _newBtnKey, width: double.infinity, child: FilledButton.icon(
            onPressed: _showNewMenu,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('新建', style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          )),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8),
            children: book.volumes.expand<Widget>((v) => _buildVolume(v)).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _switcherBtn(String label, EditorMode mode) {
    final sel = _mode == mode;
    return Expanded(child: GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        widget.onModeChanged?.call(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: sel ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 2)] : null,
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Source Serif 4', fontSize: 18,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color: sel ? AppColors.primary : AppColors.onSurfaceVariant)),
      ),
    ));
  }

  List<Widget> _buildVolume(Volume v) {
    final expanded = _expandedVolumeIds.contains(v.id);
    final isActive = widget.activeVolumeId == v.id && _mode == EditorMode.drama;
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          color: isActive ? AppColors.secondaryContainer.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: isActive ? const Border(left: BorderSide(color: AppColors.secondary, width: 2)) : null,
            ),
            child: Row(children: [
              // Arrow — expand/collapse only
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() {
                  if (expanded) { _expandedVolumeIds.remove(v.id); } else { _expandedVolumeIds.add(v.id); }
                }),
                child: Padding(padding: const EdgeInsets.all(2),
                  child: Icon(expanded ? Icons.expand_more : Icons.chevron_right, size: 20, color: AppColors.outline)),
              ),
              const SizedBox(width: 8),
              // Volume title — select for editing or toggle expand
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (widget.onSelectVolume != null) {
                      // Select volume for drama mode editing
                      widget.onSelectVolume!(v);
                      // Also expand to show chapters
                      setState(() => _expandedVolumeIds.add(v.id));
                    } else {
                      setState(() {
                        if (expanded) { _expandedVolumeIds.remove(v.id); } else { _expandedVolumeIds.add(v.id); }
                      });
                    }
                  },
                  child: Text(v.title, style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.onSurface)),
                ),
              ),
              InkWell(onTap: () => _showVolumeMenu(v), borderRadius: BorderRadius.circular(4),
                child: const Padding(padding: EdgeInsets.all(2),
                  child: Icon(Icons.more_vert, size: 18, color: AppColors.outline))),
            ]),
          ),
        ),
      ),
      if (expanded)
        ...v.chapters.map((c) {
          final active = c.id == widget.activeChapterId;
          return Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 2),
            child: Material(
              color: active ? AppColors.secondaryContainer.withAlpha(50) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => widget.onSelectChapter(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: active ? const Border(left: BorderSide(color: AppColors.secondary, width: 2)) : null,
                  ),
                  child: Row(children: [
                    Expanded(child: Text(c.title, style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: active ? AppColors.primary : AppColors.onSurfaceVariant))),
                    InkWell(onTap: () => _showChapterMenu(c), borderRadius: BorderRadius.circular(4),
                      child: const Padding(padding: EdgeInsets.all(2),
                        child: Icon(Icons.more_vert, size: 16, color: AppColors.outline))),
                  ]),
                ),
              ),
            ),
          );
        }),
    ];
  }
}
