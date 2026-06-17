import 'dart:convert';

import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/country_model.dart';
import 'package:flutter/services.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSourceContract {
  @override
  Future<List<CountryModel>> getCountries() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/countries.json',
    );

    final List decoded = jsonDecode(jsonString);

    return decoded.map((e) => CountryModel.fromJson(e)).toList();
  }
}
