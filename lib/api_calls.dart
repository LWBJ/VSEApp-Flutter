import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:vseapp/Models/vse_user.dart';
import 'Models/token_pair.dart';

Future<String> getAccessTokenOrEmptyStringAsync() async {
  final prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refreshToken');
  if (refreshToken == null) {
    return "";
  }

  try {
    Response response = await post(
      Uri.parse("https://lwbjvseapp.herokuapp.com/drf_api/token_refresh/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'refresh': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      TokenPair tokenPair = TokenPair.fromJson(jsonDecode(response.body));
      return tokenPair.accessToken;
    } else {
      return "";
    }
  } catch (ex) {
    return "";
  }
}

Future<ReturnedDataAndStringResponseStatus> getDataOrNullAsync(
    String url, String accessToken) async {
  try {
    Response response = await get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return ReturnedDataAndStringResponseStatus(response.body, 'OK');
    } else {
      return ReturnedDataAndStringResponseStatus(null, response.body);
    }
  } catch (ex) {
    return ReturnedDataAndStringResponseStatus(null, "Server Error");
  }
}

Future<ReturnedDataAndStringResponseStatus> postOrPutAndReturnStatusAsync(
    String url, String? accessToken, String httpMethod, String jsonBody) async {
  var headers = <String, String>{
    'Content-Type': 'application/json',
  };
  if (accessToken != null) {
    headers['Authorization'] = 'Bearer $accessToken';
  }

  try {
    Response response;
    if (httpMethod == 'POST') {
      response = await post(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      );
    } else if (httpMethod == 'PUT') {
      response = await put(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      );
    } else {
      throw "WRONG METHOD";
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ReturnedDataAndStringResponseStatus(response.body, 'OK');
    } else {
      return ReturnedDataAndStringResponseStatus(null, response.body);
    }
  } catch (ex) {
    return ReturnedDataAndStringResponseStatus(null, 'Server Error');
  }
}

Future<ReturnedDataAndStringResponseStatus> deleteAndReturnStatusAsync(
    String url, String accessToken) async {
  try {
    Response response = await delete(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 204) {
      return ReturnedDataAndStringResponseStatus(null, "OK");
    } else {
      return ReturnedDataAndStringResponseStatus(null, response.body);
    }
  } catch (ex) {
    return ReturnedDataAndStringResponseStatus(null, "Server Error");
  }
}

Future<ReturnedDataAndStringResponseStatus>
    postLoginAndReturnTokenPairOrNullAsync(String loginFormContent) async {
  var loginResult = await postOrPutAndReturnStatusAsync(
      'https://lwbjvseapp.herokuapp.com/drf_api/token_pair/',
      null,
      'POST',
      loginFormContent);

  if (loginResult.returnedData == null) {
    return loginResult;
  }
  return ReturnedDataAndStringResponseStatus(
      TokenPair.fromJson(jsonDecode(loginResult.returnedData as String)),
      loginResult.statusString);
}

Future<ReturnedDataAndStringResponseStatus> getUserDataOrNull(
    String accessToken) async {
  try {
    Response response = await get(
        Uri.parse('https://lwbjvseapp.herokuapp.com/drf_api/user/'),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        });
    if (response.statusCode == 200) {
      var userData = VSEUser.fromJson(jsonDecode(response.body));
      return ReturnedDataAndStringResponseStatus(userData, 'OK');
    } else {
      return ReturnedDataAndStringResponseStatus(null, response.body);
    }
  } catch (ex) {
    return ReturnedDataAndStringResponseStatus(null, 'Server Error');
  }
}

class ReturnedDataAndStringResponseStatus {
  Object? returnedData;
  String statusString;
  ReturnedDataAndStringResponseStatus(this.returnedData, this.statusString);
}
