part 'link.g.dart';

@HiveType(typeId: 0)
class Link {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String? title;

  @HiveField(3)
  final String? group;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final DateTime createdAt;

  // imageUrl is removed as per the instructions (it was not mentioned to keep it)
  // sourceApp is removed as per the instructions
  // categoryId is removed as per the instructions

  Link({
    required this.id,
    required this.url,
    this.title,
    this.group,
    this.description,
    this.isFavorite = false,
    required this.createdAt,
  });
}
