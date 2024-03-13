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
    case 'Conv2d':
      return LayerInfo(type: type)
        ..activation = 'Relu'
        ..nou = 32
        ..stride = 1
        ..filterSize = [3, 3]
        ..padding = 'valid';
    case 'Pool2d':
      return LayerInfo(type: type)
        ..stride = 1
        ..filterSize = [3, 3]
        ..pooling = 'MaxPooling';
    case 'Output':
      return LayerInfo(type: type)
        ..activation = 'Sigmoid'
        ..nou = 10;
    default:
      return LayerInfo(type: '');
  }
}

// 暂时写了不知道用在哪的代码
// ListView.builder(
// itemCount: validLayerType.length,
// itemBuilder: (context, index) {
//   return ListTile(
//     leading: const Icon(Icons.abc),
//     title: Text(validLayerType[index]),
//     subtitle: const Text('123'),
//     selected: selected == index,
//     onTap: () => {selected = index},
//   );
// }),

/// 中间的组件，图形化编程的主界面
///
class CodeWidget extends StatefulWidget {
  const CodeWidget({super.key});

  @override
  State<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  List<BaseLayerWidget> contacts = [];

  final List<String> validLayerType = ['Dense', 'Output', 'Conv2d', 'Pool2d'];

  // 闭包保留index
  void addNewLayer(int index, String type) {
    // LayerWidget的initState方法有一个神奇的问题，只能把初始化放在这里
    int hash = GlobalVar.addLayer(index, initLayer(type));
    BaseLayerWidget layer;
    switch (type) {
      case 'Dense':
        layer = DenseLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
      case 'Conv2d':
        layer = Conv2dLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
      case 'Pool2d':
        layer = Pool2dLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Output':
        layer = OutputLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
      default:
        layer = DenseLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
    }
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

  // 修改该层设置
  // void selectLayer

  @override
  void initState() {
    super.initState();
    int hash =
        GlobalVar.addLayer(0, LayerInfo(type: 'Input')..dimensions = [28]);
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
              icon: const Icon(Icons.add),
              onPressed: () async {
                String selected = validLayerType[0];
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('选择待插入的层类型'),
                        content: SizedBox(
                            width: 400,
                            height: 75,
                            // 非要包一层listview才不会显示错位
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                              children: [
                                DropdownMenu(
                                  width: 300,
                                  dropdownMenuEntries:
                                      validLayerType.map((value) {
                                    return DropdownMenuEntry(
                                      value: value,
                                      label: value,
                                      leadingIcon:
                                          const Icon(Icons.access_alarm),
                                    );
                                  }).toList(),
                                  initialSelection: validLayerType[0],
                                  // TODO: value=null时有bug，会吗？
                                  onSelected: (value) => selected = value!,
                                ),
                              ],
                            )),
                        actions: [
                          // 退出
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          // 确认
                          TextButton(
                            child: const Text('Add'),
                            // TODO: 选择插入的类型，先把其他层样式写好再说
                            onPressed: () => addNewLayer(index + 1, selected),
                          ),
                        ],
                      );
                    });
              },
            ),
            // TODO: 想把层之间的搞好看点
            const Divider(),
          ],
        );
      },
    );
  }
}
