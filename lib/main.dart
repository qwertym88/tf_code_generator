import 'package:flutter/material.dart';
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

  void increase() {
    setState(() {
      cnt++;
    });
  }

  void clearCnt() {
    setState(() {
      cnt = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('hello')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 980.0) {
            return const Row(children: <Widget>[
              // TODO: 研究下到底怎么分配页面好看
              SizedBox(
                width: 335,
                child: LeftMenuWidget(),
              ),
              Expanded(child: CodeWidget()),
              SizedBox(
                width: 335,
                child: RightMenuWidget(),
              ),
            ]);
          } else {
            return const CodeWidget();
          }
        },
      ),
      // TODO: 非常想弄个可展开的fab，然后将功能全部放进去
      floatingActionButton: const IconButton(
        icon: Icon(Icons.add),
        onPressed: null,
      ),
    );
  }
}
