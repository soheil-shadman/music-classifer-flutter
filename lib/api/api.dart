// ignore_for_file: prefer_conditional_assignment

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mood_classifer/constants.dart';

class API {
  static API? Instance;

  static void Init() {
    Instance = API();
  }

  static String _apiBaseURL = "http://" + Constants.REAL_HOST + "/api/";

  String _makeApiURL(String path) {
    if (path.startsWith("/")) {
      path = path.substring(1);
    }
    return _apiBaseURL + path;
  }
  Map<String, String> _headers = { "Content-Type": 'application/json',"api-token":Constants.API_TOKEN};


  Future<APIResponse> get(String path) async {
    try {
      print("GET=>$path");
      var httpResponse =
          await http.get(Uri.parse(_makeApiURL(path)), headers: _headers);
      print("GET=>$path=>${httpResponse.body}");
      var js = jsonDecode(httpResponse.body);
      return APIResponse.fromJson(js);
    } catch (err) {
      print(err);
      var errResp = APIResponse();
      errResp.code = -100;
      errResp.error = "failed to make request";
      return errResp;
    }
  }

  Future<APIResponse> upload_post(String path, String filepath) async {
    try {
      var postUri = Uri.parse(_apiBaseURL + path);
      http.MultipartRequest request =
          new http.MultipartRequest("POST", postUri);

      print("POST=>$path=>${jsonEncode(filepath)}");
      var multipartFile = await http.MultipartFile.fromPath('file', filepath);
      request.headers.addAll(_headers);
      request.fields['session_id'] = Constants.SESSION_ID.toString();
      request.files.add(multipartFile);
      var httpResponse = await request.send();
      // print("POST=>$path=>${httpResponse.body}");
      var js = {};
      if (httpResponse.statusCode == 200)
        js = {
          'code': httpResponse.statusCode,
          'error': '',
          '_data': 'آپلود شد'
        };
      else
        js = {
          'code': httpResponse.statusCode,
          'error': 'Problem with uploading',
        };
      var resp = APIResponse.fromJson(js);

      return resp;
    } catch (err) {
      print(err);
      var errResp = APIResponse();
      errResp.code = -100;
      errResp.error = "failed to make request";
      return errResp;
    }
  }

  Future<APIResponse> post(String path, dynamic body) async {
    try {
      print("POST=>$path=>${jsonEncode(body)}");
      var httpResponse = await http.post(Uri.parse(_makeApiURL(path)),
          headers: _headers, body: jsonEncode(body));
      print("POST=>$path=>${httpResponse.body}");
      var js = jsonDecode(httpResponse.body);
      var resp = APIResponse.fromJson(js);
      // print(resp);
      return resp;
    } catch (err) {
      print(err);
      var errResp = APIResponse();
      errResp.code = -100;
      errResp.error = "failed to make request";
      return errResp;
    }
  }
}

class APIResponse {
  late int code;
  late String? error;
  late dynamic data;

  bool get isSuccess => code == 200;

  bool get isFailed => !isSuccess;

  APIResponse();

  APIResponse.fromJson(dynamic js) {
    code = js['code'];
    error = js['error'];
    data = js['_data'];
  }
}
