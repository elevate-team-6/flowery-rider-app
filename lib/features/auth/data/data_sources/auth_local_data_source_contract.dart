import 'package:flowery_rider_app/features/auth/data/models/response/signup/country_model.dart';

abstract interface class AuthLocalDataSourceContract {
  Future<List<CountryModel>> getCountries();
}
