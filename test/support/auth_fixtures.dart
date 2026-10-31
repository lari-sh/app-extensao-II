import 'dart:convert';

const authUserId = '50000000-0000-4000-8000-000000000001';
const authSessionId = '60000000-0000-4000-8000-000000000001';
Map<String, dynamic> authUserJson({String id = authUserId}) => {
  'id': id,
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'fixture@example.test',
  'app_metadata': {'provider': 'email'},
  'user_metadata': {},
  'created_at': '2026-01-01T00:00:00Z',
};
String authTestToken({String userId = authUserId, int? expiresAt}) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part({'sub': userId, 'session_id': authSessionId, 'role': 'authenticated', 'exp': expiresAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600})}.test-signature';
}

Map<String, dynamic> authSessionJson({int? expiresAt}) => {
  'access_token': authTestToken(expiresAt: expiresAt),
  'refresh_token': 'fake-refresh-only',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': authUserJson(),
};
