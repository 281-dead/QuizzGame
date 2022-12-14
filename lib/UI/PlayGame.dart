import 'dart:async';

import 'package:ailatrieuphu/models/Question_models.dart';
import 'package:ailatrieuphu/widget/Colors.dart';
import 'package:ailatrieuphu/widget/nextButton.dart';
import 'package:ailatrieuphu/widget/question_widget.dart';
import 'package:ailatrieuphu/widget/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Widget/option_Card.dart';

class PlayGame extends StatefulWidget {
  PlayGame({super.key, required this.user, required this.credit, required this.lsQuestion});
  User user;
  final double credit;
  final lsQuestion;

  @override
  State<PlayGame> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {
  //Khai báo authentication của flutterAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Khai báo đối tượng user
  late User _user;
  //Credit
  late double _credit = 0;
  // var db = DbConnect();
  late Future extractedData;
  //index cho loop
  int index = 0;
  //diem
  int score = 0;
  //check boolean when user clicked
  bool isPress = false;
  bool isAlreadyselect = false;
  //khai báo số lượt chơi của người chơi
  int demHeart = 5;
  //check tro giup
  bool check = false, check1 = false, check2 = false;

  //funtcion chuyen cau hoi
  void nextQuestion(int questionLenght) {
    if (index == questionLenght - 1) {
      //diaglog khi het cau hoi
      showDialog(
          barrierDismissible: false, //dialog se tat  khi user click ngoai pham vi diaglog
          context: context,
          builder: (context) => Result(
                result: score,
                questionLenght: questionLenght,
                user: _user,
                credit: _credit,
              ));
    } else {
      if (isPress) {
        setState(() {
          index++;
          isPress = false;
          isAlreadyselect = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Chọn đáp án của bạn',
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 10),
        ));
      }
    }
  }

  int timer = 30;
  String showtimer = "30";
  int i = 1;

