import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:tb_vision/src/services/database/collection.dart';

class DatabaseService {
  final Databases databases;
  final Map<String, Collection> _collections = {};

  DatabaseService(Client client, List<Collection> collections)
      : databases = Databases(client) {
    // Initialize the collections map for easy access by name
    for (var collection in collections) {
      _collections[collection.name] = collection;
    }
  }

  Future<Document> createDocument(String collectionName, Map<String, dynamic> payload, {String? id}) async {
    final collection = _collections[collectionName]!;
    return await databases.createDocument(
      databaseId: collection.dbId,
      collectionId: collection.id,
      documentId: id ?? ID.unique(),
      data: payload,
    );
  }

  Future<Document> getDocument(String collectionName, String documentId) async {
    final collection = _collections[collectionName]!;
    return await databases.getDocument(
      databaseId: collection.dbId,
      collectionId: collection.id,
      documentId: documentId,
    );
  }

  Future<DocumentList> listDocuments(String collectionName, List<String> list, {List<String>? queries}) async {
    final collection = _collections[collectionName]!;
    return await databases.listDocuments(
      databaseId: collection.dbId,
      collectionId: collection.id,
      queries: queries,
    );
  }

  Future<Document> updateDocument(String collectionName, String documentId, Map<String, dynamic> payload) async {
    final collection = _collections[collectionName]!;
    return await databases.updateDocument(
      databaseId: collection.dbId,
      collectionId: collection.id,
      documentId: documentId,
      data: payload,
    );
  }

  Future<void> deleteDocument(String collectionName, String documentId) async {
    final collection = _collections[collectionName]!;
    await databases.deleteDocument(
      databaseId: collection.dbId,
      collectionId: collection.id,
      documentId: documentId,
    );
  }
}
