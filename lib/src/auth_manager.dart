import 'dart:convert';

import '../altogic_dart.dart';
import 'utils/platform_auth/stub_auth.dart'
    if (dart.library.html) 'utils/platform_auth/web_auth.dart'
    if (dart.library.io) 'utils/platform_auth/io_auth.dart' show setRedirect;

/// Handles the authentication process of your application users.
/// Provides methods to manage users, sessions and authentication.
///
/// You are free to design the way to authenticate your users and manage
/// sessions in Altogic through defining your custom services. However,
/// by default Altogic provides three methods to manage user accounts
/// through the client library.
///
/// ### 1. Email and password based account management:
/// This is the default authentication method and it requires email address
/// validation. You can customize to enable/disable email confirmations, use
/// your own SMTP server to send email (by default signup email confirmation
/// emails are sent from noreply@mail.app.altogic.com domain) and define your
/// email templates.
///
///
/// ### 2. Phone number and password based account management:
/// You can also allow your uses to sign up using their phone numbers and
/// validate these phone numbers by sending a validation code through SMS.
/// In order to use this method of authentication, you need to configure the
/// SMS provider. Altogic currently supports Twilio, MessageBird, and Vonage
/// for sending SMS messages.
///
///
/// ### 3. Authentication through 3rd party Oauth providers:
/// Such as Google,Facebook, Twitter, GitHub, Discord: This method enables to
/// run the oauth flow of specific provider in your front-end applications.
/// In order to use this method you need to make specific configuration at the
/// provider to retrieve client id and client secret.
///
/// To use any of the above authentication methods you need to configure your
/// app authentication settings. You can customize these settings in Altogic
/// designer under **App Settings/Authentication**.
class AuthManager extends APIBase {
  /// Creates an instance of [AuthManager] to manage your application users and
  /// user sessions.
  ///
  /// [fetcher] The http client to make RESTful API calls to the
  /// application's execution engine
  ///
  /// [clientOptions] Altogic client options
  AuthManager(Fetcher fetcher, ClientOptions clientOptions)
      : _localStorage = clientOptions.localStorage,
        _singInRedirect = clientOptions.signInRedirect,
        super(fetcher);

  /// Storage handler to manage local user and session data
  final ClientStorage? _localStorage;

  /// Sign in page url to redirect when the user's session becomes invalid
  final String? _singInRedirect;

  /// Deletes the currently active session and user data in local storage.
  Future<void> _deleteLocalData() async {
    if (_localStorage != null) {
      await _localStorage!.removeItem('session');
      await _localStorage!.removeItem('user');
    }
  }

  /// Saves the session and user data to the local storage.
  /// [user] The user data
  /// [session] The session data
  Future<void> _saveLocalData(User user, Session session) async {
    if (_localStorage != null) {
      await _localStorage!.setItem('session', json.encode(session.toJson()));
      await _localStorage!.setItem('user', json.encode(user.toJson()));
    }
  }

  /// By default Altogic saves the session and user data in local storage
  /// whenever a new session is created (e.g., through sign up or sign in
  /// methods). This method clears the locally saved session and user data.
  /// In contrast to [invalidateSession], this method does not clear
  /// **Session** token request header in [Fetcher] and does not redirect
  /// to a sign in page.
  Future<void> clearLocalData() => _deleteLocalData();

  /// Invalidates the current user session, removes local session data, and
  /// clears **Session** token request header in [Fetcher].
  /// If **signInRedirect** is specified in [ClientOptions]
  /// when creating the Altogic api client and if the client is running
  /// in a browser, redirects the user to the sign in page.
  Future<void> invalidateSession() async {
    await _deleteLocalData();
    fetcher.clearSession();
    if (_singInRedirect != null) {
      setRedirect(_singInRedirect);
    }
  }

