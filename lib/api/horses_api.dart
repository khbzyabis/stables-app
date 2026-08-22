import '../models/horse.dart';
import 'api_client.dart';

/// Talks to the API's stable-scoped horses endpoints:
///   GET  /v1/stables/:stableId/horses
///   POST /v1/stables/:stableId/horses
class HorsesApi {
  HorsesApi(this._client);
  final ApiClient _client;

  Future<List<Horse>> list(String stableId) async {
    final data = await _client.get('/v1/stables/$stableId/horses');
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(Horse.fromJson).toList();
  }

  Future<Horse> create(String stableId, Horse horse) async {
    final data = await _client.post(
      '/v1/stables/$stableId/horses',
      horse.toCreateJson(),
    );
    return Horse.fromJson(data as Map<String, dynamic>);
  }
}
