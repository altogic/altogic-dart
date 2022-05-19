import 'dart:html';

void setRedirect(String? singInRedirect) {
  if (singInRedirect != null) {
    window.location.href = singInRedirect;
  }
}
