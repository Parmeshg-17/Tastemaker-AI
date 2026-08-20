// Input sanitization utilities.
//
// All user-supplied text MUST pass through this class before being
// embedded into an AI prompt to prevent prompt-injection attacks.

class InputSanitizer {
  InputSanitizer._();

  // ── Limits ───────────────────────────────────────────────────────────────

  static const int maxIngredientLength = 50;
  static const int maxIngredients = 10;

  // Deny-list: instruction-injection phrases that should never appear in
  // an ingredient entry. Normalized to lowercase for matching.
  static const List<String> _injectionPatterns = [
    'ignore previous',
    'ignore above',
    'disregard',
    'system prompt',
    'you are now',
    'act as',
    'jailbreak',
    'forget',
    'new instruction',
    'override',
    '```',
    '<script',
    'javascript:',
  ];

  // ── Public API ───────────────────────────────────────────────────────────

  /// Sanitize a single ingredient string.
  ///
  /// Returns null if the input is unsafe or empty after sanitization.
  static String? sanitizeIngredient(String raw) {
    // 1. Trim whitespace
    String value = raw.trim();

    // 2. Reject empty
    if (value.isEmpty) return null;

    // 3. Strip non-printable / control characters
    value = value.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // 4. Collapse multiple spaces
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 5. Enforce max length
    if (value.length > maxIngredientLength) {
      value = value.substring(0, maxIngredientLength).trim();
    }

    // 6. Prompt-injection check
    final lower = value.toLowerCase();
    for (final pattern in _injectionPatterns) {
      if (lower.contains(pattern)) {
        return null; // Silently reject — do not explain to attacker
      }
    }

    // 7. Allow only printable ASCII + common Unicode letters/numbers/spaces/hyphens/parentheses
    final allowed = RegExp(r"^[\p{L}\p{N}\s\-\(\)\/\.,&']+$", unicode: true);
    if (!allowed.hasMatch(value)) {
      // Strip disallowed chars rather than reject, keeping what's safe
      value = value.replaceAll(
          RegExp(r"[^\p{L}\p{N}\s\-\(\)\/\.,&']", unicode: true), '').trim();
    }

    return value.isEmpty ? null : value;
  }

  /// Sanitize a list of ingredients.
  ///
  /// Automatically deduplicates (case-insensitive) and enforces [maxIngredients].
  static List<String> sanitizeIngredientList(List<String> raw) {
    final seen = <String>{};
    final result = <String>[];

    for (final item in raw) {
      if (result.length >= maxIngredients) break;
      final clean = sanitizeIngredient(item);
      if (clean == null) continue;
      final key = clean.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(clean);
    }

    return result;
  }
}
