import 'package:flutter/material.dart';
import 'package:vseapp/login_control_notifier.dart';

import 'Widgets/LoginControl/initial_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoginControlNotifierProvider(MaterialApp(
      title: 'VSE App',
      theme: ThemeData.dark(),
      home: const InitialScreen(),
    ));
  }
}
