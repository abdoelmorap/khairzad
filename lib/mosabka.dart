import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MosabpkaView extends StatefulWidget {
  const MosabpkaView({Key? key, required this.title, required this.index})
      : super(key: key);

  final String title;
  final int index;

  @override
  State<MosabpkaView> createState() => _MosabpkaViewState();
}

class _MosabpkaViewState extends State<MosabpkaView> {
  late ConfettiController _controllerCenter;

  var score = 0;
  var index = 0;
  List<asks> asksarrys = [];
  var load = 0;
  bool finshed = false;
  @override
  void dispose() {
    super.dispose();
    _controllerCenter.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    var users = FirebaseFirestore.instance.collection('chalange').get();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.reemKufi(fontSize: 18),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
            child: Stack(children: <Widget>[
          //CENTER -- Blast
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              numberOfParticles: 25, // number of particles to emit

              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
                  true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
              createParticlePath: drawStar, // define a custom shape/path.
            ),
          ),
          Container(
            child: FutureBuilder<QuerySnapshot>(
              future: users,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong${snapshot.error}");
                }

                if (snapshot.hasData && snapshot.data!.docs!.length == 0) {
                  return Text("Document does not exist");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  var randomItem = (snapshot.data!.docs.toList()..shuffle());
                  if (load == 0) {
                    randomItem.forEach((doc) {
                      asksarrys.add(asks(
                          doc['ask'],
                          doc['answertrue'],
                          doc['answerfalse3'],
                          doc['answerfalse2'],
                          doc['answerfalse1']));
                    });
                    load++;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                          height: 60,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                              color: Color(0x344955),
                            ),
                            child: Stack(
                              alignment: Alignment(0, 0),
                              // overflow: Overflow.visible,
                              children: [
                                Positioned(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    child: Text(
                                      "  عدد الاسئلة : ${asksarrys.length.toString()}",
                                      style: GoogleFonts.cairo(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Colors.pink,
                                            Colors.purple,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  right: 0,
                                ),
                                Positioned(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    child: Text(
                                      " النقاط : ${score}",
                                      style: GoogleFonts.cairo(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Colors.pink,
                                            Colors.purple,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  left: 0,
                                )
                              ],
                            ),
                          )),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(5),
                        height: 150,
                        padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1)),
                        child: Center(
                          child: Text(
                            "${asksarrys[index].ask}",
                            style: GoogleFonts.cairo(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          height: 150,
                          margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                          child: GridView.count(
                            childAspectRatio: 3 / 1,
                            crossAxisCount: 2,
                            children: [
                              answerContainer(asksarrys[index].answe1, () {
                                if (asksarrys.length > index + 1) {
                                  index++;
                                } else {
                                  Navigator.of(context).pop();
                                  finshed = true;
                                }
                                print("worng");
                                _showMyDialog(
                                    "للاسف",
                                    Image.asset(
                                      "assets/app_images/wrong.png",
                                      width: 50,
                                    ),
                                    "اخترت اجابة خطاء  \n الاجابة الصحيحة هي ${asksarrys[index].trueanswer}",
                                    "التالي", () {
                                  score += 0;

                                  setState(() {});
                                }, finshed);
                              }),
                              answerContainer(asksarrys[index].answe2, () {
                                if (asksarrys.length > index + 1) {
                                  index++;
                                } else {
                                  Navigator.of(context).pop();
                                  finshed = true;
                                }
                                print("worng");
                                _showMyDialog(
                                    "للاسف",
                                    Image.asset(
                                      "assets/app_images/wrong.png",
                                      width: 50,
                                    ),
                                    "اخترت اجابة خطاء  \n الاجابة الصحيحة هي ${asksarrys[index].trueanswer}",
                                    "التالي", () {
                                  score += 0;

                                  setState(() {});
                                }, finshed);
                              }),
                              answerContainer(asksarrys[index].trueanswer, () {
                                if (asksarrys.length > index + 1) {
                                  index++;
                                } else {
                                  Navigator.of(context).pop();
                                  finshed = true;
                                }
                                print("true");

                                _controllerCenter.play();
                                setState(() {});
                                _showMyDialog(
                                    "مبروك",
                                    Image.asset(
                                      "assets/app_images/check-green.gif",
                                      width: 50,
                                    ),
                                    "نعم الاجابة صحيحة بالفعل \n نقاطتك زادت بمقدار 15 نقطة",
                                    "التالي", () {
                                  score += 15;

                                  setState(() {});
                                }, finshed);
                              }),
                              answerContainer(asksarrys[index].answe3, () {
                                if (asksarrys.length > index + 1) {
                                  index++;
                                } else {
                                  Navigator.of(context).pop();
                                  finshed = true;
                                }
                                print("worng");
                                _showMyDialog(
                                    "للاسف",
                                    Image.asset(
                                      "assets/app_images/wrong.png",
                                      width: 50,
                                    ),
                                    "اخترت اجابة خطاء  \n الاجابة الصحيحة هي ${asksarrys[index].trueanswer}",
                                    "التالي", () {
                                  score += 0;

                                  setState(() {});
                                }, finshed);
                              })
                            ]..shuffle(),
                          ))
                    ],
                  );
                }

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            color: Color(0xFFE3E3E3),
            height: double.infinity,
          )
        ])));
  }

  Future<void> _showMyDialog(
      title, icon, content, btn, myevent, bool finshed) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xfffffcfc),
          title: Text(
            '$title',
            style:
                GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(250.0), child: icon),
                Text(
                  '$content',
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '$btn',
                style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.normal),
                textAlign: TextAlign.left,
              ),
              onPressed: () {
                if (!finshed) {
                  myevent();
                  _controllerCenter.stop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget answerContainer(String answer, void Function()? myonPressed) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: myonPressed,
        // shape:
        //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        // padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink,
                  Colors.purple,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              "$answer",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class asks {
  final String ask;

  final String trueanswer;

  final String answe1;

  final String answe2;

  final String answe3;
  asks(this.ask, this.trueanswer, this.answe1, this.answe2, this.answe3);
}
