import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tf_code_generator/component/global.dart';
import 'package:tf_code_generator/component/layer_serialize.dart';
import 'package:tf_code_generator/main.dart';
import 'package:tf_code_generator/style/style.dart';
import 'package:provider/provider.dart';

// 每一个层的显示内容、修改方式虽然大体相似，但内容都不一样，所以有些代码虽然反复无数次出现，例如
// 点击修改按钮弹出弹窗、布局方式等，但总是要重新写一遍。所以看着有点乱。

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
  const ListModifyDialog({super.key, required this.list, required this.label});

  final List<int> list;
  final String label;

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
      title: Text(widget.label, style: AppStyle.dialogTitleTextStyle),
      content: SizedBox(
        width: 400,
        height: 225,
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
                ]);
              } else if (index == inputDimension) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add dimensionality'),
                      onPressed: () {
                        setState(() {
                          inputDimension++;
                          widget.list.add(0);
                        });
                      },
                    ),
                  ],
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

  final String label = 'Input';

  @override
  State<InputLayerWidget> createState() => _InputLayerWidgetState();
}

class _InputLayerWidgetState extends State<InputLayerWidget> {
  late LayerInfo layerInfo;

  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListModifyDialog(
            list: layerInfo.dimensions!,
            label: 'Input层设置',
          );
        });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    layerInfo = GlobalVar.getLayer(widget.hash);
    String dataset = Provider.of<InputChanger>(context).dataset;
    // InputLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      height: {'IMDB', 'Reuters'}.contains(dataset) ? 130 : 100,
      child: Center(
        child: Column(children: [
          // 特殊的LayerLabel，少一个删除按钮
          Text(
            widget.label,
            style: AppStyle.layerLabelTextStyle,
          ),
          // 具体内容
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Input Shape: ${layerInfo.dimensions}',
                style: AppStyle.layerContextTextStyle,
              ),
              IconButton(
                  iconSize: 18.0,
                  onPressed: modifyCallback,
                  icon: const Icon(Icons.border_color))
            ],
          ),
          {'IMDB', 'Reuters'}.contains(dataset)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vocabulary:    ',
                        style: AppStyle.layerContextTextStyle),
                    SizedBox(
                        width: 100,
                        height: 24,
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: layerInfo.vocabulary.toString(),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            layerInfo.vocabulary = value.isEmpty
                                ? layerInfo.vocabulary
                                : int.parse(value);
                          },
                        )),
                  ],
                )
              : Container(),
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
  final String label = 'Dense';

  @override
  State<DenseLayerWidget> createState() => _DenseLayerWidgetState();
}

class _DenseLayerWidgetState extends State<DenseLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = [
    'Linear',
    'Relu',
    'Tanh',
    'Selu',
    'Elu',
    'Leaky_relu'
  ];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Dense层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 180,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    // 激活层设置
                    const SizedBox(height: 25),
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
                      decoration: InputDecoration(
                          labelText: '神经元数',
                          // helperText: '神经元数',
                          prefixIcon: const Icon(Icons.share),
                          hintText: layerInfo.nou.toString()),
                      onChanged: (value) {
                        layerInfo.nou =
                            value.isEmpty ? layerInfo.nou : int.parse(value);
                      },
                    )
                  ]),
            ),
            actions: [
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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 120,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
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
  final String label = 'Output';

  @override
  State<OutputLayerWidget> createState() => _OutputLayerWidgetState();
}

