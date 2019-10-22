import 'dart:convert';

Future<Map<String, dynamic>> parseJsonResponse(String response) async {
  Map<String, dynamic> json = jsonDecode(response);
  return json;
}
