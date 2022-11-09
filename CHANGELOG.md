## 0.0.9+3

- [AltogicClient.restoreLocalAuthSession] name changed to [AltogicClient.restoreAuthSession]. Because it can restore session from local storage or from a deep link in flutter.
- [AuthManager] constructor now takes only [AltogicClient].
- platform_auth removed
- [ClientOptions.signInRedirect] now is a [void Function()]. (In Flutter, it is called with a [BuildContext] parameter)
- Added ([]) and ([]=) operators to [User] for custom fields.
- Many documentation improvements.

## 0.0.9+2

- Code format

## 0.0.9+1

- New parameter policy: If any method has only one optional parameter, the parameter is positioned. And if any method has multiple optional parameters, the parameters are named.


## 0.0.9

- Bug Fixes
- Preparing to release

## 0.0.6

- Bug fixes
- ``APIError.toJson`` added

## 0.0.5

- Bug fixes

## 0.0.4

- Many casting errors fixed
- RealtimeManager added

## 0.0.3+3

- File delete fix

## 0.0.3+2

- Readme updated.
- Fixes on web.

## 0.0.3+1

- `APIResponse`, `KeyListResult` , `SessionResult` , `UserResult`, `UserSessionResult` extends from `APIResponseBase`


## 0.0.3

- Readme Wrote.
- Casting errors fixed.

## 0.0.2

- Tested all platforms

## 0.0.1

- Initial version.
