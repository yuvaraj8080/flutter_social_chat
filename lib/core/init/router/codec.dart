import 'dart:convert';

/// A codec for encoding and decoding PhoneNumberSignInState objects
///
/// This is used to pass authentication state between screens during the
/// phone number sign in flow via the navigation state.
class PhoneNumberSignInStateCodec {
  /// Encodes a map of authentication state data into a JSON string
  ///
  /// This allows the state to be passed via navigation parameters
  ///
  /// @param data The map of state data to encode
  /// @return A JSON string representation of the data
  static String encode(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      // Fallback to empty state if encoding fails
      return '{}';
    }
  }

  /// Decodes a JSON string into a map of authentication state data
  ///
  /// @param jsonString The JSON string to decode
  /// @return A map representing the authentication state
  static Map<String, dynamic> decode(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Return empty map if decoding fails
      return {};
    }
  }
}
