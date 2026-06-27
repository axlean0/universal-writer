import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/file_item.dart';

/// Dialog for creating a new folder or text file.
class CreateFileDialog extends StatefulWidget {
  final List<String> folders;
  final Function(FileItem) onCreate;

  const CreateFileDialog({
    super.key,
    required this.folders,
    required this.onCreate,
  });

  @override
  State<CreateFileDialog> createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<CreateFileDialog> {
  // 0 = folder, 1 = text
  int _tabIndex = 0;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _targetFolder;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 40, offset: const Offset(0, 10))],
        ),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('新建文件',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 20,
                      fontWeight: FontWeight.w600, color: AppColors.onBackground),
                ),
                IconButton(onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                  splashRadius: 16, color: AppColors.outline),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Type tabs
                  Row(children: [
                    _buildTypeTab('文件夹', 0, Icons.folder),
                    const SizedBox(width: 12),
                    _buildTypeTab('文本文档', 1, Icons.description),
                  ]),
                  const SizedBox(height: 24),
                  // Name
                  const Text('名称', style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: _tabIndex == 0 ? '文件夹名称（必填）' : '文档名称（必填）',
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '名称不能为空';
                      if (v.trim().length > 30) return '名称不超过30个字符';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text('简介', style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    maxLength: 150,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: '简介（选填）',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  // Target folder (text only)
                  if (_tabIndex == 1 && widget.folders.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('所属文件夹', style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _targetFolder ?? '（当前目录）',
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: '（当前目录）',
                            child: Text('（当前目录，不指定）', style: TextStyle(fontSize: 14))),
                        ...widget.folders.map((f) =>
                            DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 14)))),
                      ],
                      onChanged: (v) => setState(() => _targetFolder = v),
                    ),
                  ],
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _handleCreate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('创建'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, int index, IconData icon) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: selected ? null : Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(children: [
            Icon(icon, size: 28,
                color: selected ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontFamily: 'Manrope', fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final item = FileItem(
      id: now.millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _tabIndex == 0 ? FileType.folder : FileType.text,
      parentId: _targetFolder == '（当前目录）' ? null : _targetFolder,
      size: _tabIndex == 1 ? 1024 : 0,
      description: _descController.text.trim(),
      createdAt: now,
      lastModifiedAt: now,
    );
    widget.onCreate(item);
    Navigator.of(context).pop();
  }
}
