import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class TimetableCSVReader {
  static Future<dynamic> getCSVColumn(String colName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ["csv"],
    );

    if (result != null && result.files.first.path != null) {
      File file = File(result.files.single.path!);
      PlatformFile filePlatform = result.files.single;
      if (filePlatform.extension != "csv") {
        throw Exception("File is not CSV file");
      }

      final csvFile = file.openRead();
      List<String> data = await csvFile.transform(utf8.decoder).toList();

      List<List<dynamic>> convertedData =
          const CsvToListConverter().convert(data[0], eol: "\n");

      int colIndex = 0;
      for (String header in convertedData[0]) {
        if (header == colName) {
          List<dynamic> column = [];
          for (int x = 1; x < convertedData.length; x++) {
            column.add(convertedData[x][colIndex]);
          }
          return column;
        }
        colIndex++;
      }
      throw Exception("Column name does not exists in file.");
    } else {
      throw Exception("User cancelled file selection.");
    }
  }
}
