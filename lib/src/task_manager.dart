import '../altogic_dart.dart';

/// The task manager allows you to manually trigger service executions of your
/// scheduled tasks which actually ran periodically at fixed times, dates,
/// or intervals.
///
/// Typically, a scheduled task runs according to its defined execution
/// schedule. However, with Altogic's client API by calling the [runOnce]
/// method, you can manually run scheduled tasks ahead of their actual
/// execution schedule.
class TaskManager extends APIBase {
  /// Creates an instance of [TaskManager] to trigger execution of
  /// scheduled tasks.
  ///
  /// [fetcher] The http client to make RESTful API calls to the application's
  /// execution engine.
  TaskManager(super.fetcher);

  /// Triggers the execution of the specified task. After the task is triggered,
  /// the routed service defined in your scheduled task configuration is
  /// invoked. This routed service executes the task and performs necessary
  /// actions defined in its service flow.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [taskNameOrId] The name or id of the message queue.
  ///
  /// If successful, returns information about the triggered task. You can use
  /// `taskId` to check the execution status of your task by calling
  /// [getTaskStatus] method. In case of errors, returns the errors that
  /// occurred.
  Future<APIResponse<TaskInfo>> runOnce(String taskNameOrId) async {
    var res = await fetcher.post<Map<String, dynamic>>('/_api/rest/v1/task',
        body: {'taskNameOrId': taskNameOrId});

    return APIResponse(errors: res.errors, data: TaskInfo.fromJson(res.data!));
  }

  /// Gets the latest status of the task. The last seven days task execution
  /// logs are kept. If you try to get the status of a task that has been
  /// triggered earlier, this method returns `null` for [TaskInfo].
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [taskId] The id of the task
  ///
  /// If successful, returns status information about the triggered task
  Future<APIResponse<TaskInfo>> getTaskStatus(String taskId) async {
    var res =
        await fetcher.get<Map<String, dynamic>>('/_api/rest/v1/task/$taskId');

    return APIResponse(
        errors: res.errors,
        data: res.data != null ? TaskInfo.fromJson(res.data!) : null);
  }
}
