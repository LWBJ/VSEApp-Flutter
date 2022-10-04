import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Models/vse_experience.dart';
import 'package:vseapp/Models/vse_value.dart';
import 'package:vseapp/vse_control_notifier.dart';

import '../../../Models/vse_data.dart';
import '../../../Models/vse_skill.dart';
import '../../../api_calls.dart';
import '../vse_item_detail_view.dart';

class VSEExperienceCreateUpdateForm extends StatefulWidget {
  const VSEExperienceCreateUpdateForm(
      this.httpMethod, this.initialData, this.isLoading, this.setLoading,
      {Key? key})
      : super(key: key);
  final String httpMethod;
  final VSEExperience? initialData;
  final bool isLoading;
  final Function setLoading;

  @override
  State<VSEExperienceCreateUpdateForm> createState() =>
      _VSEExperienceCreateUpdateFormState();
}

class _VSEExperienceCreateUpdateFormState
    extends State<VSEExperienceCreateUpdateForm> {
  late final VSEControlNotifier model;
  final _formKey = GlobalKey<FormState>();
  //State Variables
  bool isValid = false;
  String statusMessage = '';

  late final List<VSEValue> selectedValues;
  late final List<VSESkill> selectedSkills;
  //Text Controllers
  TextEditingController nameField = TextEditingController();

  //Validity
  String? validateNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be blank";
    }
    return null;
  }

  void checkValidity() {
    bool immediateValidity = _formKey.currentState!.validate();
    setState(() {
      isValid = (immediateValidity && !widget.isLoading);
    });
  }

  //Generate JSON
  String generateJson() {
    var formContent = <String, dynamic>{
      'name': nameField.text,
      'value_set': selectedValues.map((item) => item.url).toList(),
      'skill_set': selectedSkills.map((item) => item.url).toList(),
    };
    return jsonEncode(formContent);
  }

  //Form Submission
  void submitForm() async {
    if (widget.isLoading) {
      return;
    }
    widget.setLoading(true);

    String jsonBody = generateJson();
    ReturnedDataAndStringResponseStatus apiResponse;

    if (widget.httpMethod == 'POST') {
      apiResponse =
          await model.createVSEDataAndNotify(VSEType.experience, jsonBody);
    } else {
      apiResponse = await model.updateVSEDataAndNotify(
          VSEType.experience, jsonBody, widget.initialData!.url);
    }

    if (apiResponse.statusString == 'OK') {
      _goToNewPage(VSEExperience.fromJson(
          jsonDecode(apiResponse.returnedData as String)));
    } else {
      setState(() {
        statusMessage = apiResponse.statusString;
      });
    }

    widget.setLoading(false);
  }

  _goToNewPage(VSEItem newDetailItem) {
    if (widget.httpMethod == 'PUT') {
      Navigator.of(context).pop();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return VSEItemDetailView(VSEType.experience, newDetailItem);
    }));
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<VSEControlNotifier>(context, listen: false);
    var initialData = widget.initialData;
    if (initialData != null) {
      //Set up initial values of the update form
      nameField.text = initialData.name;
      selectedValues = model.vseValueList
          .where((vseItem) => initialData.valueURLList.contains(vseItem.url))
          .toList();
      selectedSkills = model.vseSkillList
          .where((vseItem) => initialData.skillURLList.contains(vseItem.url))
          .toList();
    } else {
      selectedValues = [];
      selectedSkills = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget valueSelectField =
        Consumer<VSEControlNotifier>(builder: (context, model, child) {
      List<Widget> selectionOptions = model.vseValueList
          .map((item) => CheckboxListTile(
              title: Text(item.name),
              value: selectedValues.contains(item),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedValues.add(item);
                  } else {
                    selectedValues.remove(item);
                  }
                });
              }))
          .toList();

      return ListView(
        controller: ScrollController(),
        children: selectionOptions,
      );
    });

    Widget skillSelectField =
        Consumer<VSEControlNotifier>(builder: (context, model, child) {
      List<Widget> selectionOptions = model.vseSkillList
          .map((item) => CheckboxListTile(
              title: Text(item.name),
              value: selectedSkills.contains(item),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedSkills.add(item);
                  } else {
                    selectedSkills.remove(item);
                  }
                });
              }))
          .toList();

      return ListView(
        controller: ScrollController(),
        children: selectionOptions,
      );
    });

    return Form(
        key: _formKey,
        child: Column(
          children: [
            (statusMessage.isNotEmpty
                ? Text(statusMessage)
                : const SizedBox.shrink()),
            TextFormField(
              controller: nameField,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Experience Name',
              ),
              validator: validateNameField,
              onChanged: (_) {
                checkValidity();
              },
            ),
            const Text('Select Values'),
            Expanded(child: valueSelectField),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: const Divider(),
            ),
            const Text('Select Skills'),
            Expanded(child: skillSelectField),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitForm();
                  }
                },
                child: Text(
                    '${widget.httpMethod == 'POST' ? 'Create' : 'Update'} Experience'),
              ),
            ),
          ],
        ));
  }
}
