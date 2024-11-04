import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tf_code_generator/component/global.dart';
import 'package:tf_code_generator/component/layer_serialize.dart';
import 'package:tf_code_generator/main.dart';
import 'package:tf_code_generator/style/style.dart';
import 'package:provider/provider.dart';

class LeftMenuWidget extends StatefulWidget {
  const LeftMenuWidget({super.key, required this.rebuildCallback});

  final void Function() rebuildCallback;

  @override
  State<LeftMenuWidget> createState() => LeftMenuWidgetState();
}

class LeftMenuWidgetState extends State<LeftMenuWidget> {
  late ModelInfo model;
  final List<String> validDatasetType = [
    'MNIST',
    'IMDB',
    'Reuters',
    'Fashion MNIST',
    'CIFAR 10',
    'CIFAR 100'
  ];

  @override
  Widget build(BuildContext context) {
    model = GlobalVar.modelInfo;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            // TODO: 中间那么大块空白干啥好呢？
            padding: EdgeInsets.fromLTRB(
                0, 0.1 * constraints.maxHeight, 0, 0.5 * constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dataset',
                  style: AppStyle.menuHeaderTextStyle,
                ),
                const SizedBox(
                  height: 40,
                ),
                DropdownButton(
                    value: model.dataset,
                    focusColor: Colors.white,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 40,
                    hint: const Text('请选择数据集'),
                    items: validDatasetType.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        model.dataset = value!;
                        Provider.of<InputChanger>(context, listen: false)
                            .updateText(value);
                      });
                    }),
              ],
            ),
          ),
          // Load Diagram
          OutlinedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    lockParentWindow: true,
                    dialogTitle: 'Select File');
                if (result != null) {
                  File file = File(result.files.single.path!);
                  String str = file.readAsStringSync();
                  GlobalVar.modelInfo = modelInfoFromJson(str);
                  // TODO: 处理非法输入，目前还不太全面
                  if (GlobalVar.modelInfo.layers.isEmpty ||
                      GlobalVar.modelInfo.layers[0].type != 'Input') {
                    return;
                  }
                  setState(() {
                    widget.rebuildCallback();
                  });
                }
              },
              child: const Text('Load Diagram')),
          const SizedBox(height: 10),
          // Save Diagram
          OutlinedButton(
              onPressed: () async {
                String? outputPath = await FilePicker.platform.saveFile(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    lockParentWindow: true,
                    fileName: 'diagram1.json',
                    dialogTitle: 'Save Diagram');
                if (outputPath != null) {
                  File file = await File(outputPath).create();
                  file.writeAsStringSync(modelInfoToJson(GlobalVar.modelInfo));
                }
              },
              child: const Text('Save Diagram'))
        ],
      );
    });
  }
}
