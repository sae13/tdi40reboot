import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TD-i 40 Reboot',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'TD-i 40 Reboot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = "Touch To Reboot";
  Function? _onLongPress;
  Function? _onPressed;
  TextEditingController gateWay = TextEditingController(text: "192.168.1.1");

  void __onPressed() {
    setState(() {
      _text = "hold if you want reboot";
    });
  }

  void _reboot() async {
    setState(() {
      _text = "Rebooting";
      _onLongPress = null;
      _onPressed = null;
    });
    try {
      final HttpClientRequest req =
          await HttpClient().post(gateWay.text, 80, "/cgi-bin/makeRequest.cgi");
      req.headers.set(
          HttpHeaders.contentTypeHeader, "application/x-www-form-urlencoded");
      req.headers.set(HttpHeaders.contentLengthHeader, 6);
      req.write("Reboot");
      final HttpClientResponse response = await req.close();
      if (response.statusCode == 200) {
        setState(() {
          _text = "Exiting ...";
        });
        sleep(Duration(seconds: 4));
        SystemNavigator.pop(animated: true);
      }
      response.transform(utf8.decoder).listen((event) {
        setState(() {
          _text = event;
          _onLongPress = _reboot;
          _onPressed = __onPressed;
        });
      });
    } catch (e) {
      setState(() {
        _text = "ERROR!";
        _onLongPress = _reboot;
        _onPressed = __onPressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _onLongPress = _reboot;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: gateWay,
                decoration: InputDecoration(),
              ),
            ),
            ElevatedButton(
              child: Text(_text),
              onLongPress: _reboot,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              onPressed: __onPressed,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reboot,
        tooltip: 'Increment',
        child: Icon(Icons.power_settings_new_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
