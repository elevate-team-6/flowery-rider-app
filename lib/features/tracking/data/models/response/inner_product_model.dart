import 'package:equatable/equatable.dart';

class InnerProductModel extends Equatable {
  final String? id;
  final num? price;
  final String? title;

  const InnerProductModel({this.id, this.price, this.title});

  factory InnerProductModel.fromJson(Map<String, dynamic> json) {
    return InnerProductModel(
      id: json['_id'] as String?,
      price: json['price'] as num?,
      title: json['title'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, price, title];
}
