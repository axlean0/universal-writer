import 'package:flutter/material.dart';
import '../../models/drama_card_model.dart';
import '../../theme/app_theme.dart';

class CardCreateDialog extends StatefulWidget {
  final ValueChanged<DramaCard> onCreate;

  const CardCreateDialog({super.key, required this.onCreate});

  @override
  State<CardCreateDialog> createState() => _CardCreateDialogState();
}

class _CardCreateDialogState extends State<CardCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _assocCtrl = TextEditingController();
  CardType _type = CardType.character;
  bool _starred = false;
  final List<String> _tags = [];

  static final _types = [CardType.character, CardType.location, CardType.faction, CardType.item, CardType.event, CardType.worldSetting, CardType.custom];

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() => _tags.add(t));
      _tagCtrl.clear();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _tagCtrl.dispose(); _assocCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('新建卡片', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20), splashRadius: 16, color: AppColors.outline),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('卡片类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6,
                    children: _types.map((t) {
                      final sel = _type == t;
                      return GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(t.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.onSurfaceVariant)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('名称', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(controller: _nameCtrl, maxLength: 20,
                    decoration: const InputDecoration(hintText: '卡片名称（必填）', counterText: ''),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '名称不能为空' : null),
                  const SizedBox(height: 16),
                  const Text('简介', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(controller: _descCtrl, maxLength: 200, maxLines: 2,
                    decoration: const InputDecoration(hintText: '简介（选填）', contentPadding: EdgeInsets.all(12))),
                  const SizedBox(height: 16),
                  const Text('标签', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: _tagCtrl,
                      onSubmitted: _addTag,
                      decoration: const InputDecoration(hintText: '输入后回车添加', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    )),
                    const SizedBox(width: 8),
                    IconButton(onPressed: () => _addTag(_tagCtrl.text), icon: const Icon(Icons.add, size: 20), splashRadius: 16, color: AppColors.primary),
                  ]),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 4, runSpacing: 4,
                      children: _tags.map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _tags.remove(t)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList()),
                  ],
                  const SizedBox(height: 16),
                  const Text('关联章节', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(controller: _assocCtrl,
                    decoration: const InputDecoration(hintText: '用逗号分隔，如：第一章,第三章', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _starred = !_starred),
                      child: Icon(_starred ? Icons.star : Icons.star_border, size: 20, color: _starred ? AppColors.secondary : AppColors.outline),
                    ),
                    const SizedBox(width: 8),
                    const Text('收藏', style: TextStyle(fontSize: 14)),
                  ]),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(height: 48, child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final assoc = _assocCtrl.text.split(RegExp(r'[,，]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                    final card = DramaCard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _nameCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      type: _type,
                      tags: List.from(_tags),
                      isStarred: _starred,
                      associatedChapters: assoc,
                    );
                    widget.onCreate(card);
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                child: const Text('创建卡片'),
              )),
            ),
          ]),
        ),
      ),
    );
  }
}
