import '../altogic_dart.dart';

class QueueManager extends APIBase {
  QueueManager(super.fetcher);

  Future<APIResponse<MessageInfo>> submitMessage(
      String queueNameOrId, Map<String, dynamic> message) async {
    var res = await fetcher.post<Map<String, dynamic>>('/_api/rest/v1/queue',
        body: {'queueNameOrId': queueNameOrId, 'message': message});
    return APIResponse(
        errors: res.errors,
        data: res.data != null ? MessageInfo.fromJson(res.data!) : null);
  }

  Future<APIResponse<MessageInfo>> getMessageStatus(String messageId) async {
    var res = await fetcher.get<Map<String, dynamic>>(
      '/_api/rest/v1/queue/$messageId',
    );
    return APIResponse(
        errors: res.errors,
        data: res.data != null ? MessageInfo.fromJson(res.data!) : null);
  }
}
