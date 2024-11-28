import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

class LevelCompletionHandler {
  late String username;
  late String levelname;

  // Constructor to set username and levelname
  LevelCompletionHandler({required this.username, required this.levelname});

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> createMindParkDirectoryAndSaveCSV(
      List<Map<String, dynamic>> data) async {
    // Request permission
    await requestStoragePermission();

    // Get the external storage directory
    Directory? externalDir = await getExternalStorageDirectory();
    String externalDirPath = externalDir!.path;

    // Define the directory path
    String directoryPath = '$externalDirPath/MindPark';
    log('Directory where csv is stored: $directoryPath');

    // Create the directory
    Directory directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Define the CSV file path
    String csvFilePath = '$directoryPath/${username}_$levelname.csv';

    // Convert the data to CSV format
    List<List<dynamic>> csvData =
        data.map((item) => item.values.toList()).toList();
    String csvString = const ListToCsvConverter()
        .convert(csvData); // Convert list of lists to CSV string

    // Write the CSV data to the file
    File file = File(csvFilePath);
    await file.writeAsString(csvString);
  }
}
