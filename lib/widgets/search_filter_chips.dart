import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable multi-select search filter chips.
///
/// Rules:
/// 1. "全部" is mutually exclusive with individual types — never both highlighted.
/// 2. Clicking "全部" deselects all individual types.
/// 3. Clicking any individual type when "全部" is highlighted → deselects "全部".
/// 4. Individual types freely multi-select.
/// 5. When ALL individual types are manually selected, "全部" stays unhighlighted
///    but the callback reports "all" (empty set = search everything).
class SearchFilterChips extends StatefulWidget {
  /// Labels for individual type chips (e.g. ['文档', 'PDF', '图片', '其他'])
  final List<String> labels;

  /// Count for each chip (e.g. {'文档': 12, 'PDF': 5})
  final Map<String, int> counts;

  /// Called when selection changes.
  /// If [isAll] is true, search all. Otherwise search only [selectedLabels].
  final ValueChanged<SearchFilterState> onChanged;

  const SearchFilterChips({
    super.key,
    required this.labels,
    required this.counts,
    required this.onChanged,
  });

  @override
  State<SearchFilterChips> createState() => _SearchFilterChipsState();
}

class SearchFilterState {
  final bool isAll;
  final Set<String> selectedLabels;
  const SearchFilterState({this.isAll = true, this.selectedLabels = const {}});
}

class _SearchFilterChipsState extends State<SearchFilterChips> {
  bool _allSelected = true;
  final Set<String> _selected = {};

  void _notify() {
    widget.onChanged(SearchFilterState(
      isAll: _allSelected || _selected.length == widget.labels.length,
      selectedLabels: Set.from(_selected),
    ));
  }

  void _tapAll() {
    setState(() {
      _allSelected = true;
      _selected.clear();
    });
    _notify();
  }

  void _tapLabel(String label) {
    setState(() {
      if (_allSelected) {
        // Rule 2: deselect "全部", select only this label
        _allSelected = false;
        _selected.clear();
        _selected.add(label);
      } else if (_selected.contains(label)) {
        // Toggle off
        _selected.remove(label);
        // Rule 5: if all deselected, treat as "all" without highlighting 全部
        if (_selected.isEmpty) {
          _allSelected = true;
          _selected.clear();
        }
      } else {
        _selected.add(label);
        // Rule 5: never auto-switch to _allSelected when all manual types selected
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      // "全部" chip — highlighted only when _allSelected is true (explicitly clicked)
      _buildChip('全部', 0, _allSelected, _tapAll),
      // Individual type chips
      ...widget.labels.asMap().entries.map((e) {
        final label = e.value;
        final count = widget.counts[label] ?? 0;
        return _buildChip(label, count, _selected.contains(label), () => _tapLabel(label));
      }),
    ]);
  }

  Widget _buildChip(String label, int count, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text.rich(TextSpan(children: [
          TextSpan(
            text: label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.onSurfaceVariant),
          ),
          if (count > 0)
            TextSpan(
              text: ' ($count)',
              style: TextStyle(fontSize: 12,
                  color: selected ? Colors.white70 : AppColors.outline),
            ),
        ])),
      ),
    );
  }
}
