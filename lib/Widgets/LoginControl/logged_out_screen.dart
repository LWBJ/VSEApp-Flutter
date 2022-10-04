import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Widgets/LoginControl/login_form.dart';
import 'package:vseapp/Widgets/LoginControl/signup_form.dart';
import 'package:vseapp/login_control_notifier.dart';

class LoggedOutScreen extends StatelessWidget {
  const LoggedOutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VSE App"),
      ),
      body: Center(
          child: ListView(
        children: [
          Consumer<LoginControlNotifier>(builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 102, 51, 153),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const LoginForm(),
            );
          }),
          Consumer<LoginControlNotifier>(builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 102, 51, 153),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const SignupForm(),
            );
          }),
        ],
      )),
    );
  }
}
