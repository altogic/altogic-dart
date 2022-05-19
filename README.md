# Altogic Client Library

Javascript client for Altogic backend apps.

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

## Quick start

This guide will show you how to use the key modules of the client library to execute commands in your backend app. For
more in-depth coverage, see the
[Client API reference](https://clientapi.altogic.com/v1.3.1/modules.html).

## Tested

Section / Platform Tests

| Section        | Implemented | IO      | Browser |
|----------------|-------------|---------|---------|
| Auth           | &#9745;     | &#9745; | &#9744; |
| Auth Providers | &#9744;     | &#9744; | &#9744; |
| Database       | &#9745;     | &#9745; | &#9744; |
| Storage        | &#9745;     | &#9744; | &#9744; |
| Endpoint       | &#9745;     | &#9744; | &#9744; |
| Queue          | &#9745;     | &#9744; | &#9744; |
| Task           | &#9745;     | &#9744; | &#9744; |


## TODO

- [x] Write Base Implementation
- [ ] Implement Cookie
- [ ] Implement auth provider
- [ ] Create local storage package for flutter
- [ ] Test all platforms
- [ ] Write new readme.md
- [ ] Check all documentation
- [ ] Publish version 1.0

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

  //... after email address verified, you can get user and session data using the accessToken
  var authGrant = await altogic.auth.getAuthGrant(accessToken);

  //After the users are created and their email verified, the next time the users wants to sign in to their account, you can use the sign in method to authenticate them
  var userSession = await altogic.auth.signInWithEmail(email, password);
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
  var userSession = await altogic.auth.verifyPhone(phone, code);

//After the users are created and their phones numbers are verified, the next time the users wants to sign in to their account, you can use the sign in method to authenticate them
  var errors = await altogic.auth.signInWithPhone(phone, password);
}
```

[//]: # (#### **Sign up/sign-in users with an oAuth provider:**)

[//]: # ()

[//]: # (Signs in a user using the Oauth2 flow of the specified provider. Calling this method with the name of the sign in)

[//]: # (provider will redirect user to the relevant login page of the provider. If the provider sign in completes successfully,)

[//]: # (Altogic directs the user to the redirect URL with an)

[//]: # (`access_token` as query string parameter that you can use to fetch the authentication grants &#40;e.g., user and session)

[//]: # (data&#41;. Please note that you need to make specific configuration at the provider to retrieve client id and client secret)

[//]: # (to use this method.)

[//]: # ()

[//]: # (```js)

