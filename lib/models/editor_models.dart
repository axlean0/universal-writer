/// ── Editor Data Models ──

enum EditorMode { body, drama } // 正文 / 剧作
enum RightPanelMode { outline, card, graph } // 大纲 / 卡片 / 图谱

/// A chapter within a volume.
class Chapter {
  final String id;
  String title;
  String body;          // 正文内容
  String dramaOutline;  // 剧作章纲
  int wordCount;
  final int order;

  Chapter({
    required this.id,
    required this.title,
    this.body = '',
    this.dramaOutline = '',
    this.wordCount = 0,
    required this.order,
  });
}

/// A volume containing chapters.
class Volume {
  final String id;
  String title;
  final List<Chapter> chapters;
  String dramaOutline;  // 剧作卷纲
  final int order;

  Volume({
    required this.id,
    required this.title,
    this.chapters = const [],
    this.dramaOutline = '',
    required this.order,
  });
}

/// A book project.
class EditorBook {
  final String id;
  final String title;
  final List<Volume> volumes;
  String outlinePreview;  // 正文大纲预览（保留兼容）
  String dramaOutline;    // 剧作总纲

  EditorBook({
    required this.id,
    required this.title,
    this.volumes = const [],
    this.outlinePreview = '',
    this.dramaOutline = '',
  });
}
