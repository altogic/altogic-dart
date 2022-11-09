# Altogic Client Library

Dart client for Altogic backend apps.

[Altogic](https://altogic.com) is a **backend application development and execution platform**, enabling people and
businesses to design, deploy and manage scalable applications. It simplifies application development by eliminating
repetitive tasks, providing pre-integrated and ready-to-use execution environments, and automating key stages in the
application development process.

For detailed API documentation go to
[Client API reference](https://pub.dev/documentation/altogic_dart/latest/)

## Installation

In order to use the Altogic client library you need to <u>create an app and a client key in Altogic</u>. Additionally,
if you will be using the Authentication module of this library, you might need to do additional configuration in your
app settings.

````commandline
dart pub add altogic_dart
````

And import it

````dart
import 'package:altogic_dart/altogic_dart.dart';
````

Then you can use it from a global `altogic` variable:

````dart

AltogicClient altogic = createClient('http://fqle-avzr.c1-na.altogic.com', 'client-key');
````

## Quick start

This guide will show you how to use the key modules of the client library to execute commands in your backend app. For
more in-depth coverage, see the
[Client API reference](https://pub.dev/documentation/altogic_dart/latest/).

## Example

[Example/Test Application](https://github.com/yazmehmet/altogic_flutter_example)

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

> **Note:** Check [altogic package](https://pub.dev/packages/altogic) for learning how to handle redirect urls.

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
    'city': 'Chicago',
    'street': '1234 W Chestnut',
    'zipcode': '60610',
    'state': 'IL',
    'country': 'US',
  });

  //Increments the likeCount of a wallpost identified by id '62064c7eff64b91975a599b4' by 1
  var result = await altogic.db
      .model('wallposts')
      .object('62064c7eff64b91975a599b4')
      .updateFields(FieldUpdate(field: 'likeCount', updateType: UpdateType.increment, value: 1));
}
```

Or you can use a query manager to perform update operation. Below examples perform exactly the same updates as the above
methods.

```dart
updateObject() async {
  //Updates the an object using a query builder
  var result = await altogic.db
      .model('users.address')
      .filter('_id == "61f958dc3692b8462a9d31a1"')
      .update({
    'city': 'Chicago',
    'street': '1234 W Chestnut',
    'zipcode': '60610',
    'state': 'IL',
    'country': 'US',
  });

  //Increments the likeCount of a wallpost identified by id '62064c7eff64b91975a599b4' by 1 using the query builder
  var result = await altogic.db
      .model('wallposts')
      .filter('_id == "61f958dc3692b8462a9d31a1"')
      .updateFields(FieldUpdate(field: 'likeCount', updateType: UpdateType.increment, value: 1));
}
```

#### **Delete an object:**

```dart
deleteObject() async {
  //Delete an order identified by id '62064163ae99b3a645705667' from userOrders
  var result = await altogic.db.model('userOrders').object('62064163ae99b3a645705667').delete();

  //Alternatively you can use a query builder to delete an object
  var result = await altogic.db
      .model('userOrders')
      .filter('_id == "62064163ae99b3a645705667"')
      .delete();
}
```

#### **Query data:**

```dart
query() async {
  // Gets the first 100 orders with basket size greater than $50 and having more than 3 items and sorts them by descending orderDate
  await altogic.db
      .model('userOrders')
      .filter('totalAmount > 50 && totalQuantity > 3')
      .sort('orderDate', Direction.desc)
      .limit(100)
      .page(1)
      .get();
}
```

### RESTful Endpoints (i.e., cloud functions)

In Altogic, you can define your app RESTful endpoints and associted services. You can think of services as your cloud
functions and you define your app services in Altogic Designer. When the endpoint is called, the associated service (
i.e., cloud function) is executed. The client library endpoints module provide the methods to make POST, PUT, GET and
DELETE requests to your app endpoints.

```dart
get() async {
  //Make a GET request to /orders/{orderId} endpoint
  //...
  var orderId = '620949ee991edfba3ee644e7';
  var result = await altogic.endpoint.get('/orders/$orderId').asMap();
}
```

Endpoint methods (`get`,`post`,`put`,`delete`) returns a `FutureApiResponse`.

FutureApiResponse have a some methods like ``asMap()``. Which type of return your endpoint the methods are will cast to
that type. E.g. ``asMap()`` returns result as Future<APIResponse<Map<String,dynamic>>>. So you can read data
with ``var data = result.data``, the `data` is Map<String,dynamic>?.

```dart
post() async {
  //Make a POST request to /wallposts/{postId}/comments endpoint
//...
  var postId = '62094b43f7205e7d78082504';
  var result = await altogic.endpoint.post('/wallposts/$postId/comments', body: {
    'userId': '620949ee991edfba3ee644e7',
    'comment': 'Awesome product. Would be better if you could add tagging people in comments.',
  }).asMap();
}
```

```dart
delete() async {
  //Make a DELETE request to /wallposts/{postId}/comments/{commentId} endpoint
  //...
  var postId = '62094b4dfcc106baba52c8ec';
  var commentId = '62094b66fc475bdd5a2bfa48';
  var result = await altogic.endpoint.delete('/wallpost/$postId/comments/$commentId').asMap();
}
```

```dart
put() async {
  //Make a PUT request to /users/{userId}/address
  //...
  var userId = '62094b734848b88ff50c2ab0';
  var result = await altogic.endpoint
      .put('/users/$userId/address', body: {
    city: 'Chicago',
    street: '121 W Chestnut',
    zipcode: '60610',
    state: 'IL',
    country: 'US',
  }).asMap();
}
```

### Document storage

This module allows you manage your app's cloud storage buckets and files. You store your files, documents, images etc.
under buckets, which are the basic containers that hold your application data. You typically create a bucket and upload
files/objects to this bucket.

#### **Create a bucket:**

```dart
createBucket() async {
  //Creates a bucket names profile-images with default privacy setting of 
  //public, meaning that when you add a file to a bucket and if the file 
  //did not specify public/private setting, then it will be marked as 
  //publicly accessible through its URL
  await altogic.storage.createBucket('profile-images', isPublic: true);
}
```

#### **Upload a file:**

```dart

uploadFile() async {
  //Uploads a file to the profiles-images bucket
  var file = File('path/to/file');
  var bytesToUpload = await file.readAsBytesSync();
  var result = await altogic.storage
      .bucket('profile-images')
      .upload('file_name.ext', bytesToUpload);

  //If you would like to have a progress indicator during file upload you can also provide a callback function
  var result = await altogic.storage
      .bucket('profile-images')
      .upload(fileToUpload.name, fileToUpload, FileUploadOptions(
      onProgress: (uploaded, total, percent) =>
          print('progress: ${uploaded}/${total} ${percent}')
  ));
}

```

#### **List files in a bucket:**

```dart
listFiles() async {
  //Returns the list of files in bucket profile-images sorted by their size in ascending order
  var result = await altogic.storage.bucket('profile-images').listFiles(options: FileListOptions(
    returnCountInfo: true,
    sort: FileSort(FileSortField.size, direction: Direction.asc),
  ));

  //You can also apply filters and paginate over the files. Below call returns the first 100 of files which are marked as public and sorted by their size in ascending order.
  var result = await altogic.storage.bucket('profile-images').listFiles(
      expression: 'isPublic == true',
      options: FileListOptions(
        returnCountInfo: true,
        limit: 100,
        page: 1,
        sort: FileSort(field: FileSortField.size, direction: Direction.asc),
      ));
}
```

### Cache

You can use the Altogic client library to cache simple key-value pairs at a high-speed data storage layer (Redis) to
speed up data set and get operations.

```js
//Store items in cache
var result = await altogic.cache.set('lastUserOrder', {
    productId: 'prd000234',
    quantity: 12,
    customerId: '61fbf6ceeeed063ab062ac05',
    createdAt: '2022-02-09T10:55:34.562+00:00',
});

//Get the item stored in cache
const result = await altogic.cache.get('lastUserOrder');
```

### Message queue

The queue manager allows different parts of your application to communicate and perform activities asynchronously. A
message queue provides a buffer that temporarily stores messages and dispatches them to their consuming service. With
the client library you can submit messages to a message queue for asychronous processing. After the message is
submitted, the routed service defined in your message queue configuration is invoked. This routed service processes the
input message and performs necessary tasks defined in its service flow.

```dart
submitMessage() async {
  //Submit a message to a queuer for asychronous processing
  var result = await altogic.queue.submitMessage(queueName, messageBody);

  var info = result.info;

  //Get the status of submitted message whether it has been completed processing or not
  var result = await altogic.queue.getMessageStatus(info.messageId);
}
```

### Scheduled tasks (i.e., cron jobs)

The client library task manager allows you to manually trigger service executions of your scheduled tasks which actually
ran periodically at fixed times, dates, or intervals.

Typically, a scheduled task runs according to its defined execution schedule. However, with Altogic's client library by
calling the `runOnce` method, you can manually run scheduled tasks ahead of their actual execution schedule.

```dart
runOnce() async
{
  //Manually run a task
  var result = await altogic.queue.runOnce(taskName);

  var info = result.info;

//Get the status of the manually triggered task whether it has been completed processing or not
  var result = await altogic.queue.getTaskStatus(info.taskId);
}
```

## Learn more

You can use the following resources to learn more and get help

- 🚀 [Quick start](https://docs.altogic.com/quick-start)
- 📜 [Altogic Docs](https://docs.altogic.com)
- 💬 Discord community

## Bugs Report

Think you’ve found a bug? Please, send us an email support@altogic.com

Send to mehmedyaz@gmail.com for Dart/Flutter package bugs.

## Support / Feedback

For issues with, questions about, feedback for the client library, or want to see a new feature please, send us an email
support@altogic.com or reach out to our community forums
https://community.altogic.com
</br>

Mehmet Yaz

[Email](mailto://mehmedyaz@gmail.com) , [Twitter](https://twitter.com/smehmetyaz)
, [LinkedIn](https://www.linkedin.com/in/mehmetyaz/)