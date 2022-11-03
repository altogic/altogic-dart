library altogic_dart;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:socket_io_client/socket_io_client.dart';

import '../altogic_dart.dart';

import 'utils/platform_auth/stub_auth.dart'
if (dart.library.html) 'utils/platform_auth/web_auth.dart'
if (dart.library.io) 'utils/platform_auth/io_auth.dart' show setRedirect;

import 'utils/platform_fetcher/stub_fetcher.dart'
if (dart.library.html) 'utils/platform_fetcher/web_fetcher.dart'
if (dart.library.io) 'utils/platform_fetcher/io_fetcher.dart'
    show handlePlatformRequest, handlePlatformUpload;
part 'altogic_client.dart';
part 'types.dart';
part 'cache_manager.dart';
part 'endpoint_manager.dart';
part 'api_base.dart';
part 'api_response.dart';
part 'auth_manager.dart';
part 'bucket_manager.dart';
part 'database_manager.dart';
part 'db_object.dart';
part 'file_manager.dart';
part 'query_builder.dart';
part 'queue_manager.dart';
part 'realtime_manager.dart';
part 'storage_manager.dart';
part 'task_manager.dart';
part 'utils/fetcher.dart';
