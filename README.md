# Altogic Client Library

Dart client for Altogic backend apps.

[Altogic](https://altogic.com) is a **backend application development and execution platform**, enabling people and
businesses to design, deploy and manage scalable applications. It simplifies application development by eliminating
repetitive tasks, providing pre-integrated and ready-to-use execution environments, and automating key stages in the
application development process.

For detailed API documentation go to
[Client API reference](https://clientapi.altogic.com/v1.3.1/modules.html)

## Installation

In order to use the Altogic client library you need to <u>create an app and a client key in Altogic</u>. Additionally,
if you will be using the Authentication module of this library, you might need to do additional configuration in your
app settings.

````commandline
dart pub add altogic-dart
````

And import it

````dart
import 'package:altogic-dart/altogic-dart.dart';
````

Then you can use it from a global `altogic` variable:


````dart
AltogicClient altogic = createClient('http://fqle-avzr.c1-na.altogic.com', 'client-key');
````


## Tested

Section / Platform Tests

| Section        | Implemented | IO      | Browser |
|----------------|-------------|---------|---------|
| Auth           | &#9745;     | &#9745; | &#9745; |
| Auth Providers | &#9745;     | &#9745; | &#9745; |
| Database       | &#9745;     | &#9745; | &#9745; |
| Storage        | &#9745;     | &#9745; | &#9745; |
| Endpoint       | &#9745;     | &#9745; | &#9745; |
| Queue          | &#9745;     | &#9745; | &#9745; |
| Task           | &#9745;     | &#9745; | &#9745; |

## TODO

- [x] Write Base Implementation
- [ ] Implement Cookie
- [x] Implement auth provider
- [x] Create local storage package for flutter
- [x] Test all platforms
- [ ] Write new readme.md
- [x] Check all documentation
- [ ] Publish version 1.0

## Quick start

This guide will show you how to use the key modules of the client library to execute commands in your backend app. For
more in-depth coverage, see the
[Client API reference](https://pub.dev/documentation/altogic_dart/latest/).

### Authentication

#### **Sign up new users with email:**

If email confirmation is **enabled** in your app authentication settings then a confirm sign up email will be sent to
the user with a link to click and this method will return the user data with a
`null` session. Until the user clicks this link, the email address will not be verified and a session will not be
created. After user clicks on the link in confirmation email, Altogic verifies the verification token sent in the email
and if the email is verified successfully redirects the user to the redirect URL specified in app authentication
settings with an `access_token` in query string parameter. You can use this `access_token` token to get authentication
grants, namely the user data and a new session object by calling the `getAuthGrant` method.

```dart
authFunctions() async {
  //Sign up a new user with email and password
  var errors = await altogic.auth.signUpWithEmail(email, password);

  if (errors != null) {
    // success
  }

  // After the users are created and their email verified, the next time the users wants to sign in to their account, you can use the sign in method to authenticate them
  var userSession = await altogic.auth.signInWithEmail(email, password);

  // You can check errors. If ``errors`` is null, signIn is success. 
  if (userSession.errors != null) {
    // success
    var user = userSession.user;
    var session = userSession.session;
  } else {
    // Error
  }

  //... after email address verified, you can get user and session data using the accessToken
  var authGrant = await altogic.auth.getAuthGrant(accessToken);
}
```

#### **Sign up new users with mobile phone number:**

If phone number confirmation is **enabled** in your app authentication settings then a confirmation code SMS will be
sent to the phone. Until the user validates this code by calling `verifyPhone`, the phone number will not be verified.

```dart
authFunction() async {
  //Sign up a new user with mobile phonec number and password
  var errors = await altogic.auth.signUpWithPhone(phone, password);

  if (errors != null) {
    // success
  }

  //Verify the phone number using code sent in SMS and and return the auth grants (e.g., session)
  UserSessionResult userSession = await altogic.auth.verifyPhone(phone, code);

  //The next time, the users wants to sign in to their account, you can use the sign in method to authenticate them
  UserSessionResult userSession = await altogic.auth.signInWithPhone(phone, password);
}
```

#### **Sign up/sign-in users with an oAuth provider:**

See [altogic_flutter](https://pub.dev/packages/altogic_flutter) package.

### Database

#### **Create a new object:**

To create a new object in one of your models in the database, you have two options. You can use the query manager shown
below:

```dart
createObject() async {
  //Insert a new top-level model object to the database using the query builder
  var response = await altogic.db.model('userOrders').create({
    productId: 'prd000234',
    quantity: 12,
    customerId: '61fbf6ceeeed063ab062ac05',
    createdAt: '2022-02-09T10:55:34.562+00:00',
  });

  // Or you can use `createMany` to create multiple object(s).

  if (response != null) {
    //success
    print(response.data); // created object
  }
}
```

Or you can use an object manager:

```dart
createObject() async {
  //Insert a new top-level model object to the database using the object manager
  var response = await altogic.db.model('userOrders').object().create({
    productId: 'prd000234',
    quantity: 12,
    customerId: '61fbf6ceeeed063ab062ac05',
    createdAt: '2022-02-09T10:55:34.562+00:00',
  });

  if (response != null) {
    //success
    print(response.data); // created object
  }
}
```

#### **Update an object:**

You can use two ways to update an object in the database. You can use an object manager shown below to update an object.

```dart
updateObject() async {
  //Upates a users address identified by '61f958dc3692b8462a9d31a1' to a new one
  var result = await altogic.db
      .model('users.address')
      .object('61f958dc3692b8462a9d31a1')
      .update({
    city: 'Chicago',
    street: '1234 W Chestnut',
    zipcode: '60610',
    state: 'IL',
    country: 'US',
  });

//Increments the likeCount of a wallpost identified by id '62064c7eff64b91975a599b4' by 1
  var result = await altogic.db
      .model('wallposts')
      .object('62064c7eff64b91975a599b4')
      .updateFields({ field: 'likeCount', updateType: 'increment', value: 1});
}
```

## Learn more

You can use the following resources to learn more and get help

- 🚀 [Quick start](https://docs.altogic.com/quick-start)
- 📜 [Altogic Docs](https://docs.altogic.com)
- 💬 Discord community

## Bugs Report

Think you’ve found a bug? Please, send us an email support@altogic.com

## Support / Feedback

For issues with, questions about, feedback for the client library, or want to see a new feature please, send us an email
support@altogic.com or reach out to our community forums
https://community.altogic.com
