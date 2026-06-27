import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';

/// A vertical book card for the grid view (multi-column / grouped).
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.batchMode = false,
    this.selected = false,
    this.onSelectToggle,
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
        onLongPress: onLongPress,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildCover(aspectRatio: 2 / 3),
              if (batchMode)
                Positioned(top: 12, left: 12, child: _buildCheckbox()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.stackMd, left: 4, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatWordCount(book.wordCount)} WORDS',
                  style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildCover({required double aspectRatio}) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildDefaultCover(),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: book.type == BookType.book
          ? AppColors.primaryContainer.withAlpha(40)
          : AppColors.tertiaryContainer.withAlpha(40),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                book.type == BookType.book ? Icons.book : Icons.article,
                size: 48,
                color: AppColors.primary.withAlpha(80),
              ),
              const SizedBox(height: 16),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Source Serif 4',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 30 / 18,
                  color: AppColors.primary.withAlpha(180),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (book.wordCount % 20000) / 20000 + 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outline,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )
          : null,
    );
  }

  String _formatWordCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}万';
    if (count >= 1000) return '${count ~/ 1000},${count % 1000}';
    return count.toString();
  }
}

/// Horizontal book card for single-column list view.
/// Shows cover on the left, info on the right.
class BookCardHorizontal extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool batchMode;
  final bool selected;
  final VoidCallback? onSelectToggle;

  const BookCardHorizontal({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.batchMode = false,
    this.selected = false,
    this.onSelectToggle,
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
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            // Cover (small)
            SizedBox(
              width: 80,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  color: book.type == BookType.book
                      ? AppColors.primaryContainer.withAlpha(40)
                      : AppColors.tertiaryContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Icon(
                    book.type == BookType.book ? Icons.book : Icons.article,
                    size: 32,
                    color: AppColors.primary.withAlpha(80),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.onSurface,
                    ),
                  ),
                  if (book.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.text_fields, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            '${_fmtCount(book.wordCount)} 字',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.outline),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.folder_open, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            book.group,
                            style: const TextStyle(fontSize: 12, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Batch checkbox
            if (batchMode)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _buildCheckbox(),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outline,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
            )
          : null,
    );
  }

  String _fmtCount(int c) {
    if (c >= 10000) return '${(c / 10000).toStringAsFixed(1)}万';
    return c.toString();
  }
}

/// The "Create New Work" special card (vertical, for grid).
class CreateNewBookCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateNewBookCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.outlineVariant, width: 2, strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHighest,
                      ),
                      child: const Icon(Icons.add, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text('创建新的作品',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Create New Work" row for single-column view.
class CreateNewBookRow extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateNewBookRow({super.key, this.onTap});

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHighest,
              ),
              child: const Icon(Icons.add, size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            const Text('创建新的作品',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
