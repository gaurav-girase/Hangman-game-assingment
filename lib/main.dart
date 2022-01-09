import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(const MyApp());
}

const List<String> alphabet = [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z"
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hangman',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _currentword;
  List _currentwordList = [];
  List<String?> _splitWord = [];
  int _numberLive = 5;
  Random _random = new Random();
  bool isDisable = false;
  String? hideWord;
  late bool finishedGame;

  //To replace the Word with "_"
  String getHiddenWord(int wordLength) {
    String hiddenWord = '';
    for (int i = 0; i < wordLength; i++) {
      hiddenWord += '_';
    }
    return hiddenWord;
  }

  //After Press the letter Guess the correct letter
  void wordPress(int index) {
    var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      animationDuration: const Duration(milliseconds: 500),
      backgroundColor: Colors.grey,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 30.0,
        letterSpacing: 1.5,
      ),
    );
    bool check = false;
    setState(() {
      // To replace the hideword ("_") to alphabate
      for (int i = 0; i < _splitWord.length; i++) {
        if (_splitWord[i] == alphabet[index]) {
          check = true;
          _splitWord[i] = '';
          hideWord = hideWord!.replaceFirst(RegExp('_'), _currentword![i], i);
        }
      }
      // After correct guess we need to show the alert
      if (hideWord == _currentword) {
        finishedGame = true;
        Alert(
          context: context,
          style: alertStyle,
          type: AlertType.success,
          title: _currentword,
          desc: "You Won!",
          buttons: [
            DialogButton(
              radius: BorderRadius.circular(10),
              child: const Icon(
                Icons.arrow_right_alt,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  readWord();
                });
              },
              width: 127,
              color: Colors.grey,
              height: 52,
            )
          ],
        ).show();
      }
      // decrease the lives on each wrong check.
      if (!check) {
        _numberLive -= 1;
      }
      // if number of live is zero then game is over.
      if (_numberLive == 0) {
        finishedGame = true;
        Alert(
            style: alertStyle,
            context: context,
            title: "Game Over!",
            buttons: [
              DialogButton(
                onPressed: () {
                  readWord();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.refresh, size: 30.0),
                color: Colors.blue,
              ),
            ]).show();
      }
    });
  }

  // To read the words list from API.
  Future readWord() async {
    var result;
    var requestedUrl = "https://random-word-api.herokuapp.com/word?number=10";
    Response response = await get(
      Uri.parse(requestedUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _currentwordList = responseData;
        _currentword =
            _currentwordList[_random.nextInt(_currentwordList.length)];
        print(_currentword!);
        _splitWord = _currentword!.toUpperCase().split("");
        hideWord = getHiddenWord(_currentword!.length);
        _numberLive = 5;
      });
    } else {
      result = {'status': false, 'message': "Something went Wrong!"};
    }
    return result;
  }

  //inital state on page load
  @override
  void initState() {
    readWord();
    _numberLive = 5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Hangman Game",
        ),
        centerTitle: true,
        leading: TextButton.icon(
          icon: const Icon(
            Icons.lock_clock,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {},
          label: Text(_numberLive.toString()),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.lightbulb_outlined,
            ),
            iconSize: 25,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/hangman.png",
              ),
              const SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 10, 0),
                    child: Text(
                      hideWord!,
                      style: const TextStyle(
                          fontSize: 35, color: Colors.black, letterSpacing: 8),
                    ),
                  ),
                )
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: alphabet
                        .map((letter) => ButtonTheme(
                            height: 50,
                            minWidth: 45,
                            child: TextButton(
                              onPressed: () {
                                wordPress(alphabet.indexOf(letter));
                                isDisable = true;
                              },
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontSize: 40,
                                ),
                              ),
                            )))
                        .toList()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
