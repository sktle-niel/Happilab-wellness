import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../shared/widgets/app_toast.dart';
import '../domain/auth_repository.dart';

/// The shared tail of both auth forms: get a session for the credentials,
/// keep it, then enter the signed-in app at [destination] with the whole
/// first-run stack removed — an onboarding route left underneath keeps
/// cycling its video clips. Signing in lands on home; joining goes by the
/// photo step first.
///
/// Returns false when the member could not be let in; the toast has already
/// told them why, and the form should come back to life for another try.
Future<bool> enterWithSession(
  BuildContext context, {
  required Future<Result<AuthSession>> Function() authenticate,
  String destination = AppRoutes.home,
}) async {
  final navigator = Navigator.of(context);
  final overlay = Overlay.of(context);
  final dependencies = AppScope.of(context);

  final outcome = await authenticate();
  final error = outcome.errorOrNull;
  if (error != null) {
    AppToast.failureOn(overlay, error);
    return false;
  }

  try {
    await dependencies.sessionManager.signIn(outcome.valueOrNull!.accessToken);
  } on AppException catch (error) {
    AppToast.failureOn(overlay, error);
    return false;
  }
  // Whatever was loaded belonged to the last session.
  dependencies.member.reset();

  if (context.mounted) {
    navigator.pushNamedAndRemoveUntil(destination, (route) => false);
  }
  return true;
}
