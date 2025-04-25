import 'package:floor/floor.dart';

@entity
class Link {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? sourceApp;
  final int categoryId;

  @ColumnInfo(name: 'created_at')
  final int createdAtMillis; // Store as milliseconds since epoch

  Link({
    this.id,
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.sourceApp,
    required this.categoryId,
    DateTime? createdAt,
  }) : this.createdAtMillis =
           (createdAt ?? DateTime.now()).millisecondsSinceEpoch;

  // Convenience getter to convert milliseconds to DateTime
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
}