[//]: # (//Sign in or sign up a user using Google as the oAuth provider)

[//]: # (altogic.auth.signInWithProvider&#40;'google'&#41;;)

[//]: # ()

[//]: # (//... after oAuth provider sign-in, you can get user and session data using the accessToken)

[//]: # (const {user, session, errors} = await altogic.auth.getAuthGrant&#40;accessToken&#41;;)

[//]: # (```)

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

  if (response != null) {
    //success
    print(response.data);
  }
}
```

[//]: # ()
[//]: # (Or you can use an object manager:)

[//]: # ()
[//]: # (```js)

[//]: # (//Insert a new top-level model object to the database using the object manager)

[//]: # (const {data, errors} = await altogic.db.model&#40;'userOrders'&#41;.object&#40;&#41;.create&#40;{)

[//]: # (    productId: 'prd000234',)

[//]: # (    quantity: 12,)

[//]: # (    customerId: '61fbf6ceeeed063ab062ac05',)

[//]: # (    createdAt: '2022-02-09T10:55:34.562+00:00',)

[//]: # (}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (#### **Update an object:**)

[//]: # ()
[//]: # (You can use two ways to update an object in the database. You can use an object manager shown below to update an object.)

[//]: # ()
[//]: # (```js)

[//]: # (//Upates a users address identified by '61f958dc3692b8462a9d31a1' to a new one)

[//]: # (const {data, errors} = await altogic.db)

[//]: # (    .model&#40;'users.address'&#41;)

[//]: # (    .object&#40;'61f958dc3692b8462a9d31a1'&#41;)

[//]: # (    .update&#40;{)

[//]: # (        city: 'Chicago',)

[//]: # (        street: '1234 W Chestnut',)

[//]: # (        zipcode: '60610',)

[//]: # (        state: 'IL',)

[//]: # (        country: 'US',)

[//]: # (    }&#41;;)

[//]: # ()
[//]: # (//Increments the likeCount of a wallpost identified by id '62064c7eff64b91975a599b4' by 1)

[//]: # (const {data, errors} = await altogic.db)

[//]: # (    .model&#40;'wallposts'&#41;)

[//]: # (    .object&#40;'62064c7eff64b91975a599b4'&#41;)

[//]: # (    .updateFields&#40;{field: 'likeCount', updateType: 'increment', value: 1}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (Or you can use a query manager to perform update operation. Below examples perform exactly the same updates as the above)

[//]: # (methods.)

[//]: # ()
[//]: # (```js)

[//]: # (//Upates the an object using a query builder)

[//]: # (const result = await altogic.db)

[//]: # (    .model&#40;'users.address'&#41;)

[//]: # (    .filter&#40;'_id == "61f958dc3692b8462a9d31a1"'&#41;)

[//]: # (    .update&#40;{)

[//]: # (        city: 'Chicago',)

[//]: # (        street: '1234 W Chestnut',)

[//]: # (        zipcode: '60610',)

[//]: # (        state: 'IL',)

[//]: # (        country: 'US',)

[//]: # (    }&#41;;)

[//]: # ()
[//]: # (//Increments the likeCount of a wallpost identified by id '62064c7eff64b91975a599b4' by 1 using the query builder)

[//]: # (const {data, errors} = await altogic.db)

[//]: # (    .model&#40;'wallposts'&#41;)

[//]: # (    .filter&#40;'_id == "62064c7eff64b91975a599b4"'&#41;)

[//]: # (    .updateFields&#40;{field: 'likeCount', updateType: 'increment', value: 1}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (#### **Delete an object:**)

[//]: # ()
[//]: # (```js)

[//]: # (//Delete an order identified by id '62064163ae99b3a645705667' from userOrders)

[//]: # (const {errors} = await altogic.db.model&#40;'userOrders'&#41;.object&#40;'62064163ae99b3a645705667'&#41;.delete&#40;&#41;;)

[//]: # ()
[//]: # (//Alternatively you can use a query builder to delete an object)

[//]: # (const {errors} = await altogic.db)

[//]: # (    .model&#40;'userOrders'&#41;)

[//]: # (    .filter&#40;'_id == "62064163ae99b3a645705667"'&#41;)

[//]: # (    .delete&#40;&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (#### **Query data:**)

[//]: # ()
[//]: # (```js)

[//]: # (//Gets the first 100 orders with basket size greater than $50 and having more than 3 items and sorts them by descending orderDate)

[//]: # (await altogic.db)

[//]: # (    .model&#40;'userOrders'&#41;)

[//]: # (    .filter&#40;'totalAmount > 50 && totalQuantity > 3'&#41;)

[//]: # (    .sort&#40;'orderDate', 'desc'&#41;)

[//]: # (    .limit&#40;100&#41;)

[//]: # (    .page&#40;1&#41;)

[//]: # (    .get&#40;&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (### RESTful Endpoints &#40;i.e., cloud functions&#41;)

[//]: # ()
[//]: # (In Altogic, you can define your app RESTful endpoints and associted services. You can think of services as your cloud)

[//]: # (functions and you define your app services in Altogic Designer. When the endpoint is called, the associated service &#40;)

[//]: # (i.e., cloud function&#41; is executed. The client library endpoints module provide the methods to make POST, PUT, GET and)

[//]: # (DELETE requests to your app endpoints.)

[//]: # ()
[//]: # (```js)

[//]: # (//Make a GET request to /orders/{orderId} endpoint)

[//]: # (//...)

[//]: # (let orderId = '620949ee991edfba3ee644e7';)

[//]: # (const {data, errors} = await altogic.endpoint.get&#40;`/orders/${orderId}`&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (```js)

[//]: # (//Make a POST request to /wallposts/{postId}/comments endpoint)

[//]: # (//...)

[//]: # (let postId = '62094b43f7205e7d78082504';)

[//]: # (const {data, errors} = await altogic.endpoint.post&#40;`/wallposts/${postId}/comments`, {)

[//]: # (    userId: '620949ee991edfba3ee644e7',)

[//]: # (    comment: 'Awesome product. Would be better if you could add tagging people in comments.',)

[//]: # (}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (```js)

[//]: # (//Make a DELETE request to /wallposts/{postId}/comments/{commentId} endpoint)

[//]: # (//...)

[//]: # (let postId = '62094b4dfcc106baba52c8ec';)

[//]: # (let commentId = '62094b66fc475bdd5a2bfa48';)

[//]: # (const {data, errors} = await altogic.endpoint.delete&#40;`/wallpost/${postId}/comments/${commentId}`&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (```js)

[//]: # (//Make a PUT request to /users/{userId}/address)

[//]: # (//...)

[//]: # (let userId = '62094b734848b88ff50c2ab0';)

[//]: # (const {data, errors} = await altogic.endpoint.put&#40;`/users/${userId}/address`, {)

[//]: # (    city: 'Chicago',)

[//]: # (    street: '121 W Chestnut',)

[//]: # (    zipcode: '60610',)

[//]: # (    state: 'IL',)

[//]: # (    country: 'US',)

[//]: # (}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (### Document storage)

[//]: # ()
[//]: # (This module allows you manage your app's cloud storage buckets and files. You store your files, documents, images etc.)

[//]: # (under buckets, which are the basic containers that hold your application data. You typically create a bucket and upload)

[//]: # (files/objects to this bucket.)

[//]: # ()
[//]: # (#### **Create a bucket:**)

[//]: # ()
[//]: # (```js)

[//]: # (/*)

[//]: # (Creates a bucket names profile-images with default privacy setting of public, meaning that when you add a file to a bucket and if the file did not specify public/private setting, then it will be marked as publicly accessible through its URL)

[//]: # (*/)

[//]: # (await altogic.storage.createBucket&#40;'profile-images', true&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (#### **Upload a file:**)

[//]: # ()
[//]: # (```js)

[//]: # (//Uploads a file to the profiles-images bucket)

[//]: # (const fileToUpload = event.target.files[0];)

[//]: # (const result = await altogic.storage)

[//]: # (    .bucket&#40;'profile-images'&#41;)

[//]: # (    .upload&#40;fileToUpload.name, fileToUpload&#41;;)

[//]: # ()
[//]: # (//If you would like to have a progress indicator during file upload you can also provide a callback function)

[//]: # (const result = await altogic.storage)

[//]: # (    .bucket&#40;'profile-images'&#41;)

[//]: # (    .upload&#40;fileToUpload.name, fileToUpload, {)

[//]: # (        onProgress: &#40;uploaded, total, percent&#41; =>)

[//]: # (            console.log&#40;`progress: ${uploaded}/${total} ${percent}`&#41;,)

[//]: # (    }&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (#### **List files in a bucket:**)

[//]: # ()
[//]: # (```js)

[//]: # (//Returns the list of files in bucket profile-images sorted by their size in ascending order)

[//]: # (const result = await altogic.storage.bucket&#40;'profile-images'&#41;.listFiles&#40;{)

[//]: # (    returnCountInfo: true,)

[//]: # (    sort: {field: 'size', direction: 'asc'},)

[//]: # (}&#41;;)

[//]: # ()
[//]: # (/*)

[//]: # (You can also apply filters and paginate over the files. Below call returns the first 100 of files which are marked as public and sorted by their size in ascending order)

[//]: # (*/)

[//]: # (const result = await altogic.storage.bucket&#40;'profile-images'&#41;.listFiles&#40;'isPublic == true', {)

[//]: # (    returnCountInfo: true,)

[//]: # (    limit: 100,)

[//]: # (    page: 1,)

[//]: # (    sort: {field: 'size', direction: 'asc'},)

[//]: # (}&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (### Cache)

[//]: # ()
[//]: # (You can use the Altogic client library to cache simple key-value pairs at a high-speed data storage layer &#40;Redis&#41; to)

[//]: # (speed up data set and get operations.)

[//]: # ()
[//]: # (```js)

[//]: # (//Store items in cache)

[//]: # (const {errors} = await altogic.cache.set&#40;'lastUserOrder', {)

[//]: # (    productId: 'prd000234',)

[//]: # (    quantity: 12,)

[//]: # (    customerId: '61fbf6ceeeed063ab062ac05',)

[//]: # (    createdAt: '2022-02-09T10:55:34.562+00:00',)

[//]: # (}&#41;;)

[//]: # ()
[//]: # (//Get the item stored in cache)

[//]: # (const result = await altogic.cache.get&#40;'lastUserOrder'&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (### Message queue)

[//]: # ()
[//]: # (The queue manager allows different parts of your application to communicate and perform activities asynchronously. A)

[//]: # (message queue provides a buffer that temporarily stores messages and dispatches them to their consuming service. With)

[//]: # (the client library you can submit messages to a message queue for asychronous processing. After the message is)

[//]: # (submitted, the routed service defined in your message queue configuration is invoked. This routed service processes the)

[//]: # (input message and performs necessary tasks defined in its service flow.)

[//]: # ()
[//]: # (```js)

[//]: # (//Submit a message to a queuer for asychronous processing)

[//]: # (const {info, errors} = await altogic.queue.submitMessage&#40;queueName, messageBody&#41;;)

[//]: # ()
[//]: # (//Get the status of submitted message whether it has been completed processing or not)

[//]: # (const result = await altogic.queue.getMessageStatus&#40;info.messageId&#41;;)

[//]: # (```)

[//]: # ()
[//]: # (### Scheduled tasks &#40;i.e., cron jobs&#41;)

[//]: # ()
[//]: # (The client library task manager allows you to manually trigger service executions of your scheduled tasks which actually)

[//]: # (ran periodically at fixed times, dates, or intervals.)

[//]: # ()
[//]: # (Typically, a scheduled task runs according to its defined execution schedule. However, with Altogic's client library by)

[//]: # (calling the `runOnce` method, you can manually run scheduled tasks ahead of their actual execution schedule.)

[//]: # ()
[//]: # (```js)

[//]: # (//Manually run a task)

[//]: # (const {info, errors} = await altogic.queue.runOnce&#40;taskName&#41;;)

[//]: # ()
[//]: # (//Get the status of the manually triggered task whether it has been completed processing or not)

[//]: # (const result = await altogic.queue.getTaskStatus&#40;info.taskId&#41;;)

[//]: # (```)

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
