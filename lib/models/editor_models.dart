/// ── Editor Data Models ──

enum EditorMode { body, drama } // 正文 / 剧作
enum RightPanelMode { outline, card, graph } // 大纲 / 卡片 / 图谱

/// A chapter within a volume.
class Chapter {
  final String id;
  final String title;
  final String body;
  final int wordCount;
  final int order;

  const Chapter({
    required this.id,
    required this.title,
    this.body = '',
    this.wordCount = 0,
    required this.order,
  });

  Chapter copyWith({String? title, String? body, int? wordCount}) =>
      Chapter(id: id, title: title ?? this.title, body: body ?? this.body,
          wordCount: wordCount ?? this.wordCount, order: order);
}

/// A volume containing chapters.
class Volume {
  final String id;
  final String title;
  final List<Chapter> chapters;
  final int order;
  bool isExpanded;

  Volume({
    required this.id,
    required this.title,
    this.chapters = const [],
    required this.order,
    this.isExpanded = false,
  });

  int get totalWords => chapters.fold(0, (s, c) => s + c.wordCount);
}

/// A book project.
class EditorBook {
  final String id;
  final String title;
  final List<Volume> volumes;
  final EditorMode mode;
  final int totalWordCount;
  final String outlinePreview;

  const EditorBook({
    required this.id,
    required this.title,
    this.volumes = const [],
    this.mode = EditorMode.body,
    this.totalWordCount = 0,
    this.outlinePreview = '',
  });
}
