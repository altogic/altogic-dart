import 'dart:html';

dynamic platformGetParamValue(String param) =>
    Uri.parse(window.location.href).queryParameters[param];
