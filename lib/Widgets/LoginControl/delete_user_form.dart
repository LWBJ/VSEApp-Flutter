import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/login_control_notifier.dart';

import 'logged_out_screen.dart';

class DeleteUserForm extends StatefulWidget {
  const DeleteUserForm(this.isLoading, this.setLoading, {Key? key})
      : super(key: key);
  final bool isLoading;
  final Function setLoading;

  @override
  State<DeleteUserForm> createState() => _DeleteUserFormState();
}

class _DeleteUserFormState extends State<DeleteUserForm> {
  final _deleteUserFormKey = GlobalKey<FormState>();
  late final LoginControlNotifier model;

  //State variables
  bool deleteUserIsValid = false;
  String deleteUserStatusMessage = '';
  //TextControllers
  final TextEditingController deleteUserPasswordController =
      TextEditingController();

  //Validity
  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  void deleteUserCheckValidity() {
    bool immediateValidity = _deleteUserFormKey.currentState!.validate();
    setState(() {
      deleteUserIsValid = (immediateValidity && !widget.isLoading);
    });
  }

  //Generate JSON
  String generateLoginJson() {
    var loginInfo = <String, String>{
      'username': model.currentUser!.username,
      'password': deleteUserPasswordController.text,
    };
    return jsonEncode(loginInfo);
  }

  //Delete user
  void _navigateToLoggedOut() {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const LoggedOutScreen();
    }));
  }

  void _deleteUser() async {
    if (!deleteUserIsValid || widget.isLoading) {
      return;
    }

    widget.setLoading(true);

    String jsonBody = generateLoginJson();
    String response = await model.deleteUserAndNotify(jsonBody);

    if (response == 'OK') {
      _navigateToLoggedOut();
    } else {
      setState(() {
        deleteUserStatusMessage = response;
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
        key: _deleteUserFormKey,
        child: Column(
          children: [
            (deleteUserStatusMessage.isNotEmpty
                ? Text(deleteUserStatusMessage)
                : const SizedBox.shrink()),
            TextFormField(
              controller: deleteUserPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter password again before deletion',
              ),
              validator: validatePassword,
              onChanged: (_) {
                deleteUserCheckValidity();
              },
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ElevatedButton(
                onPressed: () {
                  if (_deleteUserFormKey.currentState!.validate()) {
                    _deleteUser();
                  }
                },
                child: const Text('Delete User'),
              ),
            )
          ],
        ));
  }
}
