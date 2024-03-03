import 'package:flutter/material.dart';
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

  final String name = 'Input';

  @override
  State<InputLayerWidget> createState() => _InputLayerWidgetState();
}

class _InputLayerWidgetState extends State<InputLayerWidget> {
  // 经过一番思考，不打算让小学生学数据维度是什么，设置成固定的算了
  late LayerInfo layerInfo;

  void modifyCallback() {}

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
                widget.name,
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
              child: ListView(children: [
                // 激活层设置
                DropdownMenu(
                  dropdownMenuEntries: validActType.map((value) {
                    return DropdownMenuEntry(
                      value: value,
                      label: value,
                      leadingIcon: const Icon(Icons.access_alarm),
                    );
                  }).toList(),
                  width: 200,
                  initialSelection: layerInfo.activation,
                  label: const Text('激活层'),
                  onSelected: (value) => layerInfo.activation = value,
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
