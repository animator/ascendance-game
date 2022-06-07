import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:google_fonts/google_fonts.dart';

const String API_URL = "https://app.ankmahato.workers.dev/";
final TextStyle textStyle = GoogleFonts.inconsolata(
  letterSpacing: .5,
);
final TextStyle pressStartStyle = GoogleFonts.pressStart2p();

void main() {
  configureApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascendance',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 0, 255),
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/intro.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "PRESS BELOW TO START",
                style: pressStartStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 400),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _scale = 0.9;
                    });
                  },
                  child: Image.asset("images/ascend.gif"),
                ),
                onEnd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LevelPage(qId: 0)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchData(int qId) async {
  final response = await http.get(Uri.parse(API_URL + "?q=$qId"));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    return {};
  }
}

class LevelPage extends StatefulWidget {
  LevelPage({Key? key, required this.qId}) : super(key: key);

  final int qId;
  @override
  State createState() => LevelPageState();
}

class LevelPageState extends State<LevelPage> with TickerProviderStateMixin {
  bool _inputError = false;
  bool _fabvisible = false;
  bool _hasInput = false;
  late FocusNode myFocusNode;

  late Future<Map<String, dynamic>> _data;
  TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = fetchData(widget.qId);
    myFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.centerLeft,
                image: AssetImage("images/${widget.qId}.jpg"),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          FutureBuilder(
            future: _data,
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data == {}) return const SizedBox();
                var ques = snapshot.data!["q"];
                var ans = snapshot.data!["a"];
                if (ans != null) {
                  _hasInput = true;
                  _fabvisible = true;
                }
                if (widget.qId == 0) _fabvisible = true;
                return Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.black87,
                    width: 400,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      children: <Widget>[
                        Text(
                          ques,
                          style: textStyle.copyWith(
                              color: theme.primaryColor, fontSize: 24.0),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        _inputError
                            ? Text(
                                "ERROR !!",
                                style: textStyle.copyWith(
                                    color: Colors.red, fontSize: 24.0),
                              )
                            : const SizedBox(),
                        _hasInput
                            ? Row(children: [
                                Text(
                                  ">> ",
                                  style: textStyle.copyWith(
                                      color: theme.primaryColor,
                                      fontSize: 30.0),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 60),
                                    child: TextField(
                                      autofocus: true,
                                      focusNode: myFocusNode,
                                      keyboardType: TextInputType.number,
                                      style: textStyle.copyWith(
                                          color: theme.primaryColor,
                                          fontSize: 30.0),
                                      cursorColor: theme.primaryColor,
                                      cursorWidth: 12.0,
                                      controller: _inputController,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: theme.primaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: theme.primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ])
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: _fabvisible,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 222, 233, 226)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  theme.primaryColor),
                            ),
                            child: Text(widget.qId == 0 ? "PROCEED" : "SUBMIT",
                                style: pressStartStyle.copyWith(fontSize: 20)),
                            onPressed: () async {
                              var correct = true;
                              if (_hasInput) {
                                if (_inputController.text.toLowerCase() !=
                                    ans) {
                                  correct = false;
                                  setState(() {
                                    _inputError = true;
                                    _inputController.text = "";
                                  });
                                  myFocusNode.requestFocus();
                                }
                              }

                              if (correct) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LevelPage(qId: widget.qId + 1)),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
