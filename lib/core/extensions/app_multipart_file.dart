import 'package:dio/dio.dart';

class AppMultipartFile {
  final String path;
  final String? fileName;

  const AppMultipartFile({required this.path, this.fileName});

  Future<MultipartFile> toMultipartFile() async {
    return MultipartFile.fromFile(path, filename: fileName);
  }
}
