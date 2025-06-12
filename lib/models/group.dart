part 'group.g.dart';

@HiveType(typeId: 1)
class Group {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int color;

  Group({
    required this.name,
    required this.color,
  });
}
