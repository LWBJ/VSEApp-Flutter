import 'package:flutter/material.dart';
import 'package:vseapp/Widgets/VSEControl/VSECreateUpdateForms/vse_create_update_form_page.dart';
import 'package:vseapp/Widgets/VSEControl/vse_create_multiple_form_page.dart';

import '../../Models/vse_data.dart';
import 'vse_item_list_view.dart';

class VSEControlWidget extends StatefulWidget {
  const VSEControlWidget({Key? key}) : super(key: key);

  @override
  State<VSEControlWidget> createState() => _VSEControlWidgetState();
}

class _VSEControlWidgetState extends State<VSEControlWidget> {
  String filter = '';
  void setFilter(newFilter) {
    setState(() {
      filter = newFilter;
    });
  }

  void _navigateToCreatePage() {
    switch (DefaultTabController.of(context)?.index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateUpdateFormPage(VSEType.value, 'POST', null);
        }));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateUpdateFormPage(VSEType.skill, 'POST', null);
        }));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateUpdateFormPage(
              VSEType.experience, 'POST', null);
        }));
        break;
    }
  }

  void _navigateToCreateMultiplePage() {
    switch (DefaultTabController.of(context)?.index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateMultipleFormPage(VSEType.value);
        }));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateMultipleFormPage(VSEType.skill);
        }));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const VSECreateMultipleFormPage(VSEType.experience);
        }));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: TabBarView(children: [
          VSEItemListView(VSEType.value, filter),
          VSEItemListView(VSEType.skill, filter),
          VSEItemListView(VSEType.experience, filter),
        ])),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: ThemeData.dark().shadowColor,
                  spreadRadius: 10,
                  blurRadius: 5,
                  offset: const Offset(0, 7),
                ),
              ],
              color: ThemeData.dark().cardColor,
              border: const Border(
                  top: BorderSide(
                      width: 1, color: Color.fromARGB(255, 102, 51, 153))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Filter',
                      ),
                      onChanged: (value) {
                        setFilter(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _navigateToCreatePage,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: _navigateToCreateMultiplePage,
                  icon: const Icon(Icons.list),
                ),
              ],
            )),
      ],
    );
  }
}
