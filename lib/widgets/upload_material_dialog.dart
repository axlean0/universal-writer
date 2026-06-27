import 'package:flutter/material.dart' hide MaterialType;
import '../theme/app_theme.dart';
import '../models/material_item.dart';

/// Maps file extensions to MaterialType.
/// Supported: txt/docx→document, pdf→pdf, jpg/jpeg/png→image, mp4→video, mp3→audio
MaterialType? detectType(String filename) {
  final ext = filename.toLowerCase().split('.').last.trim();
  switch (ext) {
    case 'txt': case 'docx': return MaterialType.document;
    case 'pdf':  return MaterialType.pdf;
    case 'jpg': case 'jpeg': case 'png': return MaterialType.image;
    case 'mp4':  return MaterialType.video;
    case 'mp3':  return MaterialType.audio;
    default:     return null;
  }
}

class UploadMaterialDialog extends StatefulWidget {
  final List<String> groups;
  final Function(MaterialItem) onUpload;

  const UploadMaterialDialog({super.key, required this.groups, required this.onUpload});

  @override
  State<UploadMaterialDialog> createState() => _UploadMaterialDialogState();
}

class _UploadMaterialDialogState extends State<UploadMaterialDialog> {
  final _nameCtrl = TextEditingController(text: '未命名素材');
  final _descCtrl = TextEditingController();
  String? _targetGroup;
  bool _showNewGroup = false;
  final _newGroupCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _typeError;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final name = _nameCtrl.text.trim();
    final detected = detectType(name);
    setState(() {
      if (detected == null && name.isNotEmpty && name != '未命名素材') {
        _typeError = '该文件类型无法上传';
      } else {
        _typeError = null;
      }
    });
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); _newGroupCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))]),
        child: Form(key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('上传素材', style: TextStyle(fontFamily: 'Manrope', fontSize: 20,
                    fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                IconButton(onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20), splashRadius: 16, color: AppColors.outline),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Upload area
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                    ),
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.cloud_upload, size: 32, color: AppColors.outline),
                      const SizedBox(height: 8),
                      const Text('点击选择文件', style: TextStyle(fontSize: 14, color: AppColors.outline)),
                    ])),
                  ),
                  const SizedBox(height: 12),
                  // Supported types hint
                  Row(children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('支持：txt, docx → 文档 ｜ pdf → PDF ｜ jpg, jpeg, png → 图片 ｜ mp4 → 视频 ｜ mp3 → 音频',
                        style: TextStyle(fontSize: 11, color: AppColors.outline.withAlpha(200))),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // Name (auto-detects type from extension)
                  const Text('文件名称', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('输入含后缀的文件名，自动识别类型', style: TextStyle(fontSize: 11, color: AppColors.outline.withAlpha(180))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl, maxLength: 80,
                    decoration: InputDecoration(
                      hintText: '例如：角色设定.png，大纲.txt',
                      counterText: '',
                      errorText: _typeError,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '名称不能为空';
                      if (detectType(v.trim()) == null) return '该文件类型无法上传，请检查文件后缀';
                      return null;
                    },
                  ),
                  // Description
                  const Text('简介', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(controller: _descCtrl, maxLength: 150, maxLines: 2,
                    decoration: const InputDecoration(hintText: '简介（选填）', contentPadding: EdgeInsets.all(12))),
                  const SizedBox(height: 16),
                  // Group
                  const Text('素材分组', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _targetGroup ?? '（根目录）',
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: [
                      const DropdownMenuItem(value: '（根目录）', child: Text('（不指定分组）', style: TextStyle(fontSize: 14))),
                      ...widget.groups.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 14)))),
                      const DropdownMenuItem(value: '__new__', child: Row(children: [
                        Icon(Icons.add, size: 16, color: AppColors.secondary), SizedBox(width: 8),
                        Text('新建分组', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
                      ])),
                    ],
                    onChanged: (v) => setState(() {
                      if (v == '__new__') { _showNewGroup = true; } else { _targetGroup = v; _showNewGroup = false; }
                    }),
                  ),
                  if (_showNewGroup) ...[
                    const SizedBox(height: 12),
                    TextFormField(controller: _newGroupCtrl, maxLength: 15,
                      decoration: const InputDecoration(hintText: '新分组名称（≤15字符）', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                  ],
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(height: 48, child: FilledButton(
                onPressed: _handleUpload,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600)),
                child: const Text('上传素材'),
              )),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleUpload() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final name = _nameCtrl.text.trim();
    final t = detectType(name)!;
    final g = _showNewGroup && _newGroupCtrl.text.trim().isNotEmpty
        ? _newGroupCtrl.text.trim() : (_targetGroup == '（根目录）' ? '未分类' : _targetGroup ?? '未分类');
    final item = MaterialItem(
      id: now.millisecondsSinceEpoch.toString(),
      name: name, type: t, group: g, size: 102400,
      description: _descCtrl.text.trim(),
      uploadedAt: now, lastOpenedAt: now,
    );
    widget.onUpload(item);
    Navigator.of(context).pop();
  }

}
