import 'package:flutter/material.dart';
import 'package:vseapp/Models/vse_experience.dart';
import 'package:vseapp/Models/vse_skill.dart';
import 'package:vseapp/Models/vse_value.dart';
import 'package:vseapp/Widgets/VSEControl/VSECreateUpdateForms/vse_experience_create_update_form.dart';
import 'package:vseapp/Widgets/VSEControl/VSECreateUpdateForms/vse_skill_create_update_form.dart';
import 'package:vseapp/Widgets/VSEControl/VSECreateUpdateForms/vse_value_create_update_form.dart';

import '../../../Models/vse_data.dart';

class VSECreateUpdateFormPage extends StatefulWidget {
  const VSECreateUpdateFormPage(
      this.vseType, this.httpMethod, this.initialValue,
      {Key? key})
      : super(key: key);
  final VSEType vseType;
  final String httpMethod;
  final VSEItem? initialValue;

  String get createOrUpdate {
    return (httpMethod == 'POST' ? 'Create' : 'Update');
  }

  @override
  State<VSECreateUpdateFormPage> createState() =>
      _VSECreateUpdateFormPageState();
}

class _VSECreateUpdateFormPageState extends State<VSECreateUpdateFormPage> {
  //State variables
  bool isLoading = false;
  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget formWidget;
    switch (widget.vseType) {
      case VSEType.value:
        formWidget = VSEValueCreateUpdateForm(
            widget.httpMethod,
            (widget.initialValue != null
                ? widget.initialValue as VSEValue
                : null),
            isLoading,
            setLoading);
        break;
      case VSEType.skill:
        formWidget = VSESkillCreateUpdateForm(
            widget.httpMethod,
            (widget.initialValue != null
                ? widget.initialValue as VSESkill
                : null),
            isLoading,
            setLoading);
        break;
      case VSEType.experience:
        formWidget = VSEExperienceCreateUpdateForm(
            widget.httpMethod,
            (widget.initialValue != null
                ? widget.initialValue as VSEExperience
                : null),
            isLoading,
            setLoading);
        break;
    }

    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.createOrUpdate} ${widget.vseType.asString}'),
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
            Expanded(child: formWidget),
          ]),
        ),
      ),
    );
  }
}
