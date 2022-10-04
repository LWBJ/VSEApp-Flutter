import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Widgets/LoginControl/edit_user_page.dart';
import 'package:vseapp/Widgets/VSEControl/vse_control_widget.dart';
import 'package:vseapp/login_control_notifier.dart';

import '../../vse_control_notifier.dart';
import 'logged_out_screen.dart';

class LoggedInScreen extends StatefulWidget {
  const LoggedInScreen({Key? key}) : super(key: key);

  @override
  State<LoggedInScreen> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  late final LoginControlNotifier model;

  void _navigateToLoggedOut() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const LoggedOutScreen();
    }));
  }

  void _navigateToEditUser() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const EditUserPage();
    }));
  }

  void _logout() async {
    await model.logout();
    _navigateToLoggedOut();
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<LoginControlNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      model.vseControl.initialSetAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Consumer<LoginControlNotifier>(
                  builder: (context, model, child) =>
                      Text("Welcome ${model.currentUser?.username}")),
              bottom: const TabBar(tabs: [
                Tab(text: 'Values'),
                Tab(text: 'Skills'),
                Tab(text: 'Experiences'),
              ]),
              actions: [
                IconButton(
                    onPressed: _navigateToEditUser,
                    icon: const Icon(Icons.person)),
                IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
              ],
            ),
            body: Stack(
              children: [
                Center(
                    child: Consumer<VSEControlNotifier>(
                        builder: (context, model, child) => (model.isLoading
                            ? const CircularProgressIndicator(value: null)
                            : const SizedBox.shrink()))),
                const VSEControlWidget(),
              ],
            ),
          ),
        ));
  }
}
