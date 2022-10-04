import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:vseapp/Models/vse_experience.dart';
import 'package:vseapp/Models/vse_skill.dart';
import 'package:vseapp/Models/vse_value.dart';
import 'package:vseapp/login_control_notifier.dart';

import 'Models/vse_data.dart';
import 'api_calls.dart';

class VSEControlNotifier extends ChangeNotifier {
  VSEControlNotifier(this.loginControl);
  LoginControlNotifier loginControl;

  //---------------------------------fields------------------------------------
  bool _isLoading = true;
  final List<VSEValue> _vseValueList = [];
  final List<VSESkill> _vseSkillList = [];
  final List<VSEExperience> _vseExperienceList = [];

  //----------------------------getters & setters------------------------------
  bool get isLoading => _isLoading;
  UnmodifiableListView<VSEValue> get vseValueList =>
      UnmodifiableListView(_vseValueList);
  UnmodifiableListView<VSESkill> get vseSkillList =>
      UnmodifiableListView(_vseSkillList);
  UnmodifiableListView<VSEExperience> get vseExperienceList =>
      UnmodifiableListView(_vseExperienceList);

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setVSEValueList(List<VSEValue> newList) {
    _vseValueList.clear();
    for (var item in newList) {
      _vseValueList.add(item);
    }
    notifyListeners();
  }

  void setVSESkillList(List<VSESkill> newList) {
    _vseSkillList.clear();
    for (var item in newList) {
      _vseSkillList.add(item);
    }
    notifyListeners();
  }

  void setVSEExperienceList(List<VSEExperience> newList) {
    _vseExperienceList.clear();
    for (var item in newList) {
      _vseExperienceList.add(item);
    }
    notifyListeners();
  }

  //------------------------------Methods--------------------------------------
  Future<void> initialSetAsync() async {
    isLoading = true;
    await Future.wait([
      setVSEDataListAndNotify(VSEType.value),
      setVSEDataListAndNotify(VSEType.skill),
      setVSEDataListAndNotify(VSEType.experience),
    ]);

    isLoading = false;
  }

  Future<String> setVSEDataListAndNotify(VSEType vseType) async {
    isLoading = true;

    //Get access token
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken == '') {
      //alert session expired
      return 'Session Expired';
    }

    //Read data & check for success
    String url = 'https://lwbjvseapp.herokuapp.com/drf_api/vse/';
    switch (vseType) {
      case VSEType.value:
        url += 'Value/';
        break;
      case VSEType.skill:
        url += 'Skill/';
        break;
      case VSEType.experience:
        url += 'Experience/';
        break;
    }
    var apiResponse = await getDataOrNullAsync(url, accessToken);
    if (apiResponse.statusString != 'OK') {
      //Unsuccessful, report status message from server
      return apiResponse.statusString;
    }

    //Set data if successful
    List<dynamic> rawJson = jsonDecode(apiResponse.returnedData as String);
    switch (vseType) {
      case VSEType.value:
        setVSEValueList(VSEValue.fromJsonList(rawJson));
        break;
      case VSEType.skill:
        setVSESkillList(VSESkill.fromJsonList(rawJson));
        break;
      case VSEType.experience:
        setVSEExperienceList(VSEExperience.fromJsonList(rawJson));
        break;
    }
    notifyListeners();
    return apiResponse.statusString;
  }

  void clearData() {
    _isLoading = true;
    _vseValueList.clear();
    _vseSkillList.clear();
    _vseExperienceList.clear();
    notifyListeners();
  }

  Future<ReturnedDataAndStringResponseStatus> createVSEDataAndNotify(
      VSEType vseType, String jsonBody) async {
    isLoading = true;

    //Get access token
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken == '') {
      //alert session expired
      isLoading = false;
      return ReturnedDataAndStringResponseStatus(null, 'Session Expired');
    }

    //Prepare URL
    String url = 'https://lwbjvseapp.herokuapp.com/drf_api/vse/';
    switch (vseType) {
      case VSEType.value:
        url += 'Value/';
        break;
      case VSEType.skill:
        url += 'Skill/';
        break;
      case VSEType.experience:
        url += 'Experience/';
        break;
    }

    //Send Data
    var apiResponse =
        await postOrPutAndReturnStatusAsync(url, accessToken, 'POST', jsonBody);

    //Check API response, return data & status
    if (apiResponse.statusString == 'OK') {
      //If successful, refresh all VSE lists
      await Future.wait([
        setVSEDataListAndNotify(VSEType.value),
        setVSEDataListAndNotify(VSEType.skill),
        setVSEDataListAndNotify(VSEType.experience),
      ]);
    }

    isLoading = false;
    return apiResponse;
  }

  Future<ReturnedDataAndStringResponseStatus> updateVSEDataAndNotify(
      VSEType vseType, String jsonBody, String url) async {
    isLoading = true;

    //Get access token
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken == '') {
      //alert session expired
      isLoading = false;
      return ReturnedDataAndStringResponseStatus(null, 'Session Expired');
    }

    //Send Data
    var apiResponse =
        await postOrPutAndReturnStatusAsync(url, accessToken, 'PUT', jsonBody);

    //Check API response, return data & status
    if (apiResponse.statusString == 'OK') {
      //If successful, refresh all VSE lists
      await Future.wait([
        setVSEDataListAndNotify(VSEType.value),
        setVSEDataListAndNotify(VSEType.skill),
        setVSEDataListAndNotify(VSEType.experience),
      ]);
    }

    isLoading = false;
    return apiResponse;
  }

  Future<ReturnedDataAndStringResponseStatus> deleteVSEDataAndNotify(
      VSEType vseType, String url) async {
    isLoading = true;

    //Get access token
    String accessToken = await getAccessTokenOrEmptyStringAsync();
    if (accessToken == '') {
      //alert session expired
      isLoading = false;
      return ReturnedDataAndStringResponseStatus(null, 'Session Expired');
    }

    //Send Data
    var apiResponse = await deleteAndReturnStatusAsync(url, accessToken);

    //Check API response, return data & status
    if (apiResponse.statusString == 'OK') {
      //If successful, refresh all VSE lists
      await Future.wait([
        setVSEDataListAndNotify(VSEType.value),
        setVSEDataListAndNotify(VSEType.skill),
        setVSEDataListAndNotify(VSEType.experience),
      ]);
    }

    isLoading = false;
    return apiResponse;
  }
}
