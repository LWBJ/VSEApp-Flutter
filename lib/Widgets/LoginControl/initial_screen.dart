import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/login_control_notifier.dart';

import 'logged_in_screen.dart';
import 'logged_out_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late final LoginControlNotifier model;

  void _navigateToLoggedOut() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const LoggedOutScreen();
    }));
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await model.firstStartup();
      if (model.isLoggedIn) {
        _navigateToLoggedIn();
      } else {
        _navigateToLoggedOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        CircularProgressIndicator(
          value: null,
        ),
        Text('VSE App'),
      ],
    )));
  }
}
