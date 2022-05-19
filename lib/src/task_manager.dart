import '../altogic_dart.dart';

class TaskManager extends APIBase {
  TaskManager(super.fetcher);

  Future<APIResponse<TaskInfo>> runOnce(String taskNameOrId) async {
    var res = await fetcher.post<Map<String, dynamic>>('/_api/rest/v1/task',
        body: {'taskNameOrId': taskNameOrId});

    return APIResponse(errors: res.errors, data: TaskInfo.fromJson(res.data!));
  }

  Future<APIResponse<TaskInfo>> getTaskStatus(String taskId) async {
    var res =
        await fetcher.get<Map<String, dynamic>>('/_api/rest/v1/task/$taskId');

    return APIResponse(
        errors: res.errors,
        data: res.data != null ? TaskInfo.fromJson(res.data!) : null);
  }
}
