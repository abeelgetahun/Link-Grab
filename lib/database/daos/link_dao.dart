import 'package:floor/floor.dart';
import '../../models/link.dart';

@dao
abstract class LinkDao {
  @Query('SELECT * FROM Link ORDER BY created_at DESC')
  Future<List<Link>> findAllLinks();

  @Query(
    'SELECT * FROM Link WHERE categoryId = :categoryId ORDER BY created_at DESC',
  )
  Future<List<Link>> findLinksByCategoryId(int categoryId);

  @Query('SELECT * FROM Link WHERE id = :id')
  Future<Link?> findLinkById(int id);

  @Query(
    'SELECT * FROM Link WHERE url LIKE :query OR title LIKE :query OR description LIKE :query ORDER BY created_at DESC',
  )
  Future<List<Link>> searchLinks(String query);

  @insert
  Future<int> insertLink(Link link);

  @update
  Future<int> updateLink(Link link);

  @delete
  Future<int> deleteLink(Link link);
}
