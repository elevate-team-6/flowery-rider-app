import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCountriesUseCase {
  final AuthRepoContract repository;

  GetCountriesUseCase(this.repository);

  Future<List<CountryEntity>> call() {
    return repository.getCountries();
  }
}
