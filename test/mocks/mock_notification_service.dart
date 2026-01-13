/// Mock notification service for testing.
///
/// Since [NotificationService] uses static methods and directly accesses
/// Firebase/Supabase singletons, we use this mock class to track calls
/// and provide a way to verify notification behavior in tests.
///
/// In integration tests, we inject a [TestableSupabaseService] which
/// bypasses the actual NotificationService calls by not triggering them.
class MockNotificationService {
  MockNotificationService._();

  static bool _initialized = false;
  static String? _lastToken;
  static bool _tokenCleared = false;
  static final List<String> _calls = [];

  /// Reset all mock state (call in setUp)
  static void reset() {
    _initialized = false;
    _lastToken = null;
    _tokenCleared = false;
    _calls.clear();
  }

  /// Mock initialize
  static Future<void> initialize() async {
    _initialized = true;
    _calls.add('initialize');
  }

  /// Mock register token
  static Future<void> registerToken() async {
    _lastToken = 'mock-fcm-token';
    _calls.add('registerToken');
  }

  /// Mock clear token
  static Future<void> clearToken() async {
    _lastToken = null;
    _tokenCleared = true;
    _calls.add('clearToken');
  }

  /// Check if initialized
  static bool get isInitialized => _initialized;

  /// Get last token
  static String? get lastToken => _lastToken;

  /// Check if token was cleared
  static bool get tokenCleared => _tokenCleared;

  /// Get call history
  static List<String> get calls => List.unmodifiable(_calls);

  /// Verify a call was made
  static bool wasCalled(String method) => _calls.contains(method);

  /// Verify call count
  static int callCount(String method) =>
      _calls.where((c) => c == method).length;
}
