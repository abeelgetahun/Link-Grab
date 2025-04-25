import 'package:floor/floor.dart';

@entity
class Category {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  @ColumnInfo(name: 'created_at')
  final int createdAtMillis; // Store as milliseconds since epoch

  Category({this.id, required this.name, DateTime? createdAt})
    : this.createdAtMillis =
          (createdAt ?? DateTime.now()).millisecondsSinceEpoch;

  // Convenience getter to convert milliseconds to DateTime
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
}
