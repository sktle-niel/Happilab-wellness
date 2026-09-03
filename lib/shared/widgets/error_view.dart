import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/errors/app_exception.dart';
import 'app_button.dart';
import 'gap.dart';

/// One failure surface for the whole app.
///
/// It renders [AppException.message], which is written to be safe for a user to
/// read — raw exceptions and stack traces never reach the screen.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, this.onRetry, super.key});

  final AppException error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(error.displayIcon, size: 40, color: theme.colorScheme.error),
            const Gap.md(),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const Gap.lg(),
              AppButton.secondary(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A mark that matches the failure reads faster than the words under it.
extension on AppException {
  IconData get displayIcon => switch (this) {
    NetworkException() => Icons.wifi_off_rounded,
    RequestTimeoutException() => Icons.hourglass_bottom_rounded,
    RateLimitedException() => Icons.speed_rounded,
    UnauthorizedException() => Icons.lock_outline_rounded,
    ServerException() => Icons.cloud_off_rounded,
    _ => Icons.error_outline,
  };
}
