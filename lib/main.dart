import 'package:flutter/material.dart';

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
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
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
        body: Column(children: <Widget>[
          Text.rich(TextSpan(
            children: [
              const TextSpan(text: 'pressed '),
              TextSpan(
                  text: '$cnt',
                  style: const TextStyle(
                      fontSize: 18.0, color: Colors.blueAccent)),
              const TextSpan(text: ' times')
            ],
          )),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: increase,
                icon: const Icon(Icons.add),
                label: const Text('add'),
              ),
              ElevatedButton(
                  onPressed: clearCnt,
                  child: const Icon(
                    Icons.clear,
                    color: Colors.redAccent,
                  ))
            ],
          ),
          TextField(
            decoration: InputDecoration(
                hintText: cnt > 5 ? 'cnt > 10' : null,
                prefixIcon: const Icon(Icons.send_outlined),
                labelText: 'some text info'),
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
        ]));
  }
}
