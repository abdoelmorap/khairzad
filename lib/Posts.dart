import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:ana_almuslim/comments.dart';
import 'package:ana_almuslim/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kr_paginate_firestore/paginate_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatelessWidget {
  final String? peerId;
  final String? peerAvatar;

  Posts({Key? key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "اخيك يسال؟",
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
      body: ChatScreen(
        peerId: peerId!,
        peerAvatar: peerAvatar!,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String? peerId;
  final String? peerAvatar;

  ChatScreen({Key? key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key? key, @required this.peerId, @required this.peerAvatar});

  String? peerId;
  String? peerAvatar;
  String? id;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);

  String? groupChatId;
  SharedPreferences? prefs;

  File? imageFile;
  bool? isLoading;
  bool? isShowSticker;
  String? imageUrl;
  List<String>? myStringList;
  List<String> blocked = [];
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  List<DocumentSnapshot> products = []; // stores fetched products
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 5; // documents to be fetched per request
  DocumentSnapshot?
      lastDocument; // flag for last document from where next 10 records to be fetched

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    // listScrollController.addListener(_scrollListener);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = '';
    // if (id.hashCode <= peerId.hashCode) {
    //   groupChatId = '$id-$peerId';
    // } else {
    //   groupChatId = '$peerId-$id';
    // }
    // read
    myStringList = prefs?.getStringList('MyLikes') ?? [];
    // write
    // prefs.setStringList('my_string_list_key', ['a', 'b', 'c']);
    groupChatId = "Posts";
    setState(() {});

    if (prefs!.getStringList("blocked") != null) {
      blocked = prefs!.getStringList("blocked") ?? [];
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'id': prefs?.getString('id') ?? '',
            'name_sender': prefs?.getString('nickname') ?? '',
            'image_sender': prefs?.getString('photoUrl') ?? ''
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker!) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  var _saving = false;
  TextEditingController _newMediaLinkAddressController =
      TextEditingController();
  showMenu_app() {
    showModalBottomSheet(
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'شارك ما يخطر ببالك',
                      style: GoogleFonts.cairo(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(hintText: 'بماذا تفكر'),
                      autofocus: true,
                      style: GoogleFonts.cairo(fontSize: 18),
                      controller: _newMediaLinkAddressController,
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                      onTap: () {
                        var content = _newMediaLinkAddressController.text;
                        if (content.trim() != '') {
                          textEditingController.clear();

                          var documentReference = FirebaseFirestore.instance
                              .collection('Posts')
                              .doc(DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString() +
                                  id!);
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            transaction.set(
                              documentReference,
                              {
                                'idFrom': id,
                                'idTo': peerId,
                                'timestamp': DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                'content': content,
                                'likes': 0,
                                'id': prefs?.getString('id') ?? '',
                                'avatar':
                                    prefs?.getString('avatar') ?? 'free1.jpg',
                                'defualt_avatar_type': "1",
                                'name_sender':
                                    prefs?.getString('nickname') ?? '',
                                'image_sender':
                                    prefs?.getString('photoUrl') ?? ''
                              },
                            );
                          });
                          listScrollController.animateTo(0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Nothing to send',
                              backgroundColor: Colors.black,
                              textColor: Colors.red);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 5, top: 15, right: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: 120.0,
                        height: 30,
                        child: Center(
                          child: Text(
                            "شارك",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ))
                  // CheckboxListTile(
                  //   title: Text("Hide My identity"),
                  //   value: _saving,
                  //   onChanged: (bool value) {
                  //     setState(() {
                  //       _saving = value;
                  //     });
                  //     // _showDialog();
                  //   },
                  //   controlAffinity: ListTileControlAffinity
                  //       .leading, //  <-- leading Checkbox
                  // ),
                ],
              ),
            ));
  }

  void onshare(text) async {
    await FlutterShare.share(
      title: 'مشاركة من التطبيق',
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Image.asset(
              "assets/quran/page_bg.png",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
                child: // List of messages
                    // buildListMessage(),
                KrPaginateFirestore(
                  //item builder type is compulsory.
                  itemBuilder: (context, documentSnapshot, index) {
                    final data = documentSnapshot[index].data() as Map;
                    //  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return Center(
                        // constraints:
                        //     BoxConstraints.tightFor(height: max(220, 500)),
                        child: Row(
                      children: <Widget>[
                        Container(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Color(0xb5c6c6c6),
                            // gradient: LinearGradient(
                            //     begin: Alignment.topCenter,
                            //     end: Alignment.bottomCenter,
                            //     colors: [Colors.brown, Colors.brown])
                          ),
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(10),
                          child: Column(children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Material(
                                  child:
                                      // CircleAvatar(child: Icon(Icons.person)),

                                      Image.asset(
                                    "assets/app_images/${data['avatar']}",
                                    width: 40,
                                    height: 40,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(60.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(data['name_sender']),
                                DropdownButton<GestureDetector>(
                                  items: <GestureDetector>[
                                    blocked.contains(data['id'])
                                        ? GestureDetector(
                                            child: Text('فك الحظر'),
                                            onTap: () {
                                              blocked.remove(data['id']);
                                              dev.log(data['id']);
                                              prefs!.setStringList(
                                                  "blocked", blocked);
                                              for (var blok in blocked) {
                                                dev.log(blok);
                                              }
                                              Fluttertoast.showToast(
                                                  msg: 'user unBlocked',
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.red);
                                              setState(() {});
                                            },
                                          )
                                        : GestureDetector(
                                            child: const Text('حظر'),
                                            onTap: () {
                                              blocked.add(data['id']);
                                              dev.log(data['id']);
                                              prefs!.setStringList(
                                                  "blocked", blocked);
                                              for (var blok in blocked) {
                                                dev.log(blok);
                                              }
                                              Fluttertoast.showToast(
                                                  msg: 'user Blocked',
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.red);
                                              setState(() {});
                                            },
                                          ),
                                    GestureDetector(
                                      child: const Text('ابلاغ'),
                                      onTap: () {
                                        CollectionReference users =
                                            FirebaseFirestore.instance
                                                .collection('users-reports');
                                        users
                                            .doc(
                                                'report${DateTime.now().millisecondsSinceEpoch.toString()}')
                                            .set({
                                              'name': data['name_sender'],
                                              'id': data['id'],
                                              'content': data['content'],
                                            })
                                            .then(
                                                (value) => print("User Added"))
                                            .catchError((error) => print(
                                                "Failed to add user: $error"));

                                        Fluttertoast.showToast(
                                            msg: 'report sent',
                                            backgroundColor: Colors.black,
                                            textColor: Colors.red);
                                      },
                                    ),
                                  ].map((GestureDetector value) {
                                    return DropdownMenuItem<GestureDetector>(
                                      value: value,
                                      child: (value),
                                    );
                                  }).toList(),
                                  onChanged: (_) {},
                                )
                              ],
                            ),
                            Container(
                              // height: 220,
                              padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                              // constraints: BoxConstraints.tightFor(
                              //     height: min(220, 500)),

                              child: Center(
                                child: Center(
                                  child: blocked.contains(data['id'])
                                      ? ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                              sigmaX: 5, sigmaY: 5),
                                          child: Text(
                                            data['content'],
                                            style: GoogleFonts.cairo(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown,
                                            ),
                                            textAlign: TextAlign.center,
                                          ))
                                      : Text(
                                          data['content'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                              ),
                            ),
                            Row(children: [
                              SizedBox(
                                width: 18,
                              ),
                              GestureDetector(
                                child: myStringList!
                                        .contains(documentSnapshot[index].id)
                                    ? Icon(
                                        Icons.favorite_sharp,
                                        color: Colors.pink,
                                      )
                                    : Icon(Icons.favorite_border),
                                onTap: () async {
                                  if (myStringList!
                                      .contains(documentSnapshot[index].id)) {
                                    await FirebaseFirestore.instance
                                        .collection("Posts")
                                        .doc(documentSnapshot[index].id)
                                        .update({
                                      "likes": FieldValue.increment(-1)
                                    });

                                    myStringList!
                                        .remove(documentSnapshot[index].id);
                                    prefs!.remove("MyLikes");
                                    prefs!.setStringList(
                                        "MyLikes", myStringList!);
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection("Posts")
                                        .doc(documentSnapshot[index].id)
                                        .update(
                                            {"likes": FieldValue.increment(1)});

                                    myStringList!
                                        .add(documentSnapshot[index].id);

                                    prefs!.remove("MyLikes");
                                    prefs!.setStringList(
                                        "MyLikes", myStringList!);
                                  }

                                  setState(() {});
                                },
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${data['likes']}",
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              GestureDetector(
                                child: Icon(Icons.comment),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ComentsPage(
                                              docsid:
                                                  documentSnapshot[index].id)));
                                },
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              GestureDetector(
                                child: Icon(Icons.share),
                                onTap: () =>
                                    onshare(data['content'].toString()),
                              )
                            ])
                          ]),
                          // height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width - 20,
                          // height: 300,
                          // ),
                          // elevation: 3,
                          // semanticContainer: true,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(20.0),
                          // ),
                          // margin: EdgeInsets.all(8),
                        ),
                      ],
                    ));
                  },
                  // orderBy is compulsory to enable pagination
                  query: FirebaseFirestore.instance
                      .collection('Posts')
                      .orderBy('timestamp', descending: true),
                  //Change types accordingly
                  itemBuilderType: PaginateBuilderType.listView,
                  // to fetch real-time data
                  isLive: true,
                ),
                height: MediaQuery.of(context).size.height),
          ],
        ),
        onWillPop: onBackPress,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMenu_app();
          // onSendMessage("content", 0);
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class RectBlurPainter extends CustomPainter {
  double rectWidth;
  double blurSigma;
  double hight;
  RectBlurPainter(
      {required this.rectWidth, required this.blurSigma, required this.hight});

  @override
  void paint(Canvas canvas, Size size) {
    // This is the flutter_screenutil library
    // ScreenUtil.init(width: 750.0, height: 1334.0, allowFontScaling: true);

    Paint paint = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..strokeWidth = rectWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    Offset center = new Offset(0, 0);

    canvas.drawRect(center & Size(rectWidth, hight), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
