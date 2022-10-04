import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/api_calls.dart';
import 'package:vseapp/vse_control_notifier.dart';

import '../../Models/vse_data.dart';

class VSECreateMultipleForm extends StatefulWidget {
  const VSECreateMultipleForm(this.vseType, this.isLoading, this.setLoading,
      {Key? key})
      : super(key: key);
  final VSEType vseType;
  final bool isLoading;
  final Function setLoading;

  @override
  State<VSECreateMultipleForm> createState() => _VSECreateMultipleFormState();
}

class _VSECreateMultipleFormState extends State<VSECreateMultipleForm> {
  late final VSEControlNotifier model;

  //State Variables
  String statusMessage = '';
  //Text Controllers
  final List<TextEditingController> fields = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  //Generate JSON
  String generateValueSkillJson() {
    var formValues = fields
        .where((field) => field.text.isNotEmpty)
        .map((field) => {'name': field.text})
        .toList();

    return jsonEncode(formValues);
  }

  String generateExperienceJson() {
    var formValues = fields
        .where((field) => field.text.isNotEmpty)
        .map((field) => {
              'name': field.text,
              'value_set': [],
              'skill_set': [],
            })
        .toList();

    return jsonEncode(formValues);
  }

  //Create Multiple
  void _createMultiple() async {
    if (widget.isLoading) {
      return;
    }
    widget.setLoading(true);

    String jsonBody = (widget.vseType == VSEType.experience
        ? generateExperienceJson()
        : generateValueSkillJson());
    ReturnedDataAndStringResponseStatus apiResponse =
        await model.createVSEDataAndNotify(widget.vseType, jsonBody);
    if (apiResponse.statusString == 'OK') {
      setState(() {
        statusMessage = 'Items created!';
      });
      for (TextEditingController field in fields) {
        field.clear();
      }
    } else {
      statusMessage = apiResponse.statusString;
    }
    widget.setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<VSEControlNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formFieldWidgets = fields
        .map(
          (field) => TextFormField(
            controller: field,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'Add ${widget.vseType.asString}',
            ),
          ),
        )
        .toList();

    List<Widget> formContents = [
      (statusMessage.isNotEmpty ? Text(statusMessage) : const SizedBox.shrink())
    ];

    for (Widget formField in formFieldWidgets) {
      formContents.add(formField);
    }

    return Form(
        child: Column(
      children: [
        Expanded(child: ListView(children: formContents)),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
          child: ElevatedButton(
            onPressed: _createMultiple,
            child: Text('Add Multiple ${widget.vseType.asString}s'),
          ),
        ),
      ],
    ));
  }
}