  /// Returns the currently active session data from local storage.
  Future<Session?> getSession() async {
    if (_localStorage != null) {
      var session = await _localStorage!.getItem('session');

      if (session != null) {
        return Session.fromJson(json.decode(session) as Map<String, dynamic>);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Returns the user data from local storage.
  Future<User?> getUser() async {
    if (_localStorage != null) {
      var user = await _localStorage!.getItem('user');
      if (user != null) {
        return User.fromJson(json.decode(user) as Map<String, dynamic>);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Sets (overrides) the active user session. If you use the *signUp* or
  /// *signIn* methods of this client library, you do not need to call this
  /// method to set the user session, since the client library automatically
  /// manages user session data.
  ///
  /// However if you have more complex sign up or sign in logic, such as 2
  /// factor authentication flow where you authenticate users using a short
  /// code, you might need to create your endpoints and associated services
  /// to handle these special cases. In those situations, this method becomes
  /// handy to update the session data of logged-in users so that the
  /// [Fetcher] can update its default headers to pass the correct
  /// session token in its RESTful API calls.
  ///
  /// When you use custom authentication logic in your apps, you need to
  /// call this service to update session data so that your calls to your
  /// app endpoints that require a valid session token do not fail.
  Future<void> setSession(Session session) async {
    fetcher.setSession(session);
    if (_localStorage != null) {
      await _localStorage!.setItem('session', json.encode(session.toJson()));
    }
  }

  /// Saves the user data to local storage. If you use the *signUp* or *signIn*
  /// methods of this client library, you do not need to call this method to set
  /// the user data, since the client library automatically manages user data.
  ///
  /// However, if you have not used the *signUp* or *signIn* methods of this
  /// client library, this method enables you to update locally stored user data
  Future<void> setUser(User user) async {
    if (_localStorage != null) {
      await _localStorage!.setItem('user', json.encode(user.toJson()));
    }
  }

  /// Sign up methods wrapper.
  Future<UserSessionResult> _signUp(
      String endpoint, String inputName, String input, String password,
      [dynamic nameOrUser]) async {
    checkRequired(inputName, input);
    checkRequired('password', password);

    assert(nameOrUser is String || nameOrUser is User || nameOrUser == null);

    var apiResponse = await fetcher
        .post<Map<String, dynamic>>('/_api/rest/v1/auth/$endpoint', body: {
      inputName: input,
      'password': password,
      if (nameOrUser is String) 'name': nameOrUser,
      if (nameOrUser is User) 'name': nameOrUser.toJson(),
    });

    if (apiResponse.errors != null) {
      return UserSessionResult(errors: apiResponse.errors);
    }

    var data = apiResponse.data!;

    var user = data['user'] == null
        ? null
        : User.fromJson(data['user'] as Map<String, dynamic>);

    var session = data['session'] == null
        ? null
        : Session.fromJson(data['session'] as Map<String, dynamic>);

    if (session != null) {
      await _deleteLocalData();
      await _saveLocalData(user!, session);
      fetcher.setSession(session);
    }

    return UserSessionResult(session: session, user: user);
  }

  /// Creates a new user using the email and password authentication
  /// method in the database.
  ///
  /// If email confirmation is **enabled** in your app authentication
  /// settings then a confirm sign up email will be sent to the user
  /// with a link to click and this method will return the user data with
  /// a `null` session. Until the user clicks this link, the email address
  /// will not be verified and a session will not be created. If a user tries
  /// to signIn to an account where email has not been confirmed yet, an error
  /// message will be returned asking for email verification.
  ///
  /// After user clicks on the link in confirmation email, Altogic
  /// verifies the verification token sent in the email and if the email is
  /// verified successfully redirects the user to the redirect URL specified
  /// in app authentication settings with an `access_token`. You can use this
  /// `access_token` token to get authentication grants, namely the user data
  /// and a new session object by calling the [getAuthGrant] method.
  ///
  /// If email confirmation is **disabled**, a newly created session object
  /// with the user data will be returned.<br>
  /// [email] Unique email address of the user. If there is
  /// already a user with the provided email address then an error is raised.
  /// <br>
  /// [password] Password of the user, should be at least 6 characters long <br>
  ///
  /// [nameOrUser] Name of the user or additional user data associated
  /// with the user that is being created in the database. Besides the name of
  /// the user, you can pass additional user fields with values
  /// (except email and password)  to be created in the database.
  ///
  Future<UserSessionResult> signUpWithEmail(String email, String password,
          [dynamic nameOrUser]) async =>
      _signUp('signup-email', 'email', email, password, nameOrUser);

  /// Creates a new user using the mobile phone number and password
  /// authentication method in the database.
  ///
  /// If phone number confirmation is **enabled** in your app authentication
  /// settings then a confirmation code SMS will be sent to the phone and this
  /// method will return the user data and a `null` session. Until the user
  /// validates this code by calling [verifyPhone], the phone number
  /// will not be verified. If a user tries to signIn to an account where
  /// phone number has not been confirmed yet, an error message will be
  /// returned asking for phone number verification.
  ///
  /// If phone number confirmation is **disabled**, a newly created session
  /// object and the user data will be returned.<br>
  /// [phone] Unique phone number of the user. If there is
  /// already a user with the provided phone number then an error is raised.<br>
  /// [password] Password of the user, should be at least
  /// 6 characters long <br>
  ///
  /// [nameOrUser] Name of user or additional user data associated with the
  /// user that is being created in the database. Besides the name of the user,
  /// you can pass additional user fields with values
  /// (except phone and password) to be created in the database.
  ///
  Future<UserSessionResult> signUpWithPhone(String phone, String password,
          [dynamic nameOrUser]) async =>
      _signUp('signup-phone', 'phone', phone, password, nameOrUser);

  /// Sign in methods wrapper.
  Future<UserSessionResult> _signIn(
      String endpoint, String inputName, String input, String password) async {
    checkRequired(inputName, input);
    checkRequired('password', password);

    var apiResponse = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/auth/$endpoint',
        body: {inputName: input, 'password': password});

    if (apiResponse.errors != null) {
      return UserSessionResult(errors: apiResponse.errors);
    }

    var data = apiResponse.data!;

    var user = data['user'] == null
        ? null
        : User.fromJson(data['user'] as Map<String, dynamic>);

    var session = data['session'] == null
        ? null
        : Session.fromJson(data['session'] as Map<String, dynamic>);

    await _deleteLocalData();
    await _saveLocalData(user!, session!);
    fetcher.setSession(session);

    return UserSessionResult(session: session, user: user);
  }

  /// Log in an existing user using email and password. In order to use email
  /// and password based log in, the authentication provider needs to be
  /// Altogic, meaning a user with email and password credentials exists
  /// in the app database.
  ///
  /// If email confirmation is **enabled** in your app authentication
  /// settings and if the email of the user has not been verified yet,
  /// this method will return an error message.
  ///
  /// You cannot use this method to log in a user who has signed up with
  /// an Oauth2 provider such as Google, Facebook, Twitter etc.
  ///
  /// [email] Email of the user
  ///
  /// [password] Password of the user
  Future<UserSessionResult> signInWithEmail(String email, String password) =>
      _signIn('signin-email', 'email', email, password);

  /// Log in an existing user using phone number and password. In order to
  /// use phone and password based log in, the authentication provider
  /// needs to be Altogic, meaning a user with phone and password credentials
  /// exists in the app database.
  ///
  /// If phone number confirmation is **enabled** in your app authentication
  /// settings and if the phone of the user has not been verified yet, this
  /// method will return an error message.
  ///
  /// [phone] Phone of the user
  ///
  /// [password] Password of the user
  Future<UserSessionResult> signInWithPhone(String phone, String password) =>
      _signIn('signin-phone', 'phone', phone, password);

  /// Log in an existing user using phone number and SMS code (OTP - one time
  /// password) that is sent to the phone. In order to use phone and password
  /// based log in, the authentication provider needs to be Altogic, meaning a
  /// user with phone and password credentials exists in the app database and
  /// *sign in using authorization codes* needs to be **enabled** in your app
  /// authentication settings. Before calling this method, you need to call the
  /// [sendSignInCode] method to get the SMS code delivered to the phone.
  ///
  /// If successful, this method returns the authorization grants (e.g.,
  /// session object) of the user.
  ///
  /// If phone number confirmation is **enabled** in your app authentication
  /// settings and if the phone of the user has not been verified yet, this
  /// method will return an error message.
  ///
  /// [phone] Phone of the user
  ///
  /// [code] SMS code (OTP - one time password)
  Future<UserSessionResult> signInWithCode(String phone, String code) async {
    checkRequired('phone', phone);
    checkRequired('code', code);

    var queryString = encodeUriParameters({'code': code, 'phone': phone});

    var apiResponse = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/auth/signin-code$queryString');

    if (apiResponse.errors != null) {
      return UserSessionResult(errors: apiResponse.errors);
    }

    var data = apiResponse.data!;

    var user = data['user'] == null
        ? null
        : User.fromJson(data['user'] as Map<String, dynamic>);

    var session = data['session'] != null
        ? null
        : Session.fromJson(data['session'] as Map<String, dynamic>);

    await _deleteLocalData();
    await _saveLocalData(user!, session!);
    fetcher.setSession(session);

    return UserSessionResult(session: session, user: user);
  }

  /// Signs in a user using the Oauth2 flow of the specified provider. Calling
  /// this method with the name of the sign in provider will return a URL that
  /// user have to redirect.
  ///
  /// If the provider sign in completes successfully, Altogic directs the user
  /// to the redirect URL with an access token that you can use to fetch the
  /// authentication grants (e.g., user and session data).
  ///
  /// If you are using this package with Flutter, ``signInWithProviderFlutter``
  /// function will launch redirect URL automatically. Then, you can use the
  /// ``handleRedirectUri`` function in `onGenerateRoute` or
  /// `onGenerateInitialRoute` to get auth information when your application is
  /// opened again with the redirect URL you specified in the Altogic interface.
  ///
  /// To access the ``signInWithProviderFlutter`` and ``handleRedirectUri``
  /// methods, you must import the altogic_flutter package.
  ///
  /// If this is the first time a user is using this provider then a new user
  /// record is created in the database, otherwise the lastLoginAt field value
  /// of the existing user record is updated.
  ///
  /// [provider] can be :
  ///   "google" |
  ///   "facebook" |
  ///   "twitter" |
  ///   "discord" |
  ///   "github"
  String signInWithProvider(String provider) =>
      '${fetcher.getBaseUrl()}/_auth/$provider';

  /// If an input token is <u>not</u> provided, signs out the user from the
  /// current session, clears user and session data in local storage and
  /// removes the **Session** header in [Fetcher]. Otherwise, signs out
  /// the user from the session identified by the input token.
  ///
  /// > An active user session is required (e.g., user needs to be logged in)
  /// to call this method.
  ///
  /// [sessionToken] Session token which uniquely identifies a user session.
  Future<APIError?> signOut({String? sessionToken}) async {
    try {
      var response = await fetcher.post<dynamic>('/_api/rest/v1/auth/signout');

      var session = await getSession();

      if (response.errors != null &&
          (sessionToken == null ||
              (session != null && sessionToken == session.token))) {
        await _deleteLocalData();
        fetcher.clearSession();
      }

      return response.errors;
    } on Exception {
      return null;
    }
  }

  /// A user can have multiple active sessions (e.g., logged in form multiple
  /// different devices, browsers). This method signs out users from all their
  /// active sessions. For the client that triggers this method, also clears
  /// user and session data in local storage, and removes the **Session**
  /// header in [Fetcher].
  ///
  /// > An active user session is required (e.g., user needs to be logged in)
  /// to call this method.
  Future<APIError?> signOutAll() async {
    var response =
        await fetcher.post<dynamic>('/_api/rest/v1/auth/signout-all');

    if (response.errors != null) {
      await _deleteLocalData();
      fetcher.clearSession();
    }

    return response.errors;
  }

  /// Signs out users from all their active sessions except the current one
  /// which makes the api call.
  ///
  /// > An active user session is required (e.g., user needs to be logged
  /// in) to call this method.
  Future<APIError?> signOutAllExceptCurrent() async {
    var response =
        await fetcher.post<dynamic>('/_api/rest/v1/auth/signout-all-except');

    return response.errors;
  }

  /// Gets all active sessions of a user.
  ///
  /// > An active user session is required (e.g., user needs to be logged in)
  /// to call this method.
  Future<SessionResult> getAllSessions() async {
    var res = await fetcher.get<List<dynamic>>('/_api/rest/v1/auth/sessions');
    return SessionResult(
        sessions: res.errors != null
            ? res.data!
                .map((e) => Session.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        errors: res.errors);
  }

  /// Retrieves the user associated with the active session from the database.
  ///
  /// > An active user session is required (e.g., user needs to be logged in)
  /// to call this method.
  Future<UserResult> getUserFromDB() async {
    var res =
        await fetcher.get<Map<String, dynamic>>('/_api/rest/v1/auth/user');
    return UserResult(
        user: res.data != null ? User.fromJson(res.data!) : null,
        errors: res.errors);
  }

  /// Changes the password of the user.
  ///
  /// > An active user session is required (e.g., user needs to be
  /// logged in) to call this method.
  /// [newPassword] The new password of the user
  /// [oldPassword] The current password of the user
  Future<APIError?> changePassword(
      String newPassword, String oldPassword) async {
    var res = await fetcher.post<dynamic>('/_api/rest/v1/auth/change-pwd',
        body: {'newPassword': newPassword, 'oldPassword': oldPassword});
    return res.errors;
  }

  /// Retrieves the authorization grants of a user using the specified input
  /// [accessToken]. If no [accessToken] specified as input, tries to retrieve
  /// the [accessToken] from the browser url query string parameter named
  /// 'access_token'. So on Flutter (if you don't use dart webdev),
  /// [accessToken] cannot be null. Else, throws UnsupportedError.
  ///
  /// If successful this method also saves the user and session data to local
  /// storage and sets the **Session** header in [Fetcher]
  ///
  /// [accessToken] The access token that will be used to get
  /// the authorization grants of a user
  Future<UserSessionResult> getAuthGrant([String? accessToken]) async {
    var tokenStr = accessToken ?? getParamValue('access_token');

    var res = await fetcher.get<Map<String, dynamic>>(
        '/_api/rest/v1/auth/grant?key=${tokenStr ?? ""}');

    if (res.errors != null) return UserSessionResult(errors: res.errors);

    var userSession = UserSessionResult(
        user: User.fromJson(res.data!['user'] as Map<String, dynamic>),
        session:
            Session.fromJson(res.data!['session'] as Map<String, dynamic>));

    await _deleteLocalData();
    await _saveLocalData(userSession.user!, userSession.session!);

    fetcher.setSession(userSession.session!);

    return userSession;
  }

  /// Resends the email to verify the user's email address. If the user's
  /// email has already been validated or email confirmation is **disabled**
  /// in your app authentication settings, it returns an error.
  ///
  /// [email] The email address of the user to send the verification email.
  Future<APIError?> resendVerificationEmail(String email) async =>
      (await fetcher.post<dynamic>('/_api/rest/v1/auth/resend?email=$email'))
          .errors;

  /// Resends the code to verify the user's phone number. If the user's phone
  /// has already been validated or phone confirmation is **disabled** in your
  /// app authentication settings, it returns an error.
  ///
  /// [phone] The phone number of the user to send the verification SMS code.
  Future<APIError?> resendVerificationCode(String phone) async =>
      (await fetcher.post<dynamic>(
              '/_api/rest/v1/auth/resend-code${encodeUriParameters({
            'phone': phone
          })}'))
          .errors;

  /// Sends a magic link to the email of the user.
  ///
  /// This method works only if email confirmation is **enabled** in your app
  /// authentication settings and the user's email address has already been
  /// verified.
  ///
  /// When the user clicks on the link in email, Altogic verifies the validity
  /// of the magic link and if successful redirects the user to the redirect
  /// URL specified in you app authentication settings with an access token in
  /// a query string parameter named 'access_token.' You can call [getAuthGrant]
  /// method with this access token to create a new session object.
  ///
  /// If email confirmation is **disabled** in your app authentication settings
  /// or if the user's email has not been verified, it returns an error.
  ///
  /// [email] The email address of the user to send the verification email.
  Future<APIError?> sendMagicLinkEmail(String email) async => (await fetcher
          .post<dynamic>('/_api/rest/v1/auth/send-magic?email=$email'))
      .errors;

  /// Sends an email with a link to reset password.
  ///
  /// This method works only if email confirmation is **enabled** in your app
  /// authentication settings and the user's email address has already been
  /// verified.
  ///
  /// When the user clicks on the link in email, Altogic verifies the validity
  /// of the reset-password link and if successful redirects the user to the
  /// redirect URL specified in you app authentication settings with an access
  /// token in a query string parameter named 'access_token.' At this state your
  /// app needs to detect `action=reset-pwd` in the redirect URL and display
  /// a password reset form to the user. After getting the new password from
  /// the user, you can call [resetPwdWithToken] method with the access
  /// token and new password to change the password of the user.
  ///
  /// If email confirmation is **disabled** in your app authentication settings
  /// or if the user's email has not been verified, it returns an error.
  ///
  /// [email] The email address of the user to send the verification email.
  Future<APIError?> sendResetPwdEmail(String email) async => (await fetcher
          .post<dynamic>('/_api/rest/v1/auth/send-reset?email=$email'))
      .errors;

  /// Sends an SMS code to reset password.
  ///
  /// This method works only if phone number confirmation is **enabled** in your
  /// app authentication settings and the user's phone number has already been
  /// verified.
  ///
  /// After sending the SMS code, you need to display a password reset form to
  /// the user. When you get the new password from the user, you can call
  /// [resetPwdWithCode] method with the phone number of the user,
  /// SMS code and new password.
  ///
  /// If phone number confirmation is **disabled** in your app authentication
  /// settings or if the user's phone has not been verified, it returns an error
  ///
  /// [phone] The phone number of the user to send the reset password code.
  Future<APIError?> sendResetPwdCode(String phone) async =>
      (await fetcher.post<dynamic>(
              '/_api/rest/v1/auth/send-reset${encodeUriParameters({
            "phone": phone
          })}'))
          .errors;

  /// Sends an SMS code (OTP - one time password) that can be used to sign in
  /// to the phone number of the user.
  ///
  /// This method works only if sign in using authorization codes is **enabled**
  /// in your app authentication settings and the user's phone number has
  /// already been verified.
  ///
  /// After getting the SMS code you can call the [signInWithCode] method.
  /// Altogic verifies the validity of the code and if successful returns the
  /// auth grants (e.g., session) of the user.
  ///
  /// If sign in using authorization codes is **disabled** in your app
  /// authentication settings or if the user's phone has not been verified,
  /// it returns an error.
  ///
  /// [phone] The phone number of the user to send the SMS code.
  Future<APIError?> sendSignInCode(String phone) async =>
      (await fetcher.post<dynamic>(
              '/_api/rest/v1/auth/send-code${encodeUriParameters({
            "phone": phone
          })}'))
          .errors;

  /// Resets the password of the user using the access token provided through
  /// the [sendResetPwdEmail] flow.
  ///
  /// [accessToken] The access token that is retrieved from
  /// the redirect URL query string parameter
  ///
  /// [newPassword] The new password of the user
  Future<APIError?> resetPwdWithToken(
          String accessToken, String newPassword) async =>
      (await fetcher.post<dynamic>(
              '/_api/rest/v1/auth/reset-pwd?key=$accessToken',
              body: {'newPassword': newPassword}))
          .errors;

  /// Resets the password of the user using the SMS code provided through the
  /// [sendResetPwdCode] method.
  ///
  /// [phone] The phone number of the user
  /// [code] The SMS code that is sent to the users phone number
  /// [newPassword] The new password of the user
  Future<APIError?> resetPwdWithCode(
          String phone, String code, String newPassword) async =>
      (await fetcher.post<dynamic>(
              '/_api/rest/v1/auth/reset-pwd-code${encodeUriParameters({
                    'phone': phone,
                    'code': code
                  })}',
              body: {'newPassword': newPassword}))
          .errors;

