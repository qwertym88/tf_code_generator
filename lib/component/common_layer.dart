import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/component/layer_serialize.dart';
import 'package:flutter_application_1/style/style.dart';

// label样式
Widget buildLayerLabel(
    String name, void Function() modify, void Function() delete) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: modify,
        icon: const Icon(Icons.settings),
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      ),
      Text(
        name,
        style: AppStyle.layerLabelTextStyle,
      ),
      IconButton(
        onPressed: delete,
        icon: const Icon(Icons.delete),
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      ),
    ],
  );
}

// 为了偷懒把列表型参数的修改弄成同一种dialog
class ListModifyDialog extends StatefulWidget {
  const ListModifyDialog({super.key, required this.list});

  final List<int> list;

  @override
  State<ListModifyDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<ListModifyDialog> {
  int inputDimension = 1;

  // 带圆边框的输入框
  Widget roundedTextField(int index, [double paddingRight = 0]) {
    // 保证该index存在，初始值为0
    String defalutText = widget.list.elementAt(index).toString();
    return Container(
      width: 200 - paddingRight,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28.0), // Set the desired border radius
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: TextField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.share),
          border: InputBorder.none,
          // 通过设置hintText达到显示保存的值的效果
          hintText: defalutText,
        ),
        onChanged: (value) {
          // 默认值为0
          widget.list[index] = value.isEmpty ? 0 : int.parse(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确定ListView长度
    inputDimension = widget.list.length;
    return AlertDialog(
      title: const Text('Input层设置'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            itemCount: inputDimension + 1,
            itemBuilder: (context, index) {
              // 输入框和删除按钮横向排列
              if (index == inputDimension - 1 && index != 0) {
                return Column(children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      roundedTextField(index, 40),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              inputDimension--;
                              widget.list.removeLast();
                            });
                          },
                          icon: const Icon(Icons.remove))
                    ],
                  ),
                  const SizedBox(height: 10),
                ]);
              } else if (index == inputDimension) {
                return ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add dimensionality'),
                  onPressed: () {
                    setState(() {
                      inputDimension++;
                      widget.list.add(0);
                    });
                  },
                );
              } else {
                return Column(children: [
                  // 用SizedBox填顶部padding
                  const SizedBox(height: 10),
                  roundedTextField(index),
                ]);
              }
            }),
      ),
      actions: [
        // 搞取消按钮纯粹是给自己找麻烦
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ), // 确认
      ],
    );
  }
}

// 由于想要差异化每一个下拉菜单，还是多复制粘贴点重复代码为好

// xxxLayerWidget的基类，方便管理
abstract class BaseLayerWidget extends StatefulWidget {
  // hash为该layer widget所维护的LayerInfo的hashCode而不是自己的，为保一一对应
  const BaseLayerWidget({super.key, required this.hash});
  final int hash;
}

// Input Layer
class InputLayerWidget extends BaseLayerWidget {
  const InputLayerWidget({super.key, required super.hash});

  final String type = 'Input';

  @override
  State<InputLayerWidget> createState() => _InputLayerWidgetState();
}

class _InputLayerWidgetState extends State<InputLayerWidget> {
  late LayerInfo layerInfo;

  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListModifyDialog(list: layerInfo.dimensions!);
        });
    print(layerInfo.toJson());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    layerInfo = GlobalVar.getLayer(widget.hash);
    // InputLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 120,
      child: Center(
        child: Column(children: [
          // 特殊的LayerLabel，少一个删除按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: modifyCallback,
                icon: const Icon(Icons.settings),
              ),
              Text(
                widget.type,
                style: AppStyle.layerLabelTextStyle,
              )
            ],
          ),
          // 具体内容
          Text(
            'Input Shape: ${layerInfo.dimensions}',
            style: AppStyle.layerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Dense Layer
class DenseLayerWidget extends BaseLayerWidget {
  const DenseLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String type = 'Dense';

  @override
  State<DenseLayerWidget> createState() => _DenseLayerWidgetState();
}

class _DenseLayerWidgetState extends State<DenseLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = ['Relu', 'Tanh'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Dense层设置'),
            content: SizedBox(
              width: 400,
              height: 300,
              child: ListView(
                  // TODO: 感觉居中后没那么好看，再多想想？
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    const SizedBox(height: 25),
                    // 激活层设置
                    DropdownMenu(
                      dropdownMenuEntries: validActType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          // TODO: 合适的icon好难找，干脆不要得了
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.activation,
                      label: const Text('激活层'),
                      onSelected: (value) => layerInfo.activation = value,
                    ),
                    // 用SizedBox填padding
                    const SizedBox(height: 25),
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: '神经元数',
                        // hintText: '123',
                        prefixIcon: Icon(Icons.share),
                      ),
                    )
                  ]),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ), // 取消
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ), // 确认
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    layerInfo = GlobalVar.getLayer(widget.hash);
    // DenseLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 150,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.type, modifyCallback, widget.deleteCallback),
          // 具体内容
          Text(
            'Number of Units: ${layerInfo.nou}',
            style: AppStyle.layerContextTextStyle,
          ),
          Text(
            'Activation: ${layerInfo.activation}',
            style: AppStyle.layerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Output Layer
// 为了方便小学生理解，感觉还是专门搞一个“输出层”比较好
class OutputLayerWidget extends BaseLayerWidget {
  const OutputLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  final void Function() deleteCallback;
  final String name = 'Output';

  @override
  State<OutputLayerWidget> createState() => _OutputLayerWidgetState();
}

class _OutputLayerWidgetState extends State<OutputLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = ['Softmax', 'Sigmoid'];

  void modifyCallback() {}

  @override
  Widget build(BuildContext context) {
    layerInfo = GlobalVar.getLayer(widget.hash);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 150,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.name, modifyCallback, widget.deleteCallback),
          Text(
            'Activation: ${layerInfo.activation}',
            style: AppStyle.layerContextTextStyle,
          )
        ]),
      ),
    );
  }
}
