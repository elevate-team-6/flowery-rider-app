import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String? id;
  final String? title;
  final String? slug;
  final String? description;
  final String? imgCover;
  final List<String>? images;
  final num? price;
  final num? priceAfterDiscount;
  final int? discount;
  final num? rateAvg;
  final int? rateCount;
  final int? sold;
  final int? quantity;
  final String? category;
  final String? occasion;
  final bool? isSuperAdmin;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  const ProductModel({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.imgCover,
    this.images,
    this.price,
    this.priceAfterDiscount,
    this.discount,
    this.rateAvg,
    this.rateCount,
    this.sold,
    this.quantity,
    this.category,
    this.occasion,
    this.isSuperAdmin,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      imgCover: json['imgCover'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      price: json['price'] as num?,
      priceAfterDiscount: json['priceAfterDiscount'] as num?,
      discount: json['discount'] as int?,
      rateAvg: json['rateAvg'] as num?,
      rateCount: json['rateCount'] as int?,
      sold: json['sold'] as int?,
      quantity: json['quantity'] as int?,
      category: json['category'] as String?,
      occasion: json['occasion'] as String?,
      isSuperAdmin: json['isSuperAdmin'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    description,
    imgCover,
    images,
    price,
    priceAfterDiscount,
    discount,
    rateAvg,
    rateCount,
    sold,
    quantity,
    category,
    occasion,
    isSuperAdmin,
    createdAt,
    updatedAt,
    v,
  ];
}
