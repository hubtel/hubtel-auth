
class AuthData {
  final AuthStatus status;

  final String? token;

  final String? mobileNumber;

  final bool? hasSetPin;

  AuthData({
    required this.status,
    this.token,
    this.mobileNumber,
    this.hasSetPin,
  });



  factory AuthData.fromJson(Map<String, dynamic>? json) {
    print("hasSetPin: ${json?['hasSetPin'] }");
  return AuthData(
  status: AuthStatus.success, // Assuming 'status' is an enum ordinal
  token: json?['token'] as String?,
  mobileNumber: json?['mobileNumber'] as String?,
  hasSetPin: ((json?['hasSetPin'] as String?) == "true") ? true : false);
  }


}

enum AuthStatus { failed, success }
