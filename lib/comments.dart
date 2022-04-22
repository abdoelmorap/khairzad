import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComentsPage extends StatefulWidget {
  final String? docsid;
  ComentsPage({Key? key, @required this.docsid}) : super(key: key);
  @override
  _TestMeState createState() => _TestMeState();
}

class _TestMeState extends State<ComentsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();

  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
  }

  Widget commentChild(data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () async {
            // Display the image in large form.
            print("Comment Clicked");
          },
          child: Container(
            height: 50.0,
            width: 50.0,
            decoration: new BoxDecoration(
                color: Colors.blue,
                borderRadius: new BorderRadius.all(Radius.circular(50))),
            child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  "assets/app_images/${data['avatar']}",
                )),
          ),
        ),
        title: Row(
          children: [
            Text(
              data['name_sender'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<GestureDetector>(
              items: <GestureDetector>[
                false
                    ? GestureDetector(
                        child: Text('فك الحظر'),
                        onTap: () {
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
        subtitle: Text(
          data['content'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comment Page"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        child: CommentBox(
          userImage:
              "https://iconape.com/wp-content/png_logo_vector/avatar-10.png",
          // userImage:"avatar/${ prefs.getString('avatar') ?? 'free1.jpg'}",
          child: PaginateFirestore(
            // orderBy is compulsory to enable pagination
            query: FirebaseFirestore.instance
                .collection('Posts')
                .doc(widget.docsid)
                .collection("Comments")
                .orderBy('timestamp', descending: true),
            //Change types accordingly
            itemBuilderType: PaginateBuilderType.listView,
            // to fetch real-time data
            isLive: true,

            //item builder type is compulsory.
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot[index].data() as Map;
              //  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return commentChild(data);
            },
          ),
          labelText: 'Write a comment...',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () async {
            if (formKey.currentState!.validate()) {
              print(commentController.text);
              var content = commentController.text;
              var id = prefs!.getString("nickname");
              // type: 0 = text, 1 = image, 2 = sticker
              if (content.trim() != '') {
                commentController.clear();

                var documentReference = FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.docsid)
                    .collection("Comments")
                    .doc(
                        DateTime.now().millisecondsSinceEpoch.toString() + id!);
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  transaction.set(
                    documentReference,
                    {
                      'idFrom': id,
                      'timestamp':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      'content': content,
                      'avatar': prefs!.getString('avatar') ?? 'free1.jpg',
                      'defualt_avatar_type': "1",
                      'name_sender': prefs!.getString('nickname') ?? '',
                    },
                  );
                });
              } else {
                Fluttertoast.showToast(
                    msg: 'Nothing to send',
                    backgroundColor: Colors.black,
                    textColor: Colors.red);
              }

              setState(() {});
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}
