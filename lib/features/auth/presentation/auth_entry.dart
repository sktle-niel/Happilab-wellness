import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/app_toast.dart';
import '../domain/local_session.dart';

/// The shared tail of both auth forms: persist the local session, then enter
/// the signed-in app at [destination] with the whole first-run stack removed —
/// an onboarding route left underneath keeps cycling its video clips. Signing
/// in lands on home; joining goes by the photo step first.
///
/// Returns false when the session could not be saved; the toast has already
/// told the member why, and the form should come back to life for another try.
Future<bool> enterWithLocalSession(
  BuildContext context, {
  String destination = AppRoutes.home,
}) async {
  final navigator = Navigator.of(context);
  final overlay = Overlay.of(context);
  final session = AppScope.of(context).sessionManager;

  try {
    await session.signIn(localSessionToken);
  } on AppException catch (error) {
    AppToast.failureOn(overlay, error);
    return false;
  }

  if (context.mounted) {
    navigator.pushNamedAndRemoveUntil(destination, (route) => false);
  }
  return true;
}
