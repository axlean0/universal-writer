enum MaterialType { document, pdf, image, video, audio, other }

/// Represents a material/asset in the materials library.
class MaterialItem {
  final String id;
  final String name;
  final MaterialType type;
  final String group;
  final int size; // bytes
  final DateTime uploadedAt;
  final DateTime lastOpenedAt;
  final DateTime? deletedAt;
  final String description;

  const MaterialItem({
    required this.id,
    required this.name,
    this.type = MaterialType.document,
    this.group = '未分类',
    this.size = 0,
    required this.uploadedAt,
    required this.lastOpenedAt,
    this.deletedAt,
    this.description = '',
  });

  bool get isDeleted => deletedAt != null;

  MaterialItem copyWith({
    String? id, String? name, MaterialType? type, String? group,
    int? size, DateTime? uploadedAt, DateTime? lastOpenedAt,
    DateTime? deletedAt, String? description,
  }) {
    return MaterialItem(
      id: id ?? this.id, name: name ?? this.name,
      type: type ?? this.type, group: group ?? this.group,
      size: size ?? this.size, uploadedAt: uploadedAt ?? this.uploadedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      deletedAt: deletedAt, description: description ?? this.description,
    );
  }
}

extension MaterialTypeX on MaterialType {
  String get label {
    switch (this) {
      case MaterialType.document: return '文档';
      case MaterialType.pdf:      return 'PDF';
      case MaterialType.image:    return '图片';
      case MaterialType.video:    return '视频';
      case MaterialType.audio:    return '音频';
      case MaterialType.other:    return '其他';
    }
  }

  String get iconName {
    switch (this) {
      case MaterialType.document: return 'description';
      case MaterialType.pdf:      return 'picture_as_pdf';
      case MaterialType.image:    return 'image';
      case MaterialType.video:    return 'videocam';
      case MaterialType.audio:    return 'audiotrack';
      case MaterialType.other:    return 'insert_drive_file';
    }
  }

  /// Fixed system categories for the type-based view
  static const List<MaterialType> systemCategories = [
    MaterialType.document, MaterialType.pdf, MaterialType.image, MaterialType.other,
  ];
}

String formatMaterialSize(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '$bytes B';
}

String formatMaterialTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
  if (diff.inDays < 1) return '今天 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  if (diff.inDays == 1) return '昨天';
  return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
