import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login_control_notifier.dart';
import 'logged_in_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final LoginControlNotifier model;
  final _formKey = GlobalKey<FormState>();
  //State variables
  bool isValid = false;
  bool isLoading = false;
  String statusMessage = '';
  //TextControllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //validation
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username cannot be blank";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  void checkValidity() {
    bool immediateValidity = _formKey.currentState!.validate();
    setState(() {
      isValid = (immediateValidity && !isLoading);
    });
  }

  //generate JSON from form values
  String generateLoginJson() {
    var loginInfo = <String, String>{
      'username': usernameController.text,
      'password': passwordController.text,
    };
    return jsonEncode(loginInfo);
  }

  //form submission
  void _login() async {
    if (!isValid || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String jsonBody = generateLoginJson();
    String response = await model.postLoginRequestAndNotify(jsonBody);
    if (response == 'OK') {
      _navigateToLoggedIn();
    } else {
      //Set status message
      setState(() {
        if (response.contains('This field may not be blank') ||
            response.contains('No active account found')) {
          statusMessage = 'Username or Password incorrect';
        } else {
          statusMessage = response;
        }
        isLoading = false;
      });
    }
  }

  void _navigateToLoggedIn() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const LoggedInScreen();
    }));
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<LoginControlNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          (statusMessage.isNotEmpty
              ? Text(statusMessage)
              : const SizedBox.shrink()),
          (isLoading
              ? const CircularProgressIndicator(value: null)
              : const SizedBox.shrink()),
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username',
            ),
            validator: validateUsername,
            onChanged: (_) {
              checkValidity();
            },
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
            validator: validatePassword,
            onChanged: (_) {
              checkValidity();
            },
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _login();
                }
              },
              child: const Text('Login'),
            ),
          )
        ],
      ),
    );
  }
}
