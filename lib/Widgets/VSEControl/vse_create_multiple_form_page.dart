import 'package:flutter/material.dart';
import 'package:vseapp/Widgets/VSEControl/vse_create_multiple_form.dart';

import '../../Models/vse_data.dart';

class VSECreateMultipleFormPage extends StatefulWidget {
  const VSECreateMultipleFormPage(this.vseType, {Key? key}) : super(key: key);
  final VSEType vseType;

  @override
  State<VSECreateMultipleFormPage> createState() =>
      _VSECreateMultipleFormPageState();
}

class _VSECreateMultipleFormPageState extends State<VSECreateMultipleFormPage> {
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
          title: Text('Add Multiple ${widget.vseType.asString}s'),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: const Color.fromARGB(255, 102, 51, 153),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              (isLoading
                  ? const CircularProgressIndicator(value: null)
                  : const SizedBox.shrink()),
              Expanded(
                  child: VSECreateMultipleForm(
                      widget.vseType, isLoading, setLoading)),
            ])),
      ),
    );
  }
}
