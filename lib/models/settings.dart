part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings {
  @HiveField(0)
  final bool darkMode;

  Settings({
    this.darkMode = false,
  });
}
