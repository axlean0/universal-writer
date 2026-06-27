/// Represents a creative work in the writer's bookshelf.
class Book {
  final String id;
  final String title;
  final String description;
  final BookType type;
  final String? coverImageUrl;
  final int wordCount;
  final String group;
  final DateTime createdAt;
  final DateTime lastEditedAt;
  final DateTime? deletedAt;

  const Book({
    required this.id,
    required this.title,
    this.description = '',
    this.type = BookType.book,
    this.coverImageUrl,
    this.wordCount = 0,
    this.group = '未分类',
    required this.createdAt,
    required this.lastEditedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Book copyWith({
    String? id,
    String? title,
    String? description,
    BookType? type,
    String? coverImageUrl,
    int? wordCount,
    String? group,
    DateTime? createdAt,
    DateTime? lastEditedAt,
    DateTime? deletedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      wordCount: wordCount ?? this.wordCount,
      group: group ?? this.group,
      createdAt: createdAt ?? this.createdAt,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      deletedAt: deletedAt,
    );
  }
}

enum BookType { book, article }

/// Represents a deleted item in the recycle bin.
class TrashItem {
  final Book book;
  final DateTime deletedAt;
  final int retentionDays;

  const TrashItem({
    required this.book,
    required this.deletedAt,
    this.retentionDays = 30,
  });

  int get daysUntilCleanup =>
      retentionDays - DateTime.now().difference(deletedAt).inDays;
}

/// Sorting options for the bookshelf.
enum SortMode {
  nameAsc,
  nameDesc,
  lastEdited,
  wordCount,
}

/// View layout modes for the bookshelf.
enum ViewMode {
  single,
  multi,
  grouped,
}

/// Search filter types.
enum SearchType {
  all,
  work,
  chapter,
  outline,
  card,
  graph,
}

extension SearchTypeLabel on SearchType {
  String get label {
    switch (this) {
      case SearchType.all:
        return '全部';
      case SearchType.work:
        return '作品';
      case SearchType.chapter:
        return '正文';
      case SearchType.outline:
        return '大纲';
      case SearchType.card:
        return '卡片';
      case SearchType.graph:
        return '图谱';
    }
  }
}
