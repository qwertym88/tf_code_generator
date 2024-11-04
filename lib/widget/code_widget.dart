import 'package:flutter/material.dart';
import 'package:tf_code_generator/component/common_layer.dart';
import 'package:tf_code_generator/component/global.dart';
import 'package:tf_code_generator/component/layer_serialize.dart';

LayerInfo initLayerInfo(String type) {
  switch (type) {
    case 'Input':
      return LayerInfo(type: type)
        ..dimensions = [28, 28, 1]
        ..vocabulary = 20000;
    case 'Dense':
      return LayerInfo(type: type)
        ..activation = 'Linear'
        ..nou = 10;
    case 'Convolution':
      return LayerInfo(type: type)
        ..activation = 'Linear'
        ..nou = 32
        ..stride = 1
        ..kernelSize = [3, 3]
        ..padding = 'Valid';
    case 'Pooling':
      return LayerInfo(type: type)
        ..stride = 1
        ..kernelSize = [2, 2]
        ..method = 'MaxPooling';
    case 'LSTM':
      return LayerInfo(type: type)
        ..nou = 10
        ..dropout = 0.2
        ..recurrentDropout = 0.2
        ..activation = 'Tanh';
    case 'Normalization':
      return LayerInfo(type: type)
        ..axis = -1
        ..method = 'BatchNormalization';
    case 'Reshaping':
      return LayerInfo(type: type)
        ..dimensions = [28, 28, 1]
        ..method = 'Reshape';
    case 'Dropout':
      return LayerInfo(type: type)
        ..dropout = 0.25
        ..method = 'Dropout'
        ..dimensions = [1];
    case 'Embedding':
      return LayerInfo(type: type)
        ..inputDim = 400
        ..outputDim = 50;
    case 'Output':
      return LayerInfo(type: type)
        ..activation = 'Sigmoid'
        ..nou = 10;
    default:
      return LayerInfo(type: '');
  }
}

/// 中间的组件，图形化编程的主界面
class CodeWidget extends StatefulWidget {
  const CodeWidget({super.key});

  @override
  State<CodeWidget> createState() => CodeWidgetState();
}

class CodeWidgetState extends State<CodeWidget> {
  List<BaseLayerWidget> layerWidgets = [];

  final List<String> validLayerType = [
    'Dense',
    'Convolution',
    'Pooling',
    'LSTM',
    'Normalization',
    'Reshaping',
    'Dropout',
    'Embedding',
    'Output',
  ];

  BaseLayerWidget fromType(String type, int hash) {
    BaseLayerWidget widget;
    switch (type) {
      case 'Input':
        widget = InputLayerWidget(hash: hash);
      case 'Dense':
        widget = DenseLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
      case 'Convolution':
        widget = ConvolutionLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
      case 'Pooling':
        widget = PoolingLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'LSTM':
        widget = LSTMLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Normalization':
        widget = NormalizationLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Reshaping':
        widget = ReshapeLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Dropout':
        widget = DropoutLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Embedding':
        widget = EmbeddingLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      case 'Output':
        widget = OutputLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
      default:
        widget = DenseLayerWidget(
          hash: hash,
          deleteCallback: () => deleteLayer(hash),
        );
        break;
    }
    return widget;
  }

  // 闭包保留index
  void addNewLayer(int index, LayerInfo info) {
    int hash = GlobalVar.addLayer(index, info);
    BaseLayerWidget widget = fromType(info.type, hash);
    setState(() {
      layerWidgets.insert(index, widget);
      Navigator.of(context).pop();
    });
  }

  void deleteLayer(int hash) {
    setState(() {
      layerWidgets.removeWhere((element) => element.hash == hash);
      GlobalVar.removeLayer(hash);
    });
  }

  // load diagram后更新code widget显示效果
  void buildByList(List<LayerInfo> layers) {
    layerWidgets.clear();
    setState(() {
      for (LayerInfo info in layers) {
        int hash = info.hashCode;
        BaseLayerWidget widget = fromType(info.type, hash);
        layerWidgets.add(widget);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    int hash = GlobalVar.addLayer(0, initLayerInfo('Input'));
    layerWidgets.add(InputLayerWidget(
      hash: hash,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: layerWidgets.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            layerWidgets[index],
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                // 待添加的layer type
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
                            onPressed: () =>
                                addNewLayer(index + 1, initLayerInfo(selected)),
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
