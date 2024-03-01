import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/component/layer_serialize.dart';
import 'package:flutter_application_1/style/style.dart';

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
// Widget buildDropdownMenu(List<String> options) {
//   return
// }

// Widget buildDropdownMenu(List<String> options) {
//   var entry = DropdownMenuEntry(value: value, label: label);
//   return DropdownMenu(dropdownMenuEntries: options.map((e) {
//     return DropdownMenuEntry(value: )
//   }).toList());
// }

abstract class BaseLayerWidget extends StatefulWidget {
  const BaseLayerWidget({super.key, required this.index});
  final int index;
}

// Input Layer
class InputLayerWidget extends BaseLayerWidget {
  const InputLayerWidget({super.key, required super.index});

  final String name = 'Input';

  @override
  State<InputLayerWidget> createState() => _InputLayerWidgetState();
}

class _InputLayerWidgetState extends State<InputLayerWidget> {
  // 经过一番思考，不打算让小学生学数据维度是什么，设置成固定的算了
  var layerInfo = LayerInfo(type: 'Input')..dimensions = [28, 28, 1];

  void modifyCallback() {}

  @override
  Widget build(BuildContext context) {
    GlobalVar.addLayers(0, layerInfo);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 200,
      child: Center(
        child: Column(children: [
          // LayerLabel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: modifyCallback,
                icon: const Icon(Icons.settings),
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              ),
              Text(
                widget.name,
                style: AppStyle.layerLabelTextStyle,
              )
            ],
          ),
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
      {super.key, required super.index, required this.deleteCallback});

  final void Function() deleteCallback;
  final String name = 'Dense';

  @override
  State<DenseLayerWidget> createState() => _DenseLayerWidgetState();
}

class _DenseLayerWidgetState extends State<DenseLayerWidget> {
  final List<String> validActType = ['Relu', 'Tanh'];
  var layerInfo = LayerInfo(type: 'Dense')
    ..activation = 'relu'
    ..nou = 10;
  int nou = 10;
  String activation = 'ReLu';

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
                  helperText: '12333',
                  onSelected: (value) => layerInfo.activation = value,
                )
              ]),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    GlobalVar.addLayers(widget.index, layerInfo);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 200,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.name, modifyCallback, widget.deleteCallback),
          Text(
            'Number of Units: $nou',
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

// Dense Layer
class OutputLayerWidget extends BaseLayerWidget {
  const OutputLayerWidget(
      {super.key, required super.index, required this.deleteCallback});

  final void Function() deleteCallback;
  final String name = 'Output';

  @override
  State<OutputLayerWidget> createState() => _OutputLayerWidgetState();
}

class _OutputLayerWidgetState extends State<OutputLayerWidget> {
  // 为了方便小学生理解，感觉还是专门搞一个“输出层”比较好
  String activation = 'Softmax';

  void modifyCallback() {}

  @override
  Widget build(BuildContext context) {
    // GlobalVar.addLayers(widget.index, layerInfo);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 200,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.name, modifyCallback, widget.deleteCallback),
          Text(
            'Activation: $activation',
            style: AppStyle.layerContextTextStyle,
          )
        ]),
      ),
    );
  }
}
