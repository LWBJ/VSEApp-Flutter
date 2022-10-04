import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vseapp/Models/vse_data.dart';
import 'package:vseapp/vse_control_notifier.dart';

class VSEDeleteDialog extends StatefulWidget {
  const VSEDeleteDialog(this.vseType, this.detailItem, {Key? key})
      : super(key: key);
  final VSEType vseType;
  final VSEItem detailItem;

  @override
  State<VSEDeleteDialog> createState() => _VSEDeleteDialogState();
}

class _VSEDeleteDialogState extends State<VSEDeleteDialog> {
  late final VSEControlNotifier model;
  bool isLoading = false;
  String statusMessage = '';

  void _deleteItem() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    var apiResponse = await model.deleteVSEDataAndNotify(
        widget.vseType, widget.detailItem.url);

    if (apiResponse.statusString == 'OK') {
      _backToListView();
    } else {
      setState(() {
        statusMessage = apiResponse.statusString;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _backToListView() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    model = Provider.of<VSEControlNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Delete ${widget.vseType.asString}: ${widget.detailItem.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('This action cannot be undone'),
          (isLoading
              ? const CircularProgressIndicator(value: null)
              : const SizedBox.shrink())
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            if (isLoading) return;
            _deleteItem();
          },
        ),
        TextButton(
          onPressed: () {
            if (isLoading) return;
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
