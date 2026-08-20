// Client-side rate limiter to prevent API abuse.
//
// Enforces a minimum cooldown between recipe generation requests.
// This is a UX + cost guard — a server-side rate limit is still needed
// for a production backend proxy.

class RateLimiter {
  RateLimiter._();

  static const Duration _cooldown = Duration(seconds: 15);
  static DateTime? _lastRequestTime;

  /// Returns null if the request is allowed, or a human-readable
  /// message with the remaining wait time if throttled.
  static String? checkAllowed() {
    if (_lastRequestTime == null) return null;

    final elapsed = DateTime.now().difference(_lastRequestTime!);
    if (elapsed >= _cooldown) return null;

    final remaining = (_cooldown - elapsed).inSeconds + 1;
    return 'Please wait $remaining second${remaining == 1 ? '' : 's'} before generating another recipe.';
  }

  /// Call this immediately before making an API request.
  static void recordRequest() {
    _lastRequestTime = DateTime.now();
  }

  /// Reset (used in tests or on full app reset).
  static void reset() {
    _lastRequestTime = null;
  }
}
