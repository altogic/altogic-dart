part of altogic_dart;

const reconnectionDelay = 1000;
const timout = 20000;
const awaitTimeout = 5000;

typedef EventCallback = void Function(dynamic data);

/// Defines the structure of listener (callback) functions for user generated events (messages).
///
/// **eventName** - The user event that has been triggered. Possible value are `user:signin`, `user:signout`, `user:update`, `user:delete`, `user:pwdchange`, `user:emailchange`, `user:phonechange`.
///
/// **session** - The user session object that has triggered the event. If the event is triggered by the user without a session then this value will be `null`.
/// @export
/// @type ListenerFunction
typedef UserEventListenerFunction = void Function(
    UserEvent eventName, Session? session);

/// The realtime manager allows realtime publish and subscribe (pub/sub)
/// messaging through websockets.
///
/// Realtime makes it possible to open a two-way interactive communication
/// session between the user's device (e.g., browser, smartphone) and a server.
/// With realtime, you can send messages to a server and receive event-driven
/// responses without having to poll the server for a reply.
///
/// The configuration parameters of the realtime module is specified when
/// creating the Altogic client library instance. In particular three key
/// parameters affect how realtime messaging works in your apps.
///
/// - `echoMessages` -  This boolean parmeter enables or prevents realtime
/// messages originating from this connection being echoed back on the same
/// connection. By default messsages are echoed back.
/// - `bufferMessages` -  By default, any event emitted while the realtime
/// socket is not connected will be buffered until reconnection. You can turn
/// on/off the message buffering using this parameter. While enabling this
/// feature is useful in most cases (when the reconnection delay is short), it
/// could result in a huge spike of events when the connection is restored.
/// - `autoJoinChannels` -  This parameter enables or disables automatic join
/// to channels already subscribed in case of websocket reconnection. When
/// websocket is disconnected, it automatically leaves subscribed channels.
/// This parameter helps re-joining to already joined channels when the
/// connection is restored. If this parameter is set to false, you need to
/// listen to `connect` and `disconnect` events to manage your channel
/// subscriptions.
class RealtimeManager extends APIBase {
  RealtimeManager(super.fetcher, [RealtimeOptions? options])
      : _echoMessages = options?.echoMessages ?? true,
        _bufferMessages = options?.bufferMessages ?? true,
        _autoJoinChannels = options?.autoJoinChannels ?? true {
    _establishConnection(options);
  }

  /// The web socket object which is basically an `EventEmitter` which sends
  /// events to and receive events from the server over the network.
  Socket? _socket;

  /// The default setting whether to enable or prevent realtime messages
  /// originating from this connection being echoed back on the same connection.
  final bool _echoMessages;

  /// The flag to enable or prevent automatic join to channels already
  /// subscribed in case of websocket reconnection. When websocket is
  /// disconnected, it automatically leaves subscribed channels. This parameter
  /// helps re-joining to already joined channels when the connection is
  /// restored.
  final bool _autoJoinChannels;

  /// By default, any event emitted while the realtime socket is not connected
  /// will be buffered until reconnection. You can turn on/off the message
  /// buffering using this parameter.
  final bool _bufferMessages;

  /// Keeps the list of channels this socket is subscribed to. In case of a
  /// reconnect, if `autoJoinChannels` is enabled then joins to the list of
  /// channels specified in this map.
  /// @type {Map}
  final Map<String, bool> _channels = {};

  /// Keeps a reference to the latest user data that is updated using the
  /// [updateProfile] method.
  dynamic _userData;

  /// Connects to the realtime server
  void _establishConnection([RealtimeOptions? options]) {
    var urlInfo = parseRealtimeEnvUrl(_fetcher.getBaseUrl());

    _socket = io(urlInfo.realtimeUrl, {
      'reconnection': true,
      'reconnectionDelay': options?.reconnectionDelay ?? reconnectionDelay,
      'timeout': options?.timeout ?? timout,
      'transports': ['websocket', 'polling'],
      'auth': {
        'echoMessages': _echoMessages,
        'subdomain': urlInfo.subdomain,
        'envId': urlInfo.envId,
        'clientKey': _fetcher.getClientKey(),
        'Session': _fetcher.getSessionToken(),
      },
    });
    _socket!.on('reconnect', (_) {
      if (_autoJoinChannels) _joinChannels();
    });
  }

  void _joinChannels() {
    if (_userData != null) updateProfile(_userData, _echoMessages);
    _channels.forEach(join);
  }

  /// Callback function fired upon successfully realtime connection, including
  /// a successful reconnection.
  ///
  /// [listener] The listener function.
  void onConnect(void Function(dynamic) listener) {
    _socket!.json.on('connect', listener);
  }

  /// Callback function fired upon an attempt to reconnect. Passes the
  /// reconnection attempt number as a parameter to the callback function.
  ///
  /// [listener] The listener function.
  void onReconnectAttempt(void Function(int number) listener) {
    _socket!.json.on('reconnect_attempt', listener as void Function(dynamic));
  }

  /// Callback function fired upon realtime disconnection. Passes the
  /// disconnection `reason` as a string parameter to the callback function.
  ///
  /// [listener] The listener function.
  void onDisconnect(void Function(dynamic reason) listener) {
    _socket!.json.on('disconnect', listener);
  }

