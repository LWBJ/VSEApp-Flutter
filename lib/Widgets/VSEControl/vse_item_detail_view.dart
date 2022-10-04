import 'package:flutter/material.dart';
import 'package:vseapp/Models/vse_data.dart';
import 'package:vseapp/Models/vse_experience.dart';
import 'package:vseapp/Models/vse_skill.dart';
import 'package:vseapp/Models/vse_value.dart';
import 'package:vseapp/Widgets/VSEControl/vse_delete_dialog.dart';

import 'VSECreateUpdateForms/vse_create_update_form_page.dart';

class VSEItemDetailView extends StatelessWidget {
  const VSEItemDetailView(this.vseType, this.detailItem, {Key? key})
      : super(key: key);

  final VSEType vseType;
  final VSEItem detailItem;

  void goToUpdatePage(BuildContext context) {
    switch (vseType) {
      case VSEType.value:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return VSECreateUpdateFormPage(
              vseType, 'PUT', detailItem as VSEValue);
        }));
        break;
      case VSEType.skill:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return VSECreateUpdateFormPage(
              vseType, 'PUT', detailItem as VSESkill);
        }));
        break;
      case VSEType.experience:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return VSECreateUpdateFormPage(
              vseType, 'PUT', detailItem as VSEExperience);
        }));
        break;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return VSEDeleteDialog(vseType, detailItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffoldBody;
    switch (vseType) {
      case VSEType.value:
        var expList = ListView(
          children: (detailItem as VSEValue)
              .experienceList
              .map((item) => ListTile(title: Text(item), key: ObjectKey(item)))
              .toList(),
        );
        scaffoldBody = Column(
          children: [
            const Text('Experiences'),
            Expanded(child: expList),
          ],
        );
        break;
      case VSEType.skill:
        var expList = ListView(
          children: (detailItem as VSESkill)
              .experienceList
              .map((item) => ListTile(title: Text(item), key: ObjectKey(item)))
              .toList(),
        );
        scaffoldBody = Column(
          children: [
            const Text('Experiences'),
            Expanded(child: expList),
          ],
        );
        break;
      case VSEType.experience:
        var valueList = ListView(
          controller: ScrollController(),
          children: (detailItem as VSEExperience)
              .valueList
              .map((item) => ListTile(title: Text(item), key: ObjectKey(item)))
              .toList(),
        );
        var skillList = ListView(
          controller: ScrollController(),
          children: (detailItem as VSEExperience)
              .skillList
              .map((item) => ListTile(title: Text(item), key: ObjectKey(item)))
              .toList(),
        );
        scaffoldBody = Column(
          children: [
            const Text('Values'),
            Expanded(child: valueList),
            const Text('Skills'),
            Expanded(child: skillList),
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${vseType.asString}: ${detailItem.name}'),
        actions: [
          IconButton(
              onPressed: () => goToUpdatePage(context),
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                _showDeleteDialog(context);
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: scaffoldBody,
    );
  }
}
