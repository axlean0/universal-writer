import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';

/// Dialog for creating a new work (book or article).
class CreateWorkDialog extends StatefulWidget {
  final Function(Book) onCreate;

  const CreateWorkDialog({super.key, required this.onCreate});

  @override
  State<CreateWorkDialog> createState() => _CreateWorkDialogState();
}

class _CreateWorkDialogState extends State<CreateWorkDialog> {
  BookType _type = BookType.book;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedGroup = '未分类';
  final _newGroupController = TextEditingController();
  bool _showNewGroup = false;

  final _groups = ['未分类', '长篇小说', '灵感随笔', '短篇集', '研究笔记'];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newGroupController.dispose();
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title bar
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '创建新作品',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      splashRadius: 16,
                      color: AppColors.outline,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Type Toggle ──
                      const Text(
                        '作品类型',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTypeChip('书籍', BookType.book,
                              Icons.menu_book),
                          const SizedBox(width: 12),
                          _buildTypeChip('文章', BookType.article,
                              Icons.article),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // ── Cover (placeholder) ──
                      const Text(
                        '作品封面',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: _type == BookType.book
                              ? AppColors.primaryContainer.withAlpha(40)
                              : AppColors.tertiaryContainer.withAlpha(40),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '点击上传封面（可选）',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _type == BookType.book ? '默认：书籍样式封面' : '默认：文章样式封面',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ── Name ──
                      const Text(
                        '作品名称',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        maxLength: 30,
                        decoration: const InputDecoration(
                          hintText: '请输入作品名称',
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return '作品名称不能为空';
                          }
                          if (v.trim().length > 30) {
                            return '名称不超过30个字符';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // ── Description ──
                      const Text(
                        '作品简介',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 300,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: '简介（非必填，最多300字）',
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ── Group ──
                      const Text(
                        '作品分组',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGroup,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          ..._groups.map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g, style: const TextStyle(fontSize: 14)),
                              )),
                          const DropdownMenuItem(
                            value: '__new__',
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16, color: AppColors.secondary),
                                SizedBox(width: 8),
                                Text('新建分组',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.secondary)),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == '__new__') {
                            setState(() {
                              _showNewGroup = true;
                            });
                          } else if (v != null) {
                            setState(() {
                              _selectedGroup = v;
                              _showNewGroup = false;
                            });
                          }
                        },
                      ),
                      if (_showNewGroup) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newGroupController,
                          maxLength: 15,
                          decoration: const InputDecoration(
                            hintText: '新分组名称（≤15字符）',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (v) {
                            if (v.trim().isNotEmpty) {
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // ── Create Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _handleCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('创建作品'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, BookType type, IconData icon) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: selected
                ? null
                : Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    String group = _selectedGroup;
    if (_showNewGroup && _newGroupController.text.trim().isNotEmpty) {
      group = _newGroupController.text.trim();
    }

    final now = DateTime.now();
    final book = Book(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      type: _type,
      wordCount: 0,
      group: group,
      createdAt: now,
      lastEditedAt: now,
    );

    widget.onCreate(book);
    Navigator.of(context).pop();
  }
}
