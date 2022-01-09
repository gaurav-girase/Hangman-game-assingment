import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

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

  // This widget is the root of your application.
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
  List<String?> _selecteLetters = <String?>[];
  String? _currentword;
  List _currentwordList = [];
  List<String?> _splitWord = [];
  bool _gameover = false;
  int _numberLive = 5;
  Random _random = new Random();
  int _wrongCount = -1;
  String? hideWord;
  String getHiddenWord(int wordLength) {
    print(wordLength);
    String hiddenWord = '';
    for (int i = 0; i < wordLength; i++) {
      hiddenWord += '_';
    }
    return hiddenWord;
  }
  Future readWord() async {
    print("heelo");
    var result;
    var requestedUrl = "https://random-word-api.herokuapp.com/word?number=10";
    print(requestedUrl);
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
        print(_currentword!.length);
        _splitWord = _currentword!.toUpperCase().split("");
        hideWord = getHiddenWord(_currentword!.length);
      });
    } else {
      result = {
        'status': false,
        'message': json.decode(response.body)['message']
      };
    }
    return result;
  }

  @override
  void initState() {
    int count = 1;
    readWord();
    _wrongCount = -1;
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
        leading: IconButton(
          icon: const Icon(
            Icons.lock_clock,
          ),
          iconSize: 25,
          color: Colors.white,
          onPressed: () {},
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
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_splitWord.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child:
                        Text( hideWord!,
                    // Text(
                    //   ((_selecteLetters
                    //               .contains(_splitWord[index]!.toUpperCase()) ||
                    //           _wrongCount > _numberLive)
                    //       ? _splitWord[index]!.toUpperCase()
                    //       : ""),
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 30,
                          color: Colors.black),
                    ),
                  ),
                );
              })),
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
                              onPressed: (_selecteLetters
                                      .contains(letter.toUpperCase()))
                                  ? null
                                  : () {
                                      if (!_selecteLetters
                                              .contains(letter.toUpperCase()) &&
                                          !_gameover) {
                                        setState(() {
                                          if (_wrongCount <= _numberLive) {
                                            _selecteLetters
                                                .add(letter.toUpperCase());
                                          }
                                        });
                                      }
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
