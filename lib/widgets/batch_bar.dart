import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Floating bottom bar for batch operations.
class BatchActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onGroupAction;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  const BatchActionBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onGroupAction,
    required this.onExport,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '$selectedCount 个项目已选择',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  '取消批量',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildAction(Icons.drive_file_move, '分组', onGroupAction),
              const SizedBox(width: 8),
              _buildAction(Icons.download, '导出', onExport),
              const SizedBox(width: 8),
              _buildAction(Icons.delete, '删除', onDelete, isDanger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap,
      {bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? AppColors.error : Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