  /// Changes the email of the user to a new one.
  ///
  /// If email confirmation is **disabled** in your app authentication settings,
  /// it immediately updates the user's email and returns back the updated user
  /// data.
  ///
  /// If email confirmation is **enabled** in your app authentication settings,
  /// it sends a confirmation email to the new email address with a link for the
  /// user to click and returns the current user's info. Until the user clicks
  /// on the link, the user's email address will not be changed to the new one.
  ///
  /// > *An active user session is required (e.g., user needs to be logged in)
  /// to call this method.*
  ///
  /// [currentPassword] The password of the user
  ///
  /// [newEmail] The new email address of the user
  Future<UserResult> changeEmail(
      String currentPassword, String newEmail) async {
    var res = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/auth/change-email',
        body: {'currentPassword': currentPassword, 'newEmail': newEmail});

    return UserResult(
        errors: res.errors,
        user: res.errors != null
            ? User.fromJson((res.data!)['user'] as Map<String, dynamic>)
            : null);
  }

  /// Changes the phone number of the user to a new one.
  ///
  /// If phone number confirmation is **disabled** in your app authentication
  /// settings, it immediately updates the user's phone number and returns back
  /// the updated user data.
  ///
  /// If phone number confirmation is **enabled** in your app authentication
  /// settings, it sends a confirmation SMS code to the new phone number and
  /// returns the current user's info. After sending the SMS code by calling
  /// this method, you need to show a form to the user to enter this SMS code
  /// and call [verifyPhone] method with the new phone number and the code to
  /// change user's phone number to the new one.
  ///
  /// > *An active user session is required (e.g., user needs to be logged in)
  /// to call this method.*
  ///
  /// [currentPassword] The password of the user
  ///
  /// [newPhone] The new phone number of the user
  Future<UserResult> changePhone(
      String currentPassword, String newPhone) async {
    var res = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/auth/change-phone',
        body: {'currentPassword': currentPassword, 'newPhone': newPhone});

    return UserResult(
        errors: res.errors,
        user: res.errors != null
            ? User.fromJson((res.data!)['user'] as Map<String, dynamic>)
            : null);
  }

  /// Verifies the phone number using code sent in SMS and if verified, returns
  /// the auth grants (e.g., user and session data) of the user if the phone is
  /// verified due to a new sign up. If the phone is verified using the code
  /// send as a result of calling the [changePhone] method, returns the updated
  /// user data only.
  ///
  /// If the code is invalid or expired, it returns an error message.
  ///
  /// [phone] The mobile phone number of the user where the SMS code was sent.
  ///
  /// [code] The code sent in SMS (e.g., 6-digit number).
  Future<UserSessionResult> verifyPhone(String phone, String code) async {
    var res = await fetcher.post<Map<String, dynamic>>(
        '/_api/rest/v1/auth/verify-phone${encodeUriParameters({
          'code': code,
          'phone': phone
        })}');

    if (res.errors != null) return UserSessionResult(errors: res.errors);
    var data = res.data!;
    var user = User.fromJson(data['user'] as Map<String, dynamic>);
    if (data['session'] != null) {
      var session = Session.fromJson(data['session'] as Map<String, dynamic>);
      await _deleteLocalData();
      await _saveLocalData(user, session);
      fetcher.setSession(session);
      return UserSessionResult(user: user, session: session);
    } else {
      return UserSessionResult(user: user);
    }
  }
}