class _OutputLayerWidgetState extends State<OutputLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = ['Softmax', 'Sigmoid'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Output层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 180,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    const SizedBox(height: 25),
                    // 激活层设置
                    DropdownMenu(
                      dropdownMenuEntries: validActType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
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
                      decoration: InputDecoration(
                          labelText: '神经元数',
                          prefixIcon: const Icon(Icons.share),
                          hintText: layerInfo.nou.toString()),
                      onChanged: (value) {
                        layerInfo.nou =
                            value.isEmpty ? layerInfo.nou : int.parse(value);
                      },
                    )
                  ]),
            ),
            actions: [
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
    // OutputLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 100,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
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

// Convolution Layer
class ConvolutionLayerWidget extends BaseLayerWidget {
  const ConvolutionLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Convolution';

  @override
  State<ConvolutionLayerWidget> createState() => _ConvolutionLayerWidgetState();
}

class _ConvolutionLayerWidgetState extends State<ConvolutionLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = ['Linear', 'Relu', 'Tanh'];
  final List<String> validPadding = ['Valid', 'Same'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Convolution层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 300,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    const SizedBox(height: 25),
                    // 激活层设置
                    DropdownMenu(
                      dropdownMenuEntries: validActType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.activation,
                      label: const Text('激活层'),
                      onSelected: (value) => layerInfo.activation = value,
                    ),
                    const SizedBox(height: 25),
                    // Padding设置
                    DropdownMenu(
                      dropdownMenuEntries: validPadding.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.padding,
                      label: const Text('Padding'),
                      onSelected: (value) => layerInfo.padding = value,
                    ),
                    // 神经元数设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '神经元数',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.nou.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.nou =
                            value.isEmpty ? layerInfo.nou : int.parse(value);
                      },
                    ),
                    // Stride设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Stride',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.stride.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.stride =
                            value.isEmpty ? layerInfo.stride : int.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // ConvolutionLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 180,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kernel Size: ${layerInfo.kernelSize}',
                style: AppStyle.denserLayerContextTextStyle,
              ),
              IconButton(
                  iconSize: 12.0,
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ListModifyDialog(
                            list: layerInfo.kernelSize!,
                            label: 'Kernel Size设置',
                          );
                        });
                    setState(() {});
                  },
                  icon: const Icon(Icons.border_color)),
            ],
          ),
          Text(
            'Number of fliters: ${layerInfo.nou}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Stride: ${layerInfo.stride}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Padding: ${layerInfo.padding}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Activation: ${layerInfo.activation}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Pooling Layer
class PoolingLayerWidget extends BaseLayerWidget {
  const PoolingLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Pooling';

  @override
  State<PoolingLayerWidget> createState() => _PoolingLayerWidgetState();
}

class _PoolingLayerWidgetState extends State<PoolingLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validPoolType = [
    'MaxPooling',
    'AvaragePooling',
    'GlobalMaxPooling'
  ];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Pooling层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 150,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    const SizedBox(height: 25),
                    // PoolType 设置
                    DropdownMenu(
                      dropdownMenuEntries: validPoolType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.method,
                      label: const Text('Pooling'),
                      onSelected: (value) => layerInfo.method = value,
                    ),
                    // Stride设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Stride',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.stride.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.stride =
                            value.isEmpty ? layerInfo.stride : int.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // PoolingLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: layerInfo.method == 'GlobalMaxPooling' ? 110 : 130,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pool Size: ${layerInfo.kernelSize}',
                style: AppStyle.denserLayerContextTextStyle,
              ),
              IconButton(
                  iconSize: 12.0,
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ListModifyDialog(
                            list: layerInfo.kernelSize!,
                            label: 'Pool Size设置',
                          );
                        });
                    setState(() {});
                  },
                  icon: const Icon(Icons.border_color)),
            ],
          ),
          layerInfo.method == 'GlobalMaxPooling'
              ? Container()
              : Text(
                  'Stride: ${layerInfo.stride}',
                  style: AppStyle.denserLayerContextTextStyle,
                ),
          Text(
            'Pooling: ${layerInfo.method}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Convolution Layer
class LSTMLayerWidget extends BaseLayerWidget {
  const LSTMLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'LSTM';

  @override
  State<LSTMLayerWidget> createState() => _LSTMLayerWidgetState();
}

class _LSTMLayerWidgetState extends State<LSTMLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validActType = ['Tanh', 'Relu'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'LSTM层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 230,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    // 激活层设置
                    DropdownMenu(
                      dropdownMenuEntries: validActType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.activation,
                      label: const Text('激活层'),
                      onSelected: (value) => layerInfo.activation = value,
                    ),
                    // 神经元数设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '单元数',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.nou.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.nou =
                            value.isEmpty ? layerInfo.nou : int.parse(value);
                      },
                    ),
                    // Dropout设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Dropout',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.dropout.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.dropout = value.isEmpty
                            ? layerInfo.dropout
                            : double.parse(value);
                      },
                    ),
                    // Recurrent Dropout设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Recurrent Dropout',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.dropout.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.dropout = value.isEmpty
                            ? layerInfo.dropout
                            : double.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // ConvolutionLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 140,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Text(
            'Units: ${layerInfo.nou}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Activation: ${layerInfo.activation}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Dropout: ${layerInfo.dropout}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
          Text(
            'Recurrent Dropout: ${layerInfo.recurrentDropout}',
            style: AppStyle.denserLayerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Normalization Layer
class NormalizationLayerWidget extends BaseLayerWidget {
  const NormalizationLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Normalization';

  @override
  State<NormalizationLayerWidget> createState() =>
      _NormalizationLayerWidgetState();
}

class _NormalizationLayerWidgetState extends State<NormalizationLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validNormType = [
    'BatchNormalization',
    'LayerNormalization',
    'GroupNormalization'
  ];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Normalization层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 150,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    const SizedBox(height: 25),
                    // Action设置
                    DropdownMenu(
                      dropdownMenuEntries: validNormType.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.method,
                      label: const Text('Normalization'),
                      onSelected: (value) => layerInfo.method = value,
                    ),
                    // Axis设置
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Axis',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.axis.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.axis =
                            value.isEmpty ? layerInfo.axis : int.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // NormalizationLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 100,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Text(
            'Axis: ${layerInfo.axis}',
            style: AppStyle.layerContextTextStyle,
          ),
          Text(
            'Normalization: ${layerInfo.method}',
            style: AppStyle.layerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

class ReshapeLayerWidget extends BaseLayerWidget {
  const ReshapeLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Reshaping';

  @override
  State<ReshapeLayerWidget> createState() => _ReshapeLayerWidgetState();
}

class _ReshapeLayerWidgetState extends State<ReshapeLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validMethods = ['Reshape', 'Flatten'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Reshaping层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 75,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    // Method设置
                    DropdownMenu(
                      dropdownMenuEntries: validMethods.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.method,
                      label: const Text('Method'),
                      onSelected: (value) => layerInfo.method = value,
                    ),
                  ]),
            ),
            actions: [
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
    // ReshapeLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: layerInfo.method == 'Reshape' ? 110 : 70,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Text(
            'Method: ${layerInfo.method}',
            style: AppStyle.layerContextTextStyle,
          ),
          layerInfo.method == 'Reshape'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dimension: ${layerInfo.dimensions}',
                      style: AppStyle.layerContextTextStyle,
                    ),
                    IconButton(
                        iconSize: 12.0,
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ListModifyDialog(
                                  list: layerInfo.dimensions!,
                                  label: 'Dimension设置',
                                );
                              });
                          setState(() {});
                        },
                        icon: const Icon(Icons.border_color)),
                  ],
                )
              : Container(),
        ]),
      ),
    );
  }
}

