import 'package:equatable/equatable.dart';

class MetadataModel extends Equatable {
  final int? currentPage;
  final int? totalPages;
  final int? totalItems;
  final int? limit;

  const MetadataModel({
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.limit,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      currentPage: json['currentPage'] as int?,
      totalPages: json['totalPages'] as int?,
      totalItems: json['totalItems'] as int?,
      limit: json['limit'] as int?,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalPages, totalItems, limit];
}
