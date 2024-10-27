import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/widget/code_widget.dart';
import 'package:flutter_application_1/widget/leftmenu_widget.dart';
import 'package:flutter_application_1/widget/rightmenu_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => InputChanger(),
        child: MaterialApp(
          title: 'Helloworld Demo',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity),
          home: const MyHomePage(title: 'Helloworld Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int cnt = 0;

  final GlobalKey<CodeWidgetState> _codeWidgetKey = GlobalKey();
  final GlobalKey<LeftMenuWidgetState> _leftWidgetKey = GlobalKey();
  final GlobalKey<RightMenuWidgetState> _rightWidgetKey = GlobalKey();

  void loadDiagram() {
    // 所有页面都要重构
    _codeWidgetKey.currentState?.buildByList(GlobalVar.modelInfo.layers);
    _leftWidgetKey.currentState?.setState(() {});
    _rightWidgetKey.currentState?.rebuild();
    Provider.of<InputChanger>(context, listen: false)
        .updateText(GlobalVar.modelInfo.dataset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('hello')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 折叠效果
          if (constraints.maxWidth > 980.0) {
            return Row(children: <Widget>[
              SizedBox(
                width: 335,
                child: LeftMenuWidget(rebuildCallback: loadDiagram),
              ),
              Expanded(child: CodeWidget(key: _codeWidgetKey)),
              SizedBox(
                width: 335,
                child: RightMenuWidget(key: _rightWidgetKey),
              ),
            ]);
          } else {
            return CodeWidget(key: _codeWidgetKey);
          }
        },
      ),
      floatingActionButton: IconButton(
          icon: const Icon(Icons.arrow_right),
          iconSize: 64,
          tooltip: 'Generate Code',
          onPressed: () async {
            String? outputPath = await FilePicker.platform.saveFile(
                type: FileType.custom,
                allowedExtensions: ['py'],
                lockParentWindow: true,
                fileName: 'code.py',
                dialogTitle: 'Genenate Code');
            if (outputPath != null) {
              File file = await File(outputPath).create();
              file.writeAsStringSync(generate(GlobalVar.modelInfo));
            }
          }),
    );
  }
}

class InputChanger with ChangeNotifier {
  // the same as GlobalVar.modelInfo.dataset's default value
  String _dataset = 'MNIST';
  String get dataset => _dataset;

  void updateText(String dataset) {
    _dataset = dataset;
    notifyListeners(); // 通知所有监听者更新
  }
}
