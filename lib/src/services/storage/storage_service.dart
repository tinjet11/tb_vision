import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/services.dart';
import 'package:tb_vision/src/services/storage/bucket.dart';

class StorageService {
  final Storage storage;
  final Map<String, Bucket> _buckets = {};

  StorageService(Client client, List<Bucket> buckets)
      : storage = Storage(client) {
    // Initialize the buckets map for easy access by name
    for (var bucket in buckets) {
      _buckets[bucket.name] = bucket;
    }
  }

  Future<File> createFile(String bucketName, InputFile file,
      {String? fileId}) async {
    final bucket = _buckets[bucketName]!;
    return await storage.createFile(
      bucketId: bucket.id,
      fileId: fileId ?? ID.unique(),
      file: file,
    );
  }

  Future<File> getFile(String bucketName, String fileId) async {
    final bucket = _buckets[bucketName]!;
    return await storage.getFile(
      bucketId: bucket.id,
      fileId: fileId,
    );
  }

  Future<FileList> listFiles(String bucketName, {List<String>? queries}) async {
    final bucket = _buckets[bucketName]!;
    return await storage.listFiles(
      bucketId: bucket.id,
      queries: queries,
    );
  }

  Future<void> deleteFile(String bucketName, String fileId) async {
    final bucket = _buckets[bucketName]!;
    await storage.deleteFile(
      bucketId: bucket.id,
      fileId: fileId,
    );
  }

  Future<String> getFilePreviewUrl(String bucketName, String fileId) async {
    final bucket = _buckets[bucketName]!;
    return storage
        .getFilePreview(
          bucketId: bucket.id,
          fileId: fileId,
        )
        .toString();
  }

  Future<Uint8List> getFileView(String bucketName, String fileId) async {
    final bucket = _buckets[bucketName]!;
    return storage.getFileView(
      bucketId: bucket.id,
      fileId: fileId,
    );
  }
}
