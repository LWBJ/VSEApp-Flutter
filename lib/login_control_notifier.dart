import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vseapp/Models/token_pair.dart';
import 'package:vseapp/Models/vse_user.dart';
import 'package:vseapp/api_calls.dart';
import 'package:vseapp/vse_control_notifier.dart';

class LoginControlNotifier extends ChangeNotifier {
  LoginControlNotifier() {
    vseControl = VSEControlNotifier(this);
  }
  late VSEControlNotifier vseControl;

  bool _isLoading = true;
  bool _isLoggedIn = false;
  VSEUser? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  VSEUser? get currentUser => _currentUser;
  set currentUser(VSEUser? value) {
    _currentUser = value;
    notifyListeners();
  }

  //-------------------------------Methods----------------------------
  Future<void> firstStartup() async {
    isLoading = true;
    await setCurrentUserFromRefreshTokenOrSetNullAsync();
    isLoading = false;
  }

  Future<void> setCurrentUserFromRefreshTokenOrSetNullAsync() async {
    isLoading = true;
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken != '') {
      var apiResponse = await getUserDataOrNull(accessToken);
      if (apiResponse.statusString == 'OK') {
        //logged in
        currentUser = apiResponse.returnedData as VSEUser;
        isLoggedIn = true;
        return;
      }
    }
    //logged out
    currentUser = null;
    isLoggedIn = false;
  }

  Future<String> postSignupRequestAndNotify(String jsonBody) async {
    isLoading = true;
    String url = "https://lwbjvseapp.herokuapp.com/drf_api/signup/";
    var apiResponse =
        await postOrPutAndReturnStatusAsync(url, null, 'POST', jsonBody);
    isLoading = false;
    return apiResponse.statusString;
  }

  Future<String> postLoginRequestAndNotify(String jsonBody) async {
    isLoading = true;

    //Get token pair
    var apiResponse = await postLoginAndReturnTokenPairOrNullAsync(jsonBody);
    if (apiResponse.returnedData == null) {
      //Login Form error
      isLoading = false;
      return apiResponse.statusString;
    }
    TokenPair tokenPair = apiResponse.returnedData as TokenPair;

    //Get user data from token pair
    var apiResponse2 = await getUserDataOrNull(tokenPair.accessToken);
    if (apiResponse2.returnedData == null) {
      //Error retrieving user data
      isLoading = false;
      return apiResponse2.statusString;
    }
    VSEUser newUser = apiResponse2.returnedData as VSEUser;

    //Login success, save token data, set current user
    final pref = await SharedPreferences.getInstance();
    pref.setString(
        'refreshToken', (apiResponse.returnedData as TokenPair).refreshToken);
    currentUser = newUser;
    isLoading = false;

    return apiResponse2.statusString;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
    currentUser = null;
    isLoggedIn = false;
    vseControl.clearData();
  }

  //-----------------------------User update methods---------------------
  Future<String> putUpdateUsernameAndNotify(String jsonBody) async {
    isLoading = true;

    //Get & check access token first
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken == '') {
      //alert session expired
      isLoading = false;
      return 'Session Expired';
    }

    //Send data
    var apiResponse = await postOrPutAndReturnStatusAsync(
        currentUser!.url, accessToken, 'PUT', jsonBody);
    if (apiResponse.statusString == 'OK') {
      await setCurrentUserFromRefreshTokenOrSetNullAsync();
    }

    isLoading = false;
    return apiResponse.statusString;
  }

  Future<String> putUpdatePasswordAndNotify(
      String loginJsonBody, String newPasswordJsonBody) async {
    isLoading = true;

    //Check login data, end if failed, extract access token if success
    var loginApiResponse =
        await postLoginAndReturnTokenPairOrNullAsync(loginJsonBody);
    if (loginApiResponse.statusString != 'OK') {
      //password was incorrect
      isLoading = false;
      return 'Password Incorrect';
    }
    TokenPair tokenPair = loginApiResponse.returnedData as TokenPair;

    //Authorization success, send password update
    var updatePasswordApiResponse = await postOrPutAndReturnStatusAsync(
        currentUser!.url, tokenPair.accessToken, 'PUT', newPasswordJsonBody);
    if (updatePasswordApiResponse.statusString == 'OK') {
      await setCurrentUserFromRefreshTokenOrSetNullAsync();
    }

    isLoading = false;
    return updatePasswordApiResponse.statusString;
  }

  Future<String> deleteUserAndNotify(String jsonBody) async {
    isLoading = true;

    //Check login data, end if failed, extract access token if success
    var loginApiResponse =
        await postLoginAndReturnTokenPairOrNullAsync(jsonBody);
    if (loginApiResponse.statusString != 'OK') {
      //password was incorrect
      isLoading = false;
      return 'Password Incorrect';
    }
    TokenPair tokenPair = loginApiResponse.returnedData as TokenPair;

    //Authorization success, delete user
    var deleteUserApiResponse = await deleteAndReturnStatusAsync(
        currentUser!.url, tokenPair.accessToken);
    if (deleteUserApiResponse.statusString == 'OK') {
      logout();
    }

    isLoading = false;
    return deleteUserApiResponse.statusString;
  }
}

class LoginControlNotifierProvider extends StatelessWidget {
  const LoginControlNotifierProvider(this.child, {Key? key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var lcn = LoginControlNotifier();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => lcn),
        ChangeNotifierProvider(create: (context) => lcn.vseControl),
      ],
      child: child,
    );
  }
}
