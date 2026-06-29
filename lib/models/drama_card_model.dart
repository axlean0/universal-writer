enum CardType { character, location, faction, item, event, worldSetting, custom }

extension CardTypeX on CardType {
  String get label {
    switch (this) {
      case CardType.character:    return '角色';
      case CardType.location:     return '地点';
      case CardType.faction:      return '势力';
      case CardType.item:         return '道具';
      case CardType.event:        return '事件';
      case CardType.worldSetting: return '设定';
      case CardType.custom:       return '自定义';
    }
  }
}

class DramaCard {
  final String id;
  String title;
  String description;
  CardType type;
  List<String> tags;
  bool isStarred;
  List<String> associatedChapters; // chapter names for V1
  String? volumeId;

  DramaCard({
    required this.id,
    required this.title,
    this.description = '',
    this.type = CardType.character,
    this.tags = const [],
    this.isStarred = false,
    this.associatedChapters = const [],
    this.volumeId,
  });
}
