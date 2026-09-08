import '../../../core/errors/result.dart';
import '../domain/support_content.dart';
import '../domain/support_repository.dart';

/// The bundled copy, until the API serves it.
final class FakeSupportRepository implements SupportRepository {
  const FakeSupportRepository();

  @override
  Future<Result<List<FaqEntry>>> faqs() async => Success(SupportContent.faqs);

  @override
  Future<Result<List<TermsSection>>> terms() async =>
      const Success(SupportContent.terms);
}