  void starttimer() async {
    const onesec = Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {
      if (mounted) {
        setState(() {
          if (timer < 1) {
            t.cancel();
          } else {
            timer = timer - 1;
          }
          showtimer = timer.toString();
        });
      }
    });
  }

  //function change color
  void CheckAndUpdateAnswer(bool value) {
    if (isAlreadyselect) {
      return;
    } else {
      if (value == true) {
        score += 10;
      }
      setState(() {
        isPress = true;
        isAlreadyselect = true;
      });
    }
  }

  //function start over (chơi lại)
  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPress = false;
      isAlreadyselect = false;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    _user = widget.user;
    _credit = widget.credit;
    extractedData = widget.lsQuestion;
    starttimer();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    starttimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: extractedData as Future<List<Question>>,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            var extractedData = snapshot.data as List<Question>;
            return Scaffold(
              backgroundColor: kprimaryColor,
              appBar: AppBar(
                title: const Text('Ai Là Triệu Phú'),
                backgroundColor: kprimaryColor,
                shadowColor: Colors.transparent,
                actions: [
                  //Điểm
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'Score : $score',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: white,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.user.displayName!,
                            style: GoogleFonts.abel(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Container(
                                child: Text(
                                  _credit.round().toString(),
                                  style: GoogleFonts.abel(
                                    color: white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.diamond_outlined,
                                size: 20,
                                color: Colors.yellow.withOpacity(0.8),
                              ),
                            ],
                          ),
                          //const SizedBox(width: 20),

                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //generate list icons (mỗi icon tương ứng với một lượt chơi)
                                ...List.generate(
                                  demHeart,
                                  (index) => Icon(
                                    Icons.heart_broken,
                                    color: Colors.red.withOpacity(0.8),
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    QuestionWidget(
                      question: extractedData[index].title,
                      indexAction: index,
                      totalQuestions: extractedData.length,
                    ),
                    const Divider(
                      color: white,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    for (int i = 0; i < extractedData[index].options.length; i++)
                      GestureDetector(
                        onTap: () => CheckAndUpdateAnswer(extractedData[index].options.values.toList()[i]),
                        child: OptionCard(
                          option: extractedData[index].options.keys.toList()[i],
                          color: isPress
                              ? extractedData[index].options.values.toList()[i] == true
                                  ? correct
                                  : incorrect
                              : white,
                        ),
                      ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              showtimer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: check
                              ? null
                              : () {
                                  showDialog5050(context);
                                },
                          child: Image.asset(
                            'assets/images/50-50.png',
                            fit: BoxFit.cover,
                            height: 55,
                            width: 70,
                          ),
                        ),
                        const SizedBox(width: 25.0),
                        GestureDetector(
                          onTap: check1
                              ? null
                              : () {
                                  showDialogCall(context);
                                },
                          child: Image.asset(
                            'assets/images/phone.png',
                            fit: BoxFit.cover,
                            height: 55,
                            width: 70,
                          ),
                        ),
                        const SizedBox(width: 25.0),
                        GestureDetector(
                          onTap: check2
                              ? null
                              : () {
                                  showDialogHelp(context);
                                },
                          child: Image.asset(
                            'assets/images/help.png',
                            fit: BoxFit.cover,
                            height: 55,
                            width: 70,
                          ),
                        ),
                      ],
                    ),
                    //const SizedBox(height: 10.3),
                  ],
                ),
              ),
              floatingActionButton: GestureDetector(
                onTap: () {
                  setState(() {
                    timer = 30;
                  });
                  nextQuestion(extractedData.length);
                },
                child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 15), child: const NextButton()),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          }
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Đợi chút nha, dữ liệu đang tải...',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: kprimaryColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text('No data'),
        );
      },
    );
  }

  //dialog 50/50
  void showDialog5050(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: background,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: boldBlue,
                ),
                height: 50,
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Trợ giúp',
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bạn chọn trợ giúp ',
                      style: TextStyle(color: white),
                    ),
                    TextSpan(
                      text: '50/50',
                      style: TextStyle(color: white),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy bỏ'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        check = true;
                      });
                      showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 0),
                                      decoration: const BoxDecoration(
                                        color: boldBlue,
                                      ),
                                      height: 50,
                                      width: double.infinity,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          '50/50',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    const Text('A và D là 2 phương án sai ')
                                  ],
                                ),
                              )));
                    },
                    child: const Text(
                      'Chọn',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  //Dialog gọi điện thoại
  void showDialogCall(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: background,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: boldBlue,
                ),
                height: 50,
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Trợ giúp',
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bạn chọn trợ giúp ',
                      style: TextStyle(color: white),
                    ),
                    TextSpan(
                      text: 'GỌI ĐIỆN THOẠI',
                      style: TextStyle(color: white),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy bỏ'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        check1 = true;
                      });
                      showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 0),
                                      decoration: const BoxDecoration(
                                        color: boldBlue,
                                      ),
                                      height: 50,
                                      width: double.infinity,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Gọi điện thoại',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    const Text('Tôi đang phân phân giữa hai đáp án  A và B ')
                                  ],
                                ),
                              )));
                    },
                    child: const Text(
                      'Chọn',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  //Dialog hỏi ý kiến khán giả
  void showDialogHelp(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: background,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 0),
                decoration: const BoxDecoration(
                  color: boldBlue,
                ),
                height: 50,
                width: double.infinity,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Trợ giúp',
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bạn chọn trợ giúp ',
                      style: TextStyle(color: white),
                    ),
                    TextSpan(
                      text: 'HỎI Ý KIẾN KHÁN GIẢ',
                      style: TextStyle(color: white),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy bỏ'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        check2 = true;
                      });
                      showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 0),
                                      decoration: const BoxDecoration(
                                        color: boldBlue,
                                      ),
                                      height: 50,
                                      width: double.infinity,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'HỎI Ý KIẾN KHÁN GIẢ',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    const Text('Tôi đang phân phân giữa hai đáp án  A và B ')
                                  ],
                                ),
                              )));
                    },
                    child: const Text(
                      'Chọn',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
