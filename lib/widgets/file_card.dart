import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_theme.dart';
import '../models/file_item.dart';

/// ─── Folder/File card for grid (multi-column) view ───
class FileGridCard extends StatefulWidget {
  final FileItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const FileGridCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.batchMode = false,
    this.selected = false,
    this.onSelectToggle,
  });

  @override
  State<FileGridCard> createState() => _FileGridCardState();
}

class _FileGridCardState extends State<FileGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (e) {
          if (e.buttons == kSecondaryMouseButton) {
            widget.onLongPress?.call();
          }
        },
        child: GestureDetector(
          onTap: widget.batchMode ? widget.onSelectToggle : widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onLongPress: widget.onLongPress,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: _hovered ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      widget.item.isFolder ? Icons.folder : Icons.description,
                      size: 180,
                      color: _hovered ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
                if (widget.batchMode)
                  Positioned(top: 12, left: 26, child: _buildCheckbox()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Column(
                children: [
                  Text(widget.item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 15,
                        fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.item.isFolder ? '${widget.item.childCount} FILES' : formatFileSize(widget.item.size),
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 12,
                        fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
      ) : null,
    );
  }
}

/// ─── File row for single-column list view ───
class FileListRow extends StatelessWidget {
  final FileItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const FileListRow({
    super.key,
    required this.item,
    this.onTap, this.onDoubleTap, this.onLongPress,
    this.batchMode = false, this.selected = false, this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        if (e.buttons == kSecondaryMouseButton) {
          onLongPress?.call();
        }
      },
      child: GestureDetector(
        onTap: batchMode ? onSelectToggle : onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(children: [
          Icon(_iconForType(), size: 32, color: AppColors.primary),
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
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Text(_formatTime(item.lastModifiedAt),
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(item.isFolder ? '${item.childCount} 项' : formatFileSize(item.size),
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
              textAlign: TextAlign.right,
            ),
          ),
          if (batchMode) ...[const SizedBox(width: 8), _buildCheckbox()],
        ]),
      ),
    ),
  );
  }

  IconData _iconForType() => item.isFolder ? Icons.folder : Icons.description;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '今天 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return '昨天';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
      ) : null,
    );
  }
}

/// ─── Tree node for grouped/expandable folder view ───
class FileTreeNode extends StatefulWidget {
  final FileItem item;
  final int depth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const FileTreeNode({
    super.key,
    required this.item,
    this.depth = 0,
    this.onTap, this.onLongPress,
    this.batchMode = false, this.selected = false, this.onSelectToggle,
  });

  @override
  State<FileTreeNode> createState() => _FileTreeNodeState();
}

class _FileTreeNodeState extends State<FileTreeNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.item.children.isNotEmpty && widget.item.isFolder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Listener(
          onPointerDown: (e) {
            if (e.buttons == kSecondaryMouseButton) {
              widget.onLongPress?.call();
            }
          },
          child: GestureDetector(
            onTap: () {
              if (hasChildren) {
                setState(() => _expanded = !_expanded);
              } else {
                widget.onTap?.call();
              }
            },
            onLongPress: widget.onLongPress,
            child: Container(
            padding: EdgeInsets.only(left: 8.0 + widget.depth * 24, right: 8, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.normal),
              border: Border.all(color: AppColors.outlineVariant.withAlpha(100)),
            ),
            child: Row(children: [
              if (hasChildren)
                Icon(_expanded ? Icons.expand_more : Icons.chevron_right, size: 20, color: AppColors.outline)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              Icon(_iconForType(), size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.item.name,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
              ),
              const SizedBox(width: 16),
              Text(widget.item.isFolder ? '${widget.item.childCount} 项' : formatFileSize(widget.item.size),
                style: const TextStyle(fontSize: 12, color: AppColors.outline),
              ),
              if (widget.batchMode) ...[const SizedBox(width: 8), _buildCheckbox()],
            ]),
          ),
        ),
      ),
        if (_expanded && hasChildren)
          ...widget.item.children.map((child) => FileTreeNode(
            item: child,
            depth: widget.depth + 1,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            batchMode: widget.batchMode,
            selected: widget.selected,
            onSelectToggle: widget.onSelectToggle,
          )),
      ],
    );
  }

  IconData _iconForType() => widget.item.isFolder ? Icons.folder : Icons.description;

  Widget _buildCheckbox() {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: widget.selected ? AppColors.primary : AppColors.outline, width: 2),
      ),
      child: widget.selected ? Center(
        child: Container(width: 12, height: 12,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
      ) : null,
    );
  }
}

/// ─── "Create New" cards ───
class CreateNewFileGridCard extends StatelessWidget {
  final VoidCallback? onTap;
  const CreateNewFileGridCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          height: 180,
          alignment: Alignment.center,
          child: const Icon(Icons.create_new_folder, size: 180, color: AppColors.outline),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Column(children: [
            const Text('新建文件',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                  fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            const Text('NEW',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline),
            ),
          ]),
        ),
      ]),
    );
  }
}

class CreateNewFileListRow extends StatelessWidget {
  final VoidCallback? onTap;
  const CreateNewFileListRow({super.key, this.onTap});

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
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.surfaceContainerHighest,
            ),
            child: const Icon(Icons.add, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          const Text('新建文件',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 18,
                fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ]),
      ),
    );
  }
}
