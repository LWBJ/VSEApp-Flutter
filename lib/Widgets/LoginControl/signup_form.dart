import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/login_control_notifier.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  late final LoginControlNotifier model;
  final _formKey = GlobalKey<FormState>();
  //State variables
  bool isValid = false;
  bool isLoading = false;
  String statusMessage = '';
  //TextControllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

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

  String? validatePassword2(String? value) {
    if (value != passwordController.text) {
      return "Passwords do not match";
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
  String generateSignupJson() {
    var signupInfo = <String, String>{
      'username': usernameController.text,
      'password': passwordController.text,
      'password2': password2Controller.text,
    };
    return jsonEncode(signupInfo);
  }

  //form submission
  void _signup() async {
    if (!isValid || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String jsonBody = generateSignupJson();
    String response = await model.postSignupRequestAndNotify(jsonBody);

    if (response == 'OK') {
      setState(() {
        statusMessage = 'Account created, please login';
        usernameController.clear();
        passwordController.clear();
        password2Controller.clear();
      });
    } else {
      setState(() {
        if (response.contains('This field must be unique')) {
          statusMessage = 'Username already taken';
        } else if (response.contains('This password is too common')) {
          statusMessage = 'This password is too common';
        } else {
          statusMessage = response;
        }
      });
    }
    setState(() {
      isLoading = false;
    });
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
          TextFormField(
            controller: password2Controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Confirm Password',
            ),
            validator: validatePassword2,
            onChanged: (_) {
              checkValidity();
            },
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signup();
                }
              },
              child: const Text('Signup'),
            ),
          )
        ],
      ),
    );
  }
}
