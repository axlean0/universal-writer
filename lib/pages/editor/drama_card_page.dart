import 'package:flutter/material.dart';
import '../../models/drama_card_model.dart';
import '../../data/card_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/editor/card_create_dialog.dart';

class DramaCardPage extends StatefulWidget {
  const DramaCardPage({super.key});

  @override
  State<DramaCardPage> createState() => _DramaCardPageState();
}

class _DramaCardPageState extends State<DramaCardPage> {
  final CardRepository _repo = CardRepository.i;
  bool _manageMode = false;
  final Set<String> _selectedIds = {};
  int _viewMode = 1; // 0=list, 1=medium(default), 2=compact
  CardType? _filterType;

  @override
  void initState() {
    super.initState();
    _repo.initMock();
  }

  void _toggleManage() => setState(() { _manageMode = !_manageMode; _selectedIds.clear(); });
  void _toggleSelect(String id) => setState(() {
    if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); }
  });
  void _toggleStar(DramaCard card) => setState(() => card.isStarred = !card.isStarred);

  List<DramaCard> get _filteredCards {
    var list = _repo.all;
    if (_filterType != null) list = list.where((c) => c.type == _filterType).toList();
    return list;
  }

  String get _filterLabel {
    if (_filterType != null) return _filterType!.label;
    // Show first volume name as default context
    return '全部卡片';
  }

  void _showCreateDialog() {
    showDialog(context: context, builder: (_) => CardCreateDialog(
      onCreate: (card) => setState(() => _repo.add(card)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Header ──
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.3)),
        ),
        child: Row(children: [
          const Text('剧作 / 卡片库', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_filterLabel, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              if (_filterType != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _filterType = null),
                  child: const Icon(Icons.close, size: 14, color: AppColors.outline),
                ),
              ],
            ]),
          ),
          const Spacer(),
          // View mode switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _viewBtn(Icons.view_agenda, 0),
              _viewBtn(Icons.grid_view, 1),
              _viewBtn(Icons.view_module, 2),
            ]),
          ),
        ]),
      ),
      // ── Card Grid ──
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _viewMode == 0 ? _buildListView() : _buildGridView(),
        ),
      ),
      // ── Batch Bar ──
      if (_manageMode)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.3)),
          ),
          child: Row(children: [
            Text('已选择 ${_selectedIds.length} 项', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(width: 16),
            const VerticalDivider(width: 1),
            _batchBtn(Icons.delete, '删除'),
            _batchBtn(Icons.star, '收藏'),
            _batchBtn(Icons.label, '标签'),
            _batchBtn(Icons.drive_file_move, '分组'),
            const Spacer(),
            FilledButton(onPressed: _toggleManage, style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ), child: const Text('完成管理', style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w700))),
          ]),
        ),
    ]);
  }

  Widget _viewBtn(IconData icon, int mode) {
    final sel = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          boxShadow: sel ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 1)] : null,
        ),
        child: Icon(icon, size: 20, color: sel ? AppColors.primary : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _batchBtn(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filteredCards.length,
      separatorBuilder: (_, i) => const Divider(height: 1, color: AppColors.outlineVariant),
      itemBuilder: (_, i) {
        final card = _filteredCards[i];
        return _cardRow(card);
      },
    );
  }

  Widget _cardRow(DramaCard card) {
    final sel = _selectedIds.contains(card.id);
    return InkWell(
      onTap: _manageMode ? () => _toggleSelect(card.id) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(children: [
          if (_manageMode) ...[
            Icon(sel ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
          ],
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(4)),
            child: Text(card.type.label, style: const TextStyle(fontSize: 11, color: AppColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            if (card.description.isNotEmpty)
              Text(card.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
          ])),
          if (card.tags.isNotEmpty)
            Row(children: card.tags.take(3).map((t) => Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
              child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
            )).toList()),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _toggleStar(card),
            child: Icon(card.isStarred ? Icons.star : Icons.star_border, size: 18,
                color: card.isStarred ? AppColors.secondary : AppColors.outline),
          ),
        ]),
      ),
    );
  }

  Widget _buildGridView() {
    final cards = _filteredCards;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
      itemCount: cards.length,
      itemBuilder: (_, i) => _cardTile(cards[i]),
    );
  }

  Widget _cardTile(DramaCard card) {
    final sel = _selectedIds.contains(card.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant, width: 0.3),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (_manageMode) ...[
              GestureDetector(
                onTap: () => _toggleSelect(card.id),
                child: Icon(sel ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
            ],
            _typeBadge(card.type),
            const Spacer(),
            GestureDetector(
              onTap: () => _toggleStar(card),
              child: Icon(card.isStarred ? Icons.star : Icons.star_border, size: 18,
                  color: card.isStarred ? AppColors.secondary : AppColors.outline),
            ),
          ]),
          const SizedBox(height: 12),
          Text(card.title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(card.description, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, height: 1.5, color: AppColors.onSurfaceVariant)),
          ),
          if (card.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 4, runSpacing: 4,
              children: card.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(999)),
                child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
              )).toList()),
          ],
          if (card.associatedChapters.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.2))),
              child: Row(children: [
                const Icon(Icons.menu_book, size: 14, color: AppColors.outline),
                const SizedBox(width: 6),
                Expanded(child: Text('关联：${card.associatedChapters.join('、')}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.outline))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _typeBadge(CardType type) {
    Color bg;
    switch (type) {
      case CardType.character:    bg = AppColors.primary.withAlpha(25); break;
      case CardType.worldSetting: bg = AppColors.secondary.withAlpha(25); break;
      case CardType.event:        bg = AppColors.errorContainer; break;
      case CardType.item:         bg = AppColors.tertiaryFixed; break;
      case CardType.location:
      case CardType.faction:
      default:                    bg = AppColors.surfaceContainerHigh; break;
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(type.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)));
  }

  // Public API for EditorShell
  void showCreateDialog() => _showCreateDialog();
  void toggleManage() => _toggleManage();
}
