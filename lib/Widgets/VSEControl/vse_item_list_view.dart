import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Models/vse_data.dart';
import 'package:vseapp/Widgets/VSEControl/vse_item_detail_view.dart';
import 'package:vseapp/vse_control_notifier.dart';

class VSEItemListView extends StatelessWidget {
  const VSEItemListView(this.vseType, this.filter, {Key? key})
      : super(key: key);
  final VSEType vseType;
  final String filter;

  void _navigateToDetailView(BuildContext context, VSEItem detailItem) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VSEItemDetailView(vseType, detailItem);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VSEControlNotifier>(builder: ((context, model, child) {
      List<VSEItem> ogList;
      switch (vseType) {
        case VSEType.value:
          ogList = model.vseValueList;
          break;
        case VSEType.skill:
          ogList = model.vseSkillList;
          break;
        case VSEType.experience:
          ogList = model.vseExperienceList;
          break;
      }
      List<Widget> listItems = ogList
          .where((VSEItem item) => item.name.contains(filter))
          .map((VSEItem item) => ListTile(
                key: ValueKey(item.url),
                title: Text(item.name),
                onTap: () {
                  _navigateToDetailView(context, item);
                },
              ))
          .toList();
      return ListView(
        controller: ScrollController(),
        children: listItems,
      );
    }));
  }
}
