import '../database/database.dart';
import '../models/link.dart';

class LinkRepository {
  final AppDatabase _database;

  LinkRepository(this._database);

  Future<List<Link>> getAllLinks() async {
    return await _database.linkDao.findAllLinks();
  }

  Future<List<Link>> getLinksByCategoryId(int categoryId) async {
    return await _database.linkDao.findLinksByCategoryId(categoryId);
  }

  Future<Link?> getLinkById(int id) async {
    return await _database.linkDao.findLinkById(id);
  }

  Future<List<Link>> searchLinks(String query) async {
    // Add wildcards for SQL LIKE operator
    String wildcardQuery = '%$query%';
    return await _database.linkDao.searchLinks(wildcardQuery);
  }

  Future<int> insertLink(Link link) async {
    return await _database.linkDao.insertLink(link);
  }

  Future<int> updateLink(Link link) async {
    return await _database.linkDao.updateLink(link);
  }

  Future<int> deleteLink(Link link) async {
    return await _database.linkDao.deleteLink(link);
  }
}