class DropoutLayerWidget extends BaseLayerWidget {
  const DropoutLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Dropout';

  @override
  State<DropoutLayerWidget> createState() => _DropoutLayerWidgetState();
}

class _DropoutLayerWidgetState extends State<DropoutLayerWidget> {
  late LayerInfo layerInfo;

  final List<String> validMethod = ['Dropout', 'SpatialDropout'];

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Dropout层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 120,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    // Action设置
                    DropdownMenu(
                      dropdownMenuEntries: validMethod.map((value) {
                        return DropdownMenuEntry(
                          value: value,
                          label: value,
                          leadingIcon: const Icon(Icons.access_alarm),
                        );
                      }).toList(),
                      width: 250,
                      initialSelection: layerInfo.method,
                      label: const Text('Method'),
                      onSelected: (value) => layerInfo.method = value,
                    ),
                    // Rate设置
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        // 输入小数
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Dropout Rate',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.dropout.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.dropout = value.isEmpty
                            ? layerInfo.dropout
                            : double.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // DropoutLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: layerInfo.method == 'SpatialDropout' ? 140 : 100,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          layerInfo.method == 'SpatialDropout'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dimension: ${layerInfo.dimensions}',
                      style: AppStyle.layerContextTextStyle,
                    ),
                    IconButton(
                        iconSize: 12.0,
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ListModifyDialog(
                                  list: layerInfo.dimensions!,
                                  label: 'Dimension设置',
                                );
                              });
                          setState(() {});
                        },
                        icon: const Icon(Icons.border_color)),
                  ],
                )
              : Container(),
          Text(
            'Dropout Rate: ${layerInfo.dropout}',
            style: AppStyle.layerContextTextStyle,
          ),
          Text(
            'Method: ${layerInfo.method}',
            style: AppStyle.layerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}

// Embedding
class EmbeddingLayerWidget extends BaseLayerWidget {
  const EmbeddingLayerWidget(
      {super.key, required super.hash, required this.deleteCallback});

  // 实现'按下按钮后删除自己'的行为
  final void Function() deleteCallback;
  final String label = 'Embedding';

  @override
  State<EmbeddingLayerWidget> createState() => _EmbeddingLayerWidgetState();
}

class _EmbeddingLayerWidgetState extends State<EmbeddingLayerWidget> {
  late LayerInfo layerInfo;

  // 修改该层设置
  void modifyCallback() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Embedding层设置',
              style: AppStyle.dialogTitleTextStyle,
            ),
            content: SizedBox(
              width: 400,
              height: 120,
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(75, 0, 75, 0),
                  children: [
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Input Size',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.inputDim.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.inputDim = value.isEmpty
                            ? layerInfo.inputDim
                            : int.parse(value);
                      },
                    ),
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Output Size',
                        prefixIcon: const Icon(Icons.share),
                        hintText: layerInfo.outputDim.toString(),
                      ),
                      onChanged: (value) {
                        layerInfo.outputDim = value.isEmpty
                            ? layerInfo.outputDim
                            : int.parse(value);
                      },
                    ),
                  ]),
            ),
            actions: [
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
    // DropoutLayerWidget显示效果
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 100,
      child: Center(
        child: Column(children: [
          buildLayerLabel(widget.label, modifyCallback, widget.deleteCallback),
          // 具体内容
          Text(
            'Input Size: ${layerInfo.inputDim}',
            style: AppStyle.layerContextTextStyle,
          ),
          Text(
            'Output Size: ${layerInfo.outputDim}',
            style: AppStyle.layerContextTextStyle,
          ),
        ]),
      ),
    );
  }
}
