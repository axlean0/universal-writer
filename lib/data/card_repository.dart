import '../models/drama_card_model.dart';

class CardRepository {
  CardRepository._();
  static final i = CardRepository._();

  final List<DramaCard> _cards = [];
  int _nextId = 200;

  List<DramaCard> get all => _cards;
  List<DramaCard> get starred => _cards.where((c) => c.isStarred).toList();

  List<DramaCard> byType(CardType type) => _cards.where((c) => c.type == type).toList();
  int countByType(CardType type) => byType(type).length;

  void add(DramaCard card) => _cards.add(card);
  void remove(String id) => _cards.removeWhere((c) => c.id == id);

  void initMock() {
    if (_cards.isNotEmpty) return;
    _cards.addAll([
      DramaCard(id: 'c201', title: '林风', type: CardType.character, description: '出身青云镇的平凡少年，身怀上古血脉', tags: ['主角', '剑修'], isStarred: true, associatedChapters: ['第一章', '第三章']),
      DramaCard(id: 'c202', title: '苍云大陆', type: CardType.worldSetting, description: '故事核心世界，分为九州四海', tags: ['核心世界', '地理'], associatedChapters: ['序章']),
      DramaCard(id: 'c203', title: '九幽冥石', type: CardType.item, description: '通往九幽之地的钥匙，蕴含灵魂力量', tags: ['神器', '关键道具'], associatedChapters: ['第十二章']),
      DramaCard(id: 'c204', title: '青云镇之变', type: CardType.event, description: '神秘黑衣人夜袭青云镇', tags: ['转折点', '第一卷'], associatedChapters: ['第二章']),
      DramaCard(id: 'c205', title: '北境驿站', type: CardType.location, description: '北境古道上的孤零零驿站', tags: ['关键地点'], associatedChapters: ['第一章']),
      DramaCard(id: 'c206', title: '霜语城密会', type: CardType.faction, description: '霜语城暗中的反抗势力', tags: ['地下组织'], associatedChapters: ['第四章']),
    ]);
  }
}
