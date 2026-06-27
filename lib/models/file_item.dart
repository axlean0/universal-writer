/// Represents a file or folder in the file manager.
enum FileType { folder, text, book }

class FileItem {
  final String id;
  final String name;
  final FileType type;
  final String? parentId;
  final int size; // bytes
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final DateTime? deletedAt;
  final String description;
  final List<FileItem> children;

  const FileItem({
    required this.id,
    required this.name,
    this.type = FileType.folder,
    this.parentId,
    this.size = 0,
    required this.createdAt,
    required this.lastModifiedAt,
    this.deletedAt,
    this.description = '',
    this.children = const [],
  });

  bool get isDeleted => deletedAt != null;
  bool get isFolder => type == FileType.folder || type == FileType.book;
  int get childCount => children.isEmpty ? 0 : children.length;

  FileItem copyWith({
    String? id, String? name, FileType? type, String? parentId,
    int? size, DateTime? createdAt, DateTime? lastModifiedAt,
    DateTime? deletedAt, String? description, List<FileItem>? children,
  }) {
    return FileItem(
      id: id ?? this.id, name: name ?? this.name,
      type: type ?? this.type, parentId: parentId ?? this.parentId,
      size: size ?? this.size, createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      deletedAt: deletedAt, description: description ?? this.description,
      children: children ?? this.children,
    );
  }
}

String formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '$bytes B';
}
