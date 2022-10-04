import 'package:flutter/material.dart';
import 'package:vseapp/Widgets/LoginControl/delete_user_form.dart';
import 'package:vseapp/Widgets/LoginControl/edit_password_form.dart';
import 'package:vseapp/Widgets/LoginControl/edit_username_form.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  //State variables
  bool isLoading = false;
  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit User'),
        ),
        body: ListView(
          children: [
            Center(
              child: (isLoading
                  ? const CircularProgressIndicator(value: null)
                  : const SizedBox.shrink()),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 102, 51, 153),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: EditUsernameForm(isLoading, setLoading),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 102, 51, 153),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: EditPasswordForm(isLoading, setLoading),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 102, 51, 153),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DeleteUserForm(isLoading, setLoading),
            ),
          ],
        ),
      ),
    );
  }
}
