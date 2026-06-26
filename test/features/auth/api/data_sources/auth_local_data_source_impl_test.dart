import 'dart:convert';

import 'package:flowery_rider_app/features/auth/api/data_sources/auth_local_data_source_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_rider_app/core/utils/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = AuthLocalDataSourceImpl();

    const jsonData = '''
    [
      {
        "name": "Egypt",
        "code": "EG",
        "dial_code": "+20"
      }
    ]
    ''';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());

          if (key == AppJson.countryPath) {
            return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonData)).buffer,
            );
          }

          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('should return list of countries', () async {
    final result = await dataSource.getCountries();

    expect(result.length, 1);
    expect(result.first.name, 'Egypt');
  });
}
