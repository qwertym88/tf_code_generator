import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/component/global.dart';
import 'package:flutter_application_1/widget/code_widget.dart';
import 'package:flutter_application_1/widget/leftmenu_widget.dart';
import 'package:flutter_application_1/widget/rightmenu_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helloworld Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const MyHomePage(title: 'Helloworld Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int cnt = 0;

  // Widget code = const CodeWidget();
  // Widget rightmenu = const RightMenuWidget();
  final GlobalKey<CodeWidgetState> _codeWidgetKey = GlobalKey();
  final GlobalKey<RightMenuWidgetState> _rightWidgetKey = GlobalKey();

  void loadDiagram() {
    _codeWidgetKey.currentState?.buildByList(GlobalVar.modelInfo.layers);
    _rightWidgetKey.currentState?.rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('hello')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 980.0) {
            return Row(children: <Widget>[
              // TODO: 研究下到底怎么分配页面好看
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
      // TODO: 非常想弄个可展开的fab，然后将功能全部放进去
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
