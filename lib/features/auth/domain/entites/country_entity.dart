import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String isoCode;
  final String name;
  final String phoneCode;
  final String flag;
  final String currency;

  const CountryEntity({
    required this.isoCode,
    required this.name,
    required this.phoneCode,
    required this.flag,
    required this.currency,
  });

  @override
  List<Object?> get props => [isoCode, name, phoneCode, flag, currency];
}
