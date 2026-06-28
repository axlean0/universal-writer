import '../models/editor_models.dart';

/// Currently loaded project. Pages read from here, never maintain copies.
class EditorRepository {
  EditorRepository._();
  static final i = EditorRepository._();

  EditorBook? _current;

  EditorBook get current {
    _current ??= _mock();
    return _current!;
  }

  /// Load a project by ID (mock for now).
  void load(String bookId) {
    _current = _mock();
  }

  Chapter? chapterById(String id) {
    for (final v in current.volumes) {
      for (final c in v.chapters) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  // ── Mock data ──
  EditorBook _mock() {
    return EditorBook(
      id: '1',
      title: '创作一号',
      totalWordCount: 12450,
      outlinePreview: '''
作品总纲
├── 世界背景：异世界奇幻大陆，魔法与科技共存
├── 主线剧情：主角觉醒 → 踏上旅程 → 战胜黑暗
├── 关键角色：主角、导师、反派、同伴
└── 结局方向：胜利但付出代价''',
      volumes: [
        Volume(id: 'v1', title: '第一卷', order: 0, isExpanded: true, chapters: [
          Chapter(id: 'c1', title: '第一章 相遇', order: 0, wordCount: 2450,
            body: '在北境的寒风中，她第一次见到了那个改变她命运的人。\n\n远处的雪山在晨曦中泛着银白色的光芒，她的马在积雪中跋涉了三天，终于望见了前方那座孤零零的驿站。\n\n推开厚重的木门，温暖的炉火气息扑面而来。驿站的角落里，一个戴着兜帽的身影正安静地翻阅着一本泛黄的书卷。\n\n"请问，去往霜语城的路..."'),
          Chapter(id: 'c2', title: '第二章 启程', order: 1, wordCount: 1800,
            body: '黎明时分，他们收拾行装，踏上了通往霜语城的古道。\n\n山间雾气弥漫，古老的松树被冰霜装点得如同水晶雕塑。沿途的石碑上刻满了早已失传的文字，记录着千年前那场改变世界的大战。'),
          Chapter(id: 'c3', title: '第三章 考验', order: 2, wordCount: 3200,
            body: '古道的尽头，一座废墟横亘在前。\n\n"这是远古守卫的试炼之地，只有通过考验的人才能继续前行。"兜帽人终于开口，声音低沉而悠远。\n\n她握紧了腰间的那把祖传的短刀，深吸一口气，迈入了废墟的阴影之中。'),
        ]),
        Volume(id: 'v2', title: '第二卷', order: 1, chapters: [
          Chapter(id: 'c4', title: '第四章 暗流', order: 0, wordCount: 1500,
            body: '霜语城并不像传说中那样宁静祥和。\n\n城中的暗巷里流传着关于黑暗势力的窃窃私语——一种古老的邪恶正在苏醒，而城内的高层却对此视而不见。'),
        ]),
      ],
    );
  }
}
