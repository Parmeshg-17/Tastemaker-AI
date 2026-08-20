// Typed application error hierarchy.
//
// Using sealed-class-style enum so every call-site is forced
// to handle all error kinds via exhaustive switch/pattern-match.

enum AppErrorKind {
  /// API key not configured (env var missing at build time).
  missingApiKey,

  /// No internet connectivity detected before the request.
  noConnectivity,

  /// All AI model fallbacks exhausted.
  allModelsFailed,

  /// The AI returned a response but it could not be parsed as a Recipe.
  invalidAiResponse,

  /// Network layer timeout.
  requestTimeout,

  /// HTTP error from OpenRouter (4xx / 5xx).
  httpError,

  /// Ingredient validation failure (business rule).
  validationError,

  /// Unclassified / unexpected error.
  unknown,
}

class AppError implements Exception {
  final AppErrorKind kind;

  /// User-facing message — safe to display directly in UI.
  final String userMessage;

  /// Internal technical detail — log only, never show to users.
  final String? technicalDetail;

  final Object? cause;
  final StackTrace? stackTrace;

  const AppError({
    required this.kind,
    required this.userMessage,
    this.technicalDetail,
    this.cause,
    this.stackTrace,
  });

  // ── Factory constructors ─────────────────────────────────────────────────

  factory AppError.missingApiKey() => const AppError(
        kind: AppErrorKind.missingApiKey,
        userMessage:
            'App is not configured correctly. Please contact support.',
        technicalDetail:
            'OPENROUTER_API_KEY dart-define is empty. '
            'Build with: flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...',
      );

  factory AppError.noConnectivity() => const AppError(
        kind: AppErrorKind.noConnectivity,
        userMessage:
            'No internet connection. Please check your network and try again.',
      );

  factory AppError.allModelsFailed(String detail) => AppError(
        kind: AppErrorKind.allModelsFailed,
        userMessage:
            'Our AI chef is taking a break. Please try again in a moment.',
        technicalDetail: detail,
      );

  factory AppError.invalidAiResponse(String detail) => AppError(
        kind: AppErrorKind.invalidAiResponse,
        userMessage:
            "Couldn't understand the recipe format. Please try again.",
        technicalDetail: detail,
      );

  factory AppError.requestTimeout() => const AppError(
        kind: AppErrorKind.requestTimeout,
        userMessage:
            'The request timed out. Please check your connection and try again.',
      );

  factory AppError.httpError(int statusCode, String body) => AppError(
        kind: AppErrorKind.httpError,
        userMessage: statusCode == 429
            ? 'Too many requests. Please wait a moment and try again.'
            : 'Service unavailable. Please try again later.',
        technicalDetail: 'HTTP $statusCode: $body',
      );

  factory AppError.unknown(Object cause, [StackTrace? st]) => AppError(
        kind: AppErrorKind.unknown,
        userMessage: 'An unexpected error occurred. Please try again.',
        technicalDetail: cause.toString(),
        cause: cause,
        stackTrace: st,
      );

  @override
  String toString() =>
      'AppError(${kind.name}): $userMessage'
      '${technicalDetail != null ? ' | tech: $technicalDetail' : ''}';
}
