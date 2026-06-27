import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fixed left sidebar with user info, navigation, and footer.
class AppSidebar extends StatefulWidget {
  final String currentRoute;
  final VoidCallback? onNavigateToWriting;
  final VoidCallback? onNavigateToFiles;
  final VoidCallback? onNavigateToMaterials;
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToSettings;

  const AppSidebar({
    super.key,
    this.currentRoute = 'writing',
    this.onNavigateToWriting,
    this.onNavigateToFiles,
    this.onNavigateToMaterials,
    this.onNavigateToStats,
    this.onNavigateToSettings,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final GlobalKey _profileKey = GlobalKey();

  void _showUserMenu() {
    final RenderBox renderBox =
        _profileKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 4,
      ),
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      items: [
        _buildUserMenuItem(Icons.person, '查看个人信息'),
        _buildUserMenuItem(Icons.edit, '修改头像'),
        _buildUserMenuItem(Icons.badge, '修改昵称'),
        _buildUserMenuItem(Icons.settings, '账户设置'),
        const PopupMenuDivider(),
        _buildUserMenuItem(Icons.logout, '退出登录'),
      ],
    );
  }

  PopupMenuItem<String> _buildUserMenuItem(IconData icon, String label) {
    return PopupMenuItem<String>(
      value: label,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.safePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfile(),
            const SizedBox(height: 40),
            Expanded(child: _buildNavMenu()),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.stackSm),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return GestureDetector(
      key: _profileKey,
      onTap: _showUserMenu,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 28),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Text('用户XX',
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w600,
                  height: 32 / 24, color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavMenu() {
    final items = [
      _NavItem('writing', '写作', Icons.edit, widget.onNavigateToWriting),
      _NavItem('files', '文件', Icons.folder, widget.onNavigateToFiles),
      _NavItem('materials', '素材', Icons.inventory_2, widget.onNavigateToMaterials),
      _NavItem('stats', '统计', Icons.insights, widget.onNavigateToStats),
      _NavItem('settings', '设置', Icons.settings, widget.onNavigateToSettings),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map(_buildNavItem).toList(),
    );
  }

  Widget _buildNavItem(_NavItem item) {
    final isActive = item.route == widget.currentRoute;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? AppColors.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: isActive ? null : item.onTap,
          splashColor: AppColors.surfaceContainerHighest,
          highlightColor: AppColors.surfaceContainerLow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: isActive
                  ? const Border(left: BorderSide(color: AppColors.secondary, width: 4))
                  : null,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 22,
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.stackMd),
                Text(item.label,
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: null,
        splashColor: AppColors.surfaceContainerHigh,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.cloud_upload, size: 22, color: AppColors.onSurfaceVariant),
              SizedBox(width: AppSpacing.stackMd),
              Text('上传云端',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  _NavItem(this.route, this.label, this.icon, this.onTap);
}
