import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';


class CountryModel {
  final String isoCode;
  final String name;
  final String phoneCode;
  final String flag;
  final String currency;


  CountryModel({
    required this.isoCode,
    required this.name,
    required this.phoneCode,
    required this.flag,
    required this.currency,

  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      isoCode: json['isoCode'] ?? '',
      name: json['name'] ?? '',
      phoneCode: json['phoneCode'] ?? '',
      flag: json['flag'] ?? '',
      currency: json['currency'] ?? '',
    
    );
  }

  CountryEntity toEntity() {
    return CountryEntity(
      isoCode: isoCode,
      name: name,
      phoneCode: phoneCode,
      flag: flag,
      currency: currency, id: '',
  
    );
  }
}