  /// Callback function fired upon a realtime connection error. Passes the
  /// `error` as a parameter to the callback function.
  ///
  /// [listener] The listener function.
  void onError(void Function(dynamic) listener) {
    _socket!.json.on('connect_error', listener);
  }

  /// Manually open the realtime connection, connects the socket.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  void open() {
    if (_socket!.disconnected) _socket!.open();
    _socket!.emitBuffered();
  }

  /// Manually closes the realtime connection. In this case, the socket
  /// will not try to reconnect.
  void close() {
    if (_socket!.connected) _socket!.close();
  }

  /// Returns the unique identifier of the underlying websocket
  /// returns the socket id
  String getSocketId() => _socket!.id!;

  // TODO: Test

  /// Returns true if the realtime socket is connected otherwise false
  bool isConnected() => _socket!.connected;

  // TODO: Test

  /// Register a new listener function for the given event.
  void on(String eventName, EventCallback listener) {
    _socket!.json.on(eventName, listener);
  }

  // TODO: Test

  /// Registers a new catch-all listener function. This listener function is
  /// triggered for all messages sent to this socket.
  ///
  /// [listener] The listener function.
  void onAny(void Function(String, dynamic) listener) {
    _socket!.json.onAny(listener);
  }

  /// Adds a one-time listener function for the event named `eventName`.
  /// The next time `eventName` is triggered, this listener is removed
  /// and then invoked.
  ///
  /// [eventName] The name of the event.
  ///
  /// [listener] The listener function.
  void once(String eventName, EventCallback listener) {
    _socket!.json.once(eventName, listener);
  }

  /// Removes the specified listener function from the listener array for the
  /// event named `eventName`.
  ///
  /// If `listener` is not specified, it removes all listeners for for the
  /// event named `eventName`.
  ///
  /// If neither `eventName` nor `listener` is specified, it removes all
  /// listeners for all events.
  ///
  /// [eventName] The name of the event.
  ///
  /// [listener] The listener function.
  void off(String eventName, EventCallback? listener) {
    _socket!.json.off(eventName, listener);
  }

  /// Removes the previously registered listener function. If no listener is
  /// provided, all catch-all listener functions are removed.
  ///
  /// [listener] The listener function.
  void offAny(void Function(String, dynamic) listener) {
    _socket!.json.offAny(listener);
  }

  /// Sends the message identified by the `eventName` to all connected members
  /// of the app. All serializable datastructures are supported for the
  /// `message`, including `Buffer`.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// @param {string} eventName The name of the event.
  /// @param {any} message The message payload/contents.
  /// @param {boolean} echo Override the echo flag specified when creating
  /// the websocket to enable or prevent realtime messages originating from
  /// this connection being echoed back on the same connection.
  ///
  /// Throws an exception if `eventName` is not specified
  void broadcast(String eventName, dynamic message, [bool? echo]) {
    checkRequired('eventName', eventName);
    if (_bufferMessages) {
      _socket!.json
          .emit('message', {'eventName': eventName, 'message': message});
    } else {
      _socket!.json.emit('message', {
        'eventName': eventName,
        'message': message,
        if (echo != null) 'echo': echo
      });
    }
  }

  // TODO: Test

  /// Sends the message identified by the `eventName` to the provided channel
  /// members only. All serializable datastructures are supported for the
  /// `message`, including `Buffer`.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [channel] The name of the channel.
  ///
  /// [eventName] The name of the event.
  ///
  /// [message] The message payload/contents.
  ///
  /// [echo] Override the echo flag specified when creating the websocket to
  /// enable or prevent realtime messages originating from this connection
  /// being echoed back on the same connection.
  ///
  /// Throws an exception if `channel` or `eventName` is not specified
  void send(String channel, String eventName, dynamic message, [bool? echo]) {
    checkRequired('channel', channel);
    checkRequired('eventName', eventName);
    if (_bufferMessages) {
      _socket!.json.emit('message',
          {'channel': channel, 'eventName': eventName, 'message': message});
      _socket!.json.emitBuffered();
    } else {
      _socket!.json.emit('message', {
        'channel': channel,
        'eventName': eventName,
        'message': message,
        if (echo != null) 'echo': echo
      });
    }
  }

  /// Adds the realtime socket to the specified channel. As a result of this
  /// action a `channel:join` event is sent to all members of the channel
  /// notifying the new member arrival.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// channel The name of the channel.
  /// echo Override the echo flag specified when creating the websocket to
  /// enable or prevent `channel:join` event originating from this connection
  /// being echoed back on the same connection.
  ///
  /// Throws an exception if `channel` is not specified
  void join(String channel, [bool? echo]) {
    checkRequired('channel', channel);
    _socket!.json.emit('join', {'channel': channel, 'echo': echo});

    _channels[channel] = echo ?? _echoMessages;
  }

  // TODO: Test

  /// Removes the realtime socket from the specified channel. As a result of
  /// this action a `channel:leave` event is sent to all members of the channel
  /// notifying the departure of existing member.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [channel] The name of the channel.
  ///
  /// [echo] Override the echo flag specified when creating the websocket to
  /// enable or prevent `channel:leave` event originating from this connection
  /// being echoed back on the same connection.
  ///
  /// Throws an exception if `channel` is not specified
  void leave(String channel, [bool? echo]) {
    checkRequired('channel', channel);
    _socket!.json.emit('leave', {'channel': channel, 'echo': echo});

    _channels.remove(channel);
  }

  // TODO: Test

  /// Update the current realtime socket member data and broadcast an update
  /// event to each joined channel so that other channel members can get the
  /// information about the updated member data. Whenever the socket joins a
  /// new channel, this updated member data will be broadcasted to channel
  /// members. As a result of this action a `channel:update` event is sent to
  /// all members of the subscribed channels notifying the member data update.
  ///
  /// As an example if you are developing a realtime chat application it might
  /// be a good idea to store the username and user profile picture URL in
  /// member data so that joined chat channels can get updated user information.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [data] data payload for the current member. The supported payload types
  /// are Strings, JSON objects and arrays, buffers containing arbitrary binary
  /// data, and null.
  ///
  /// [echo] Override the echo flag specified when creating the websocket to
  /// enable or prevent `channel:update` event originating from this connection
  /// being echoed back on the same connection.
  ///
  void updateProfile(dynamic data, [bool? echo]) {
    _socket!.json.emit('update', {'data': data, 'echo': echo});
    _userData = data;
  }

