import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/bookshelf_page.dart';
import 'pages/files_page.dart';
import 'pages/materials_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const UniversalWriterApp());
}

class UniversalWriterApp extends StatefulWidget {
  const UniversalWriterApp({super.key});

  @override
  State<UniversalWriterApp> createState() => _UniversalWriterAppState();
}

class _UniversalWriterAppState extends State<UniversalWriterApp> {
  String _currentPage = 'writing';

  void _navigateTo(String page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Writer — 通用写作',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case 'writing':
        return BookshelfPage(
          onNavigateToFiles: () => _navigateTo('files'),
          onNavigateToMaterials: () => _navigateTo('materials'),
          onNavigateToStats: () => _navigateTo('stats'),
          onNavigateToSettings: () => _navigateTo('settings'),
        );
      case 'files':
        return FilesPage(
          onNavigateToWriting: () => _navigateTo('writing'),
          onNavigateToMaterials: () => _navigateTo('materials'),
          onNavigateToStats: () => _navigateTo('stats'),
          onNavigateToSettings: () => _navigateTo('settings'),
        );
      case 'materials':
        return MaterialsPage(
          onNavigateToWriting: () => _navigateTo('writing'),
          onNavigateToFiles: () => _navigateTo('files'),
          onNavigateToStats: () => _navigateTo('stats'),
          onNavigateToSettings: () => _navigateTo('settings'),
        );
      case 'stats':
        return StatsPage(
          onNavigateToWriting: () => _navigateTo('writing'),
          onNavigateToFiles: () => _navigateTo('files'),
          onNavigateToMaterials: () => _navigateTo('materials'),
          onNavigateToSettings: () => _navigateTo('settings'),
        );
      case 'settings':
        return SettingsPage(
          onNavigateToWriting: () => _navigateTo('writing'),
          onNavigateToFiles: () => _navigateTo('files'),
          onNavigateToMaterials: () => _navigateTo('materials'),
          onNavigateToStats: () => _navigateTo('stats'),
        );
      default:
        return const Scaffold(
          body: Center(child: Text('页面开发中...', style: TextStyle(fontFamily: 'Manrope', fontSize: 18))),
        );
    }
  }
}
