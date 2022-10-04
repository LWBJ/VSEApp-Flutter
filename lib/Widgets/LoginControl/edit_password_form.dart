import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/login_control_notifier.dart';

class EditPasswordForm extends StatefulWidget {
  const EditPasswordForm(this.isLoading, this.setLoading, {Key? key})
      : super(key: key);
  final bool isLoading;
  final Function setLoading;

  @override
  State<EditPasswordForm> createState() => _EditPasswordFormState();
}

class _EditPasswordFormState extends State<EditPasswordForm> {
  final _editPasswordFormKey = GlobalKey<FormState>();
  late final LoginControlNotifier model;

  //State variables
  bool editPasswordIsValid = false;
  String editPasswordStatusMessage = '';
  //TextControllers
  final TextEditingController editPasswordOldPasswordController =
      TextEditingController();
  final TextEditingController editPasswordNewPasswordController =
      TextEditingController();
  final TextEditingController editPasswordConfirmPasswordController =
      TextEditingController();

  //Validity
  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  String? editPasswordValidatePassword2(String? value) {
    if (value != editPasswordNewPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  void editPasswordCheckValidity() {
    bool immediateValidity = _editPasswordFormKey.currentState!.validate();
    setState(() {
      editPasswordIsValid = (immediateValidity && !widget.isLoading);
    });
  }

  //Generate JSON
  String generateLoginJson() {
    var loginInfo = <String, String>{
      'username': model.currentUser!.username,
      'password': editPasswordOldPasswordController.text,
    };
    return jsonEncode(loginInfo);
  }

  String generateChangePasswordJson() {
    var changePasswordInfo = <String, String>{
      'password': editPasswordNewPasswordController.text,
      'password2': editPasswordConfirmPasswordController.text,
    };
    return jsonEncode(changePasswordInfo);
  }

  //Change Password
  void _changePassword() async {
    if (!editPasswordIsValid || widget.isLoading) {
      return;
    }

    widget.setLoading(true);

    String loginJsonBody = generateLoginJson();
    String newPasswordJsonBody = generateChangePasswordJson();
    String response = await model.putUpdatePasswordAndNotify(
        loginJsonBody, newPasswordJsonBody);
    if (response == 'OK') {
      setState(() {
        editPasswordStatusMessage = 'Password changed';
      });
    } else {
      setState(() {
        editPasswordStatusMessage = response;
      });
    }

    widget.setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<LoginControlNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _editPasswordFormKey,
        child: Column(
          children: [
            (editPasswordStatusMessage.isNotEmpty
                ? Text(editPasswordStatusMessage)
                : const SizedBox.shrink()),
            TextFormField(
              controller: editPasswordOldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Old Password',
              ),
              validator: validatePassword,
              onChanged: (_) {
                editPasswordCheckValidity();
              },
            ),
            TextFormField(
              controller: editPasswordNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'New Password',
              ),
              validator: validatePassword,
              onChanged: (_) {
                editPasswordCheckValidity();
              },
            ),
            TextFormField(
              controller: editPasswordConfirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Confirm New Password',
              ),
              validator: editPasswordValidatePassword2,
              onChanged: (_) {
                editPasswordCheckValidity();
              },
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ElevatedButton(
                onPressed: () {
                  if (_editPasswordFormKey.currentState!.validate()) {
                    _changePassword();
                  }
                },
                child: const Text('Change password'),
              ),
            )
          ],
        ));
  }
}
