import 'package:flutter/material.dart';
import '../../models/editor_models.dart';
import '../../data/editor_repository.dart';
import '../../theme/app_theme.dart';

class ChapterTree extends StatefulWidget {
  final String? activeChapterId;
  final ValueChanged<Chapter> onSelectChapter;
  final VoidCallback onBack;

  const ChapterTree({
    super.key,
    this.activeChapterId,
    required this.onSelectChapter,
    required this.onBack,
  });

  @override
  State<ChapterTree> createState() => _ChapterTreeState();
}

class _ChapterTreeState extends State<ChapterTree> {
  EditorMode _mode = EditorMode.body;
  // Internal expanded state — does not mutate the data model
  final Set<String> _expandedVolumeIds = {};

  @override
  Widget build(BuildContext context) {
    final book = EditorRepository.i.current;
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.surface,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            InkWell(
              onTap: widget.onBack, borderRadius: BorderRadius.circular(999),
              child: const Padding(padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back, size: 24, color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 20,
                  fontWeight: FontWeight.w700, color: AppColors.onSurface))),
          ]),
        ),
        const SizedBox(height: 20),
        // 正文/剧作 switcher
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
          child: SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () {},
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
      onTap: () => setState(() => _mode = mode),
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
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() {
              if (expanded) { _expandedVolumeIds.remove(v.id); } else { _expandedVolumeIds.add(v.id); }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Icon(expanded ? Icons.expand_more : Icons.chevron_right, size: 20, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(child: Text(v.title, style: const TextStyle(fontFamily: 'Manrope',
                    fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface))),
                InkWell(onTap: () {}, borderRadius: BorderRadius.circular(4),
                  child: const Padding(padding: EdgeInsets.all(2),
                    child: Icon(Icons.more_vert, size: 18, color: AppColors.outline))),
              ]),
            ),
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
                    InkWell(onTap: () {}, borderRadius: BorderRadius.circular(4),
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
