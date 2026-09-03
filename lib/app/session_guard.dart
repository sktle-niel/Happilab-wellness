import 'package:flutter/material.dart';

import '../core/security/session_manager.dart';
import '../shared/widgets/app_toast.dart';
import 'router/app_routes.dart';

/// Walks the member out when their session ends.
///
/// Both exits converge here — an explicit log out and a token the server
/// rejected mid-use — so no screen has to know how to leave. A revoked session
/// is explained with a toast; a chosen one is not, because the member already
/// knows.
class SessionGuard extends StatefulWidget {
  const SessionGuard({
    required this.session,
    required this.navigatorKey,
    required this.messengerKey,
    required this.child,
    super.key,
  });

  final SessionManager session;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  late SessionStatus _last = widget.session.status;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Only the fall from signed in matters: the first-run restore also lands on
  /// signed out, and reacting to that would hijack onboarding.
  void _onSessionChanged() {
    final wasSignedIn = _last == SessionStatus.signedIn;
    _last = widget.session.status;
    if (!wasSignedIn || _last != SessionStatus.signedOut) return;

    widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (route) => false,
    );

    final messenger = widget.messengerKey.currentState;
    if (messenger != null &&
        widget.session.endReason == SessionEndReason.revoked) {
      AppToast.showOn(
        messenger,
        ToastKind.caution,
        'Session expired',
        detail: 'Please sign in again to continue.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
