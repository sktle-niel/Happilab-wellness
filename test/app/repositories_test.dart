import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/di/repositories.dart';
import 'package:happilab/core/config/app_config.dart';
import 'package:happilab/core/logging/app_logger.dart';
import 'package:happilab/core/network/api_client.dart';
import 'package:happilab/core/security/token_store.dart';
import 'package:happilab/features/auth/data/auth_api.dart';
import 'package:happilab/features/auth/data/fake_auth_repository.dart';
import 'package:happilab/features/support/data/fake_support_desk.dart';
import 'package:happilab/features/support/data/support_desk_api.dart';

import '../support/fake_http_transport.dart';

void main() {
  Repositories bind(BackendMode backend) {
    final config = AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: Uri.parse('https://api.test.local'),
      backend: backend,
    );
    return Repositories.forConfig(
      config,
      ApiClient(
        config: config,
        transport: FakeHttpTransport(),
        credentials: InMemoryTokenStore(),
        logger: AppLogger.forEnvironment(isProduction: true),
      ),
    );
  }

  test('the fake backend is bound unless the build asks for the API', () {
    expect(bind(BackendMode.fake).auth, isA<FakeAuthRepository>());
    expect(bind(BackendMode.fake).supportDesk, isA<FakeSupportDesk>());
    expect(bind(BackendMode.api).auth, isA<AuthApi>());
    expect(bind(BackendMode.api).supportDesk, isA<SupportDeskApi>());
  });
}