// TODO: Test

  /// Convenience method which registers a new listener function for `
  /// channel:join` events which are emitted when a new member joins a channel.
  ///
  /// [listener] The listener function.
  ///
  void onJoin(EventCallback listener) {
    _socket!.json.on('channel:join', listener);
  }

  // TODO: Test

  /// Convenience method which registers a new listener function for
  /// `channel:leave` events which are emitted when an existing member leaves
  /// a channel.
  ///
  /// [listener] The listener function.
  void onLeave(EventCallback listener) {
    _socket!.json.on('channel:leave', listener);
  }

  // TODO: Test

  /// Convenience method which registers a new listener function for
  /// `channel:update` events which are emitted when a channel member
  /// updates its member data.
  ///
  /// [listener] The listener function.
  void onUpdate(EventCallback listener) {
    _socket!.json.on('channel:update', listener);
  }

  // TODO: Test

  /// Returns the members of the specified channel.
  ///
  /// > *If the client library key is set to **enforce session**, an active
  /// user session is required (e.g., user needs to be logged in) to call
  /// this method.*
  ///
  /// [channel] The name of the channel.
  ///
  /// Returns array of channel member data. If no channel members then
  /// returns and empty array []. If timeout exceed returns null.
  ///
  /// Throws an exception if `channel` is not specified
  Future<List<MemberData>?> getMembers(String channel) async {
    checkRequired('channel', channel);
    var completer = Completer<dynamic>();

    // _socket!.json.once('members', (data) {
    //   completer.complete(data);
    // });

    _socket!.json.emit('members', <String, dynamic>{'channel': channel});

    var res =
        await completer.future.timeout(const Duration(milliseconds: timout));

    if (res != null) {
      return (res as List)
          .map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  // TODO: Test

  //ignore_for_file: lines_longer_than_80_chars

  /// Registers a method to listen to main user events. The following events
  /// will be listened:
  ///
  /// | Event | Description |
  /// | :--- | :--- |
  /// | user:signin |  Triggered whenever a new user session is created. |
  /// | user:signout | Triggered when a user session is deleted. If {@link AuthManager.signOutAll} or {@link AuthManager.signOutAllExceptCurrent} method is called then for each deleted sesssion a separate `user:signout` event is triggered. |
  /// | user:update | Triggered whenever user data changes including password, email and phone number updates. |
  /// | user:delete | Triggered when the user data is deleted from the database. |
  /// | user:pwdchange |  Triggered when the user password changes, either through direct password update or password reset. |
  /// | user:emailchange |  Triggered whenever the email of the user changes. |
  /// | user:phonechange |  Triggered whenever the phone number of the user changes. |
  ///
  /// > *Please note that `user:update` and `user:delete` events are fired only when a specific user with a known _id is updated or deleted in the database. For bulk user update or delete operations these events are not fired.*
  /// @param {ListenerFunction} listener The listener function. This function gets two input parameters the name of the event that is being triggered and the user session object that has triggered the event. If the event is triggered by the user without a session, then the session value will be `null`.
  /// @returns {void}
  void onUserEvent(UserEventListenerFunction listener) {
    var events = UserEvent.values.map((e) => 'user:${e.name}').toList();

    void baseListener(dynamic data) {
      var dataList = data as List<dynamic>;
      var session = dataList[1] as Map<String, dynamic>?;
      var event = dataList[0] as String;
      listener(UserEvent.values[events.indexOf(event)],
          session != null ? Session.fromJson(session) : null);
    }

    for (var event in events) {
      _socket!.json.on(event, baseListener);
    }
  }
}

enum UserEvent {
  signin,
  signout,
  update,
  delete,
  pwdchange,
  emailchange,
  phonechange,
}
