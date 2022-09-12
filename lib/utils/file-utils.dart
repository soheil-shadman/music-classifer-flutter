import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {


  static Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  static Future<void> deleteFolderItems(String folderName) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');
    try {
      if (await _appDocDirFolder.exists()) {

        final List<FileSystemEntity> entities = await _appDocDirFolder.list().toList();
        for (var i = 0; i < entities.length; i++) {
          await entities[i].delete();
        }
      }
      else
        {
          final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
        }
    } catch (e) {
      print(e.toString());
      print('problem deleting');
    }
  }
}
