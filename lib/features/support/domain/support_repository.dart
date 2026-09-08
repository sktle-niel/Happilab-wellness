import '../../../core/errors/result.dart';
import 'support_content.dart';

/// The help copy: what members ask, and the terms they joined under.
abstract interface class SupportRepository {
  Future<Result<List<FaqEntry>>> faqs();

  Future<Result<List<TermsSection>>> terms();
}
