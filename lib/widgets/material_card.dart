import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter/gestures.dart';
import '../theme/app_theme.dart';
import '../models/material_item.dart';

/// ─── Grid card for multi-column view ───
class MaterialGridCard extends StatefulWidget {
  final MaterialItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const MaterialGridCard({
    super.key,
    required this.item,
    this.onTap, this.onDoubleTap, this.onLongPress,
    this.batchMode = false, this.selected = false, this.onSelectToggle,
  });

  @override
  State<MaterialGridCard> createState() => _MaterialGridCardState();
}

class _MaterialGridCardState extends State<MaterialGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (e) {
          if (e.buttons == kSecondaryMouseButton) widget.onLongPress?.call();
        },
        child: GestureDetector(
          onTap: widget.batchMode ? widget.onSelectToggle : widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onLongPress: widget.onLongPress,
          child: Column(children: [
            Stack(children: [
              Container(
                height: 180,
                alignment: Alignment.center,
                child: AnimatedScale(
                  scale: _hovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _iconForType(widget.item.type),
                    size: 180,
                    color: _hovered ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              if (widget.batchMode)
                Positioned(top: 12, left: 26, child: _buildCheckbox()),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Column(children: [
                Text(widget.item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(widget.item.type.label,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 12,
                      fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: widget.selected ? AppColors.primary : AppColors.outline, width: 2),
      ),
      child: widget.selected ? Center(
        child: Container(width: 12, height: 12,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      ) : null,
    );
  }
}

IconData _iconForType(MaterialType t) {
  switch (t) {
    case MaterialType.document: return Icons.description;
    case MaterialType.pdf:      return Icons.picture_as_pdf;
    case MaterialType.image:    return Icons.image;
    case MaterialType.video:    return Icons.videocam;
    case MaterialType.audio:    return Icons.audiotrack;
    case MaterialType.other:    return Icons.insert_drive_file;
  }
}

/// ─── List row for single-column view ───
class MaterialListRow extends StatelessWidget {
  final MaterialItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const MaterialListRow({
    super.key,
    required this.item,
    this.onTap, this.onDoubleTap, this.onLongPress,
    this.batchMode = false, this.selected = false, this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        if (e.buttons == kSecondaryMouseButton) onLongPress?.call();
      },
      child: GestureDetector(
        onTap: batchMode ? onSelectToggle : onTap,
        onDoubleTap: onDoubleTap, onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(children: [
            Icon(_iconForType(item.type), size: 32, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15,
                    fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                if (item.description.isNotEmpty)
                  Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
              ]),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 80,
              child: Text(item.type.label,
                style: const TextStyle(fontSize: 12, color: AppColors.outline), textAlign: TextAlign.center),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 90,
              child: Text(formatMaterialSize(item.size),
                style: const TextStyle(fontSize: 12, color: AppColors.outline), textAlign: TextAlign.right),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 110,
              child: Text(formatMaterialTime(item.uploadedAt),
                style: const TextStyle(fontSize: 12, color: AppColors.outline), textAlign: TextAlign.right),
            ),
            if (batchMode) ...[const SizedBox(width: 8), _buildCheckbox()],
          ]),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: 2),
      ),
      child: selected ? Center(
        child: Container(width: 12, height: 12,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      ) : null,
    );
  }
}

/// ─── Group card for grouped view ───
class MaterialGroupCard extends StatelessWidget {
  final String groupName;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MaterialGroupCard({
    super.key,
    required this.groupName,
    required this.count,
    this.onTap, this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        if (e.buttons == kSecondaryMouseButton) onLongPress?.call();
      },
      child: GestureDetector(
        onTap: onTap, onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.inventory_2, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(groupName, style: const TextStyle(fontFamily: 'Manrope', fontSize: 16,
                    fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text('$count 个素材', style: const TextStyle(fontSize: 13, color: AppColors.outline)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ]),
        ),
      ),
    );
  }
}

/// ─── Type section header for type-based view ───
class MaterialTypeSection extends StatelessWidget {
  final MaterialType materialType;
  final List<MaterialItem> items;
  final Function(MaterialItem) onItemTap;
  final Function(MaterialItem) onItemLongPress;

  const MaterialTypeSection({
    super.key,
    required this.materialType,
    required this.items,
    required this.onItemTap,
    required this.onItemLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(_iconForType(materialType), size: 24, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(materialType.label,
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 20,
              fontWeight: FontWeight.w600, color: AppColors.onBackground)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text('${items.length}', style: const TextStyle(fontSize: 12, color: AppColors.outline)),
        ),
      ]),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: MaterialListRow(
          item: item,
          onTap: () => onItemTap(item),
          onDoubleTap: () => onItemTap(item),
          onLongPress: () => onItemLongPress(item),
        ),
      )),
      const SizedBox(height: 24),
    ]);
  }
}

/// ─── Upload new material card ───
class UploadNewMaterialGridCard extends StatelessWidget {
  final VoidCallback? onTap;
  const UploadNewMaterialGridCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          height: 180, alignment: Alignment.center,
          child: const Icon(Icons.note_add, size: 180, color: AppColors.outline),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Column(children: [
            const Text('新素材', style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(height: 4),
            const Text('NEW', style: TextStyle(fontFamily: 'Manrope', fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
          ]),
        ),
      ]),
    );
  }
}

class UploadNewMaterialListRow extends StatelessWidget {
  final VoidCallback? onTap;
  const UploadNewMaterialListRow({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant, width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerHighest),
            child: const Icon(Icons.add, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          const Text('新素材',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 18,
                fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ]),
      ),
    );
  }
}
