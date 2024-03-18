import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/component/layer_serialize.dart';
import 'package:flutter_application_1/style/style.dart';

class LeftMenuWidget extends StatefulWidget {
  const LeftMenuWidget({super.key, required this.rebuildCallback});

  final void Function() rebuildCallback;

  @override
  State<LeftMenuWidget> createState() => _LeftMenuWidgetState();
}

class _LeftMenuWidgetState extends State<LeftMenuWidget> {
  int? v;

  @override
  Widget build(BuildContext context) {
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
                // TODO: 奇丑无比的下拉按钮，感觉不太想用它
                DropdownButton(
                    value: v,
                    focusColor: Colors.white,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 40,
                    hint: const Text('请选择数据集'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('mnist 手写数字集1')),
                      DropdownMenuItem(value: 2, child: Text('mnist 手写数字集2')),
                      DropdownMenuItem(value: 3, child: Text('mnist 手写数字集3'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        v = value;
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
                    allowedExtensions: ['pdf', 'txt'],
                    lockParentWindow: true,
                    dialogTitle: 'Select File');
                if (result != null) {
                  File file = File(result.files.single.path!);
                  String str = file.readAsStringSync();
                  GlobalVar.modelInfo = modelInfoFromJson(str);
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
                    allowedExtensions: ['txt'],
                    lockParentWindow: true,
                    fileName: 'diagram1.txt',
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
