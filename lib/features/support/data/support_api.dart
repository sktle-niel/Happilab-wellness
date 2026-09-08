import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../domain/support_content.dart';
import '../domain/support_repository.dart';

/// [SupportRepository] over the API. Copy changes rarely, so both reads
/// are cached for an hour and served stale when the backend is down.
final class SupportApi implements SupportRepository {
  const SupportApi(this._client);

  static const Duration _maxAge = Duration(hours: 1);

  final ApiClient _client;

  @override
  Future<Result<List<FaqEntry>>> faqs() =>
      _client.get(ApiEndpoints.faqs, parse: parseFaqs, maxAge: _maxAge);

  @override
  Future<Result<List<TermsSection>>> terms() =>
      _client.get(ApiEndpoints.terms, parse: parseTerms, maxAge: _maxAge);

  static List<FaqEntry> parseFaqs(Object? json) => JsonReader.listOf(
    json,
    (item) => FaqEntry(
      question: item.string('question'),
      answer: item.string('answer'),
    ),
  );

  static List<TermsSection> parseTerms(Object? json) => JsonReader.listOf(
    json,
    (item) => TermsSection(
      heading: item.string('heading'),
      body: item.string('body'),
    ),
  );
}
