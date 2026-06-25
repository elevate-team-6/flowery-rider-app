import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:path/path.dart' as path;

class AppMultipartFile {
  final String? filePath;
  final List<int>? bytes;
  final String? fileName;

  const AppMultipartFile._({this.filePath, this.bytes, this.fileName});

  factory AppMultipartFile.fromPath(String filePath, {String? fileName}) {
    return AppMultipartFile._(filePath: filePath, fileName: fileName);
  }

  factory AppMultipartFile.fromBytes(
    List<int> bytes, {
    required String fileName,
  }) {
    return AppMultipartFile._(bytes: bytes, fileName: fileName);
  }

  Future<MultipartFile> toMultipartFile() async {
    if (filePath != null) {
      final file = File(filePath!);

      if (!await file.exists()) {
        throw Exception('${AppStrings.fileDoesNotExist}: $filePath');
      }

      return MultipartFile.fromFile(
        file.path,
        filename: fileName ?? path.basename(file.path),
      );
    }

    if (bytes != null) {
      return MultipartFile.fromBytes(bytes!, filename: fileName ?? 'file');
    }

    throw Exception(AppStrings.appMultipartFileRequiresEitherFilePathOrBytes);
  }
}
