import '../../utils/result.dart';

abstract interface class TeamService {
  Future<Result<Map<String, Object?>?>> rpc(
    String name,
    Map<String, Object?> parameters,
  );
  Future<Result<Map<String, Object?>>> send(Map<String, Object?> body);
  Future<Result<Map<String, Object?>>> reconcile(String key);
  Future<Result<Unit>> definePassword(String password);
}
