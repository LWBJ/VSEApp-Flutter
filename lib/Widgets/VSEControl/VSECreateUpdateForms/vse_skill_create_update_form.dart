import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Models/vse_data.dart';
import 'package:vseapp/Models/vse_experience.dart';
import 'package:vseapp/Models/vse_skill.dart';
import 'package:vseapp/api_calls.dart';
import 'package:vseapp/vse_control_notifier.dart';

import '../vse_item_detail_view.dart';

class VSESkillCreateUpdateForm extends StatefulWidget {
  const VSESkillCreateUpdateForm(
      this.httpMethod, this.initialData, this.isLoading, this.setLoading,
      {Key? key})
      : super(key: key);
  final String httpMethod;
  final VSESkill? initialData;
  final bool isLoading;
  final Function setLoading;

  @override
  State<VSESkillCreateUpdateForm> createState() =>
      _VSESkillCreateUpdateFormState();
}

class _VSESkillCreateUpdateFormState extends State<VSESkillCreateUpdateForm> {
  late final VSEControlNotifier model;
  final _formKey = GlobalKey<FormState>();
  //State Variables
  bool isValid = false;
  String statusMessage = '';

  late final List<VSEExperience> selectedExperiences;
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
      'experiences': selectedExperiences.map((exp) => exp.url).toList(),
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
      apiResponse = await model.createVSEDataAndNotify(VSEType.skill, jsonBody);
    } else {
      apiResponse = await model.updateVSEDataAndNotify(
          VSEType.skill, jsonBody, widget.initialData!.url);
    }

    if (apiResponse.statusString == 'OK') {
      _goToNewPage(
          VSESkill.fromJson(jsonDecode(apiResponse.returnedData as String)));
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
      return VSEItemDetailView(VSEType.skill, newDetailItem);
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
      selectedExperiences = model.vseExperienceList
          .where((exp) => initialData.experienceURLList.contains(exp.url))
          .toList();
    } else {
      selectedExperiences = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget experienceSelectField =
        Consumer<VSEControlNotifier>(builder: (context, model, child) {
      List<Widget> selectionOptions = model.vseExperienceList
          .map((item) => CheckboxListTile(
              title: Text(item.name),
              value: selectedExperiences.contains(item),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedExperiences.add(item);
                  } else {
                    selectedExperiences.remove(item);
                  }
                });
              }))
          .toList();

      return ListView(
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
                labelText: 'Skill Name',
              ),
              validator: validateNameField,
              onChanged: (_) {
                checkValidity();
              },
            ),
            const Text('Select Experiences'),
            Expanded(child: experienceSelectField),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitForm();
                  }
                },
                child: Text(
                    '${widget.httpMethod == 'POST' ? 'Create' : 'Update'} Skill'),
              ),
            ),
          ],
        ));
  }
}
