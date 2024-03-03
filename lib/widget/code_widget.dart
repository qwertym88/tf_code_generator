import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/common_layer.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/component/layer_serialize.dart';

LayerInfo initLayer(String type) {
  switch (type) {
    case 'Input':
      return LayerInfo(type: type)..dimensions = [1, 28, 28];
    case 'Dense':
      return LayerInfo(type: type)
        ..activation = 'Relu'
        ..nou = 10;
    default:
      return LayerInfo(type: '');
  }
}

/// 中间的组件，图形化编程的主界面
///
class CodeWidget extends StatefulWidget {
  const CodeWidget({super.key});

  @override
  State<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  List<BaseLayerWidget> contacts = [];

  // 闭包保留index
  void addNewLayer(int index) {
    // LayerWidget的initState方法有一个神奇的问题，只能把初始化放在这里
    int hash = GlobalVar.addLayer(index, initLayer('Dense'));
    var layer = DenseLayerWidget(
      hash: hash,
      deleteCallback: () => deleteLayer(hash),
    );
    setState(() {
      // print('current place $index $hash');
      contacts.insert(index, layer);
      Navigator.of(context).pop();
    });
    // print(GlobalVar.modelInfo.toJson());
    // for (int i = 0; i < contacts.length; i++) {
    //   print('$i: ${contacts[i].hash}, ${contacts[i].hashCode}');
    // }
  }

  void deleteLayer(int hash) {
    setState(() {
      contacts.removeWhere((element) => element.hash == hash);
      GlobalVar.removeLayer(hash);
      // print(GlobalVar.modelInfo.toJson());
    });
  }

  @override
  void initState() {
    super.initState();
    int hash = GlobalVar.addLayer(0, LayerInfo(type: 'Input'));
    contacts.add(InputLayerWidget(
      hash: hash,
    ));
  }

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
                    // 增加layer的弹窗
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
                        // 退出
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        // 确认
                        TextButton(
                          child: Text('Add'),
                          onPressed: () => addNewLayer(index + 1),
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
