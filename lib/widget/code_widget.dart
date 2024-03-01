import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/common_layer.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/component/layer_serialize.dart';

/// 中间的组件，图形化编程的主界面
///
class CodeWidget extends StatefulWidget {
  const CodeWidget({super.key});

  @override
  State<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  List<Widget> contacts = [InputLayerWidget(index: 0)];

  @override
  Widget build(BuildContext context) {
    // TODO: 编写页面内容
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            contacts[index],
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add Contact'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Add'),
                          onPressed: () {
                            setState(() {
                              contacts.insert(
                                  index + 1,
                                  DenseLayerWidget(
                                    index: index + 1,
                                    deleteCallback: () =>
                                        contacts.removeAt(index),
                                  ));
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
