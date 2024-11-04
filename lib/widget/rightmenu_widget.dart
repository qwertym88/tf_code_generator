import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tf_code_generator/component/global.dart';
import 'package:tf_code_generator/component/layer_serialize.dart';
import 'package:tf_code_generator/style/style.dart';

/// 右侧的界面，目前只是占空用的，没想到该放啥
///
class RightMenuWidget extends StatefulWidget {
  const RightMenuWidget({super.key});

  @override
  State<RightMenuWidget> createState() => RightMenuWidgetState();
}

class RightMenuWidgetState extends State<RightMenuWidget> {
  late ModelInfo model;

  final List<String> validLossType = [
    'MSE',
    'CE',
    'Categorical_Crossentropy',
    'Binary_Crossentropy',
  ];

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    model = GlobalVar.modelInfo;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 0.04 * constraints.maxHeight),
        OptimizerWidget(model: model),
        SizedBox(height: 0.15 * constraints.maxHeight),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Loss Function',
            style: AppStyle.menuHeaderTextStyle,
          ),
          DropdownMenu(
            dropdownMenuEntries: validLossType.map((value) {
              return DropdownMenuEntry(
                value: value,
                label: value,
              );
            }).toList(),
            inputDecorationTheme:
                // 仅下划线
                const InputDecorationTheme(border: UnderlineInputBorder()),
            width: 250,
            initialSelection: model.loss,
            onSelected: (value) => model.loss = value,
          )
        ]),
        SizedBox(height: 0.125 * constraints.maxHeight),
        TrainParamWidget(model: model),
      ]);
    });
  }
}

// 缩减粒度仅局部重绘
class OptimizerWidget extends StatefulWidget {
  const OptimizerWidget({super.key, required this.model});

  final ModelInfo model;

  @override
  State<OptimizerWidget> createState() => _OptimizerWidgetState();
}

class _OptimizerWidgetState extends State<OptimizerWidget> {
  final List<String> validOptType = ['SGD', 'RMSprop', 'Adam'];

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text(
        'Optimizer',
        style: AppStyle.menuHeaderTextStyle,
      ),
      DropdownMenu(
        dropdownMenuEntries: validOptType.map((value) {
          return DropdownMenuEntry(
            value: value,
            label: value,
          );
        }).toList(),
        inputDecorationTheme:
            // 仅下划线
            const InputDecorationTheme(border: UnderlineInputBorder()),
        width: 250,
        initialSelection: widget.model.optimizer,
        onSelected: (value) => widget.model.optimizer = value,
      ),
      const SizedBox(height: 25),
      const Text(
        'learning rate',
        style: AppStyle.hintTextStyle,
      ),
      SizedBox(
          width: 120,
          height: 30,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              // 输入小数
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: widget.model.lr.toString(),
            ),
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                // 默认值0.001
                widget.model.lr = double.tryParse(value) ?? 0.001;
              });
            },
          ))
    ]);
  }
}

// 缩减粒度仅局部重绘
class TrainParamWidget extends StatefulWidget {
  const TrainParamWidget({super.key, required this.model});

  final ModelInfo model;

  @override
  State<TrainParamWidget> createState() => _TrainParamWidgetState();
}

class _TrainParamWidgetState extends State<TrainParamWidget> {
  final List<String> validOptType = ['SGD', 'Adam'];

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text(
        'Train',
        style: AppStyle.menuHeaderTextStyle,
      ),
      const SizedBox(height: 20),
      const Text(
        'Number of Epochs',
        style: AppStyle.hintTextStyle,
      ),
      SizedBox(
          width: 120,
          height: 30,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: widget.model.epoch.toString(),
            ),
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                // 默认值0.001
                widget.model.epoch = int.tryParse(value) ?? 10;
              });
            },
          )),
      const SizedBox(height: 15),
      const Text(
        'Batch Size',
        style: AppStyle.hintTextStyle,
      ),
      SizedBox(
          width: 120,
          height: 30,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: widget.model.batch.toString(),
            ),
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                widget.model.batch = int.tryParse(value) ?? 32;
              });
            },
          )),
    ]);
  }
}
