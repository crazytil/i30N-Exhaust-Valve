// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:http/http.dart' as http;
import 'package:v1/settings.dart';

void main() {
  runApp(Application());
}

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

double initial = 0;
String initialvalueString = "";
bool mode = false;

class _ApplicationState extends State<Application> {
  int exhaust = 0;

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = AsyncLoader(
      initState: () async => await getMessage(),
      renderLoad: () => CircularProgressIndicator(),
      renderError: ([error]) =>
          const Text('Sorry, there was an error loading your joke'),
      renderSuccess: ({data}) => ExhaustOpen(),
    );

    return MaterialApp(
        title: 'TBURG Exhaust Control',
        home: Builder(
            builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Exhaust Control'),
                    backgroundColor: Colors.yellow,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                        },
                      )
                    ],
                  ),
                  body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _asyncLoader,
                        ]),
                  ),
                )));
  }
}

changeExhaust(int pwm) async {
  pwm = (pwm * 2.55).round();
  try {
    http.Response response =
        await http.get(Uri.parse("http://192.168.3.30/analog/16/$pwm"));
    final jsonData = jsonDecode(response.body);
    return jsonData;
  } catch (err) {
    return err;
  }
}

getMessage() async {
  const start = 'return_value": ';
  const end = ",";
  try {
    http.Response response =
        await http.get(Uri.parse("http://192.168.3.30/analog/16"));
    final responses = response.body;
    final startIndex = responses.indexOf(start);
    final endIndex = responses.indexOf(end, startIndex + start.length);
    initialvalueString =
        responses.substring(startIndex + start.length, endIndex);
    initial = double.parse(initialvalueString) / 2.55;
  } catch (err) {
    return err;
  }

  return (initial);
}

class ExhaustOpen extends StatefulWidget {
  const ExhaustOpen({Key? key}) : super(key: key);

  @override
  _ExhaustOpenState createState() => _ExhaustOpenState();
}

class _ExhaustOpenState extends State<ExhaustOpen> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(30),
            child: SizedBox(
              width: 200.0,
              height: 100.0,
              child: ElevatedButton(
                child: mode
                    ? Text("Passthrough Mode: ON")
                    : Text("Passthrough Mode: OFF"),
                onPressed: () {
                  setState(() {
                    mode = !mode;
                  });
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          SleekCircularSlider(
              initialValue: initial,
              appearance: CircularSliderAppearance(
                angleRange: 240,
                size: 300,
                customColors: CustomSliderColors(
                    shadowColor: Colors.grey,
                    trackColor: Colors.black,
                    progressBarColor: const Color(0xffe7e300)),
              ),
              onChangeEnd: (double value) {
                changeExhaust(value.toInt());
              }),
        ]);
  }
}
