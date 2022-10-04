import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/login_control_notifier.dart';

class EditUsernameForm extends StatefulWidget {
  const EditUsernameForm(this.isLoading, this.setLoading, {Key? key})
      : super(key: key);
  final bool isLoading;
  final Function setLoading;

  @override
  State<EditUsernameForm> createState() => _EditUsernameFormState();
}

class _EditUsernameFormState extends State<EditUsernameForm> {
  late final LoginControlNotifier model;
  final _editUsernameFormKey = GlobalKey<FormState>();
  //State variables
  String get originalUsername => model.currentUser!.username;
  bool editUsernameIsValid = false;
  String editUsernameStatusMessage = '';
  //TextControllers
  final TextEditingController editUsernameUsernameController =
      TextEditingController();

  //Validity
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username cannot be blank";
    }
    return null;
  }

  void editUsernameCheckValidity() {
    bool immediateValidity = _editUsernameFormKey.currentState!.validate();
    setState(() {
      editUsernameIsValid = (immediateValidity && !widget.isLoading);
    });
  }

  //generate JSON from form values
  String generateChangeUsernameJson() {
    var changeUsernameInfo = <String, String>{
      'username': editUsernameUsernameController.text,
    };
    return jsonEncode(changeUsernameInfo);
  }

  //form submission
  void _changeUsername() async {
    if (!editUsernameIsValid || widget.isLoading) {
      return;
    }

    widget.setLoading(true);

    String jsonBody = generateChangeUsernameJson();
    String response = await model.putUpdateUsernameAndNotify(jsonBody);

    if (response == 'OK') {
      setState(() {
        editUsernameStatusMessage = 'Username updated';
      });
    } else {
      setState(() {
        editUsernameStatusMessage = response;
      });
    }

    widget.setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<LoginControlNotifier>(context, listen: false);
    editUsernameUsernameController.text = model.currentUser?.username ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _editUsernameFormKey,
        child: Column(
          children: [
            (editUsernameStatusMessage.isNotEmpty
                ? Text(editUsernameStatusMessage)
                : const SizedBox.shrink()),
            TextFormField(
              controller: editUsernameUsernameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Username',
              ),
              validator: validateUsername,
              onChanged: (_) {
                editUsernameCheckValidity();
              },
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ElevatedButton(
                onPressed: () {
                  if (_editUsernameFormKey.currentState!.validate()) {
                    _changeUsername();
                  }
                },
                child: const Text('Change username'),
              ),
            )
          ],
        ));
  }
}
