import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as iframe;

class DrosEEleam extends StatefulWidget {
  @override
  _DrosEEleamPagetate createState() => new _DrosEEleamPagetate();
}

class _DrosEEleamPagetate extends State<DrosEEleam> {
  @override
  Widget build(BuildContext context) {
    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        [Factory(() => EagerGestureRecognizer())].toSet();
    UniqueKey _key = UniqueKey();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "خير زاد ",
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
      body: Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SingleChildScrollView(
              child: Column(
            children: [
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "jnJdXj3P26M",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Container(
                height: MediaQuery.of(context).size.height * 40 / 100,
                child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 3 / 2,
                    crossAxisCount: 2,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          var pagerIndex = prefs.getInt('pageNumber') ?? 0;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemsScreen("قصص الانبياء", "alanbiyaa", 29),
                            ),
                          );
                        },
                        child: Card(
                            elevation: 15,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Image.asset(
                                "assets/app_images/kssAlabia.jpg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          var pagerIndex = prefs.getInt('pageNumber') ?? 0;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemsScreen("قصص القران", "islamic", 24),
                            ),
                          );
                        },
                        child: Card(
                            elevation: 15,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Image.asset(
                                "assets/app_images/kssQuran.jpg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          var pagerIndex = prefs.getInt('pageNumber') ?? 0;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemsScreen("قصص الصحابة", "sahaba", 38),
                            ),
                          );
                        },
                        child: Card(
                            elevation: 15,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Image.asset(
                                "assets/app_images/sahba.jpg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          var pagerIndex = prefs.getInt('pageNumber') ?? 0;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ItemsScreen("المعجزات ", "moajezat", 14),
                            ),
                          );
                        },
                        child: Card(
                            elevation: 15,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Image.asset(
                                "assets/app_images/maxresdefault.jpg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )),
                      ),
                    ]),
              ),
              Card(
                // <-- wrap this around
                child: YoutubePlayer(
                    key: _key,
                    controller: YoutubePlayerController(
                      initialVideoId: "uV7w8PxQOJg",
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                      ),
                    )),
              ),
              Stack(
                children: [
                  Card(
                    child: YoutubePlayer(
                      aspectRatio: 16 / 9,
                      controller: YoutubePlayerController(
                        initialVideoId: "tL6xUAdB7gM",
                        flags: const YoutubePlayerFlags(
                          autoPlay: false,
                          mute: false,
                        ),
                      ),
                      // showVideoProgressIndicator: true,
                      // onReady: () {},
                    ),
                  ),
                ],
              ),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "50W7r--Xe4Q",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "QPWggh29tOU",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "Hymv5YuvbJ0",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "0rdfI-4sV9g",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "iOqoDu5IQyY",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "rd48iRLRbj0",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "VF3OyRvnMoo",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              )),
              Card(
                  child: YoutubePlayer(
                aspectRatio: 16 / 9,
                controller: YoutubePlayerController(
                  initialVideoId: "VsiPSgy-Ktk",
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
              ))
            ],
          ))),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  String? title;
  String? url;
  String? Ytb_id;

  DetailsScreen(this.title, this.url, this.Ytb_id, {Key? key})
      : super(key: key);
  @override
  DetailsScreenState createState() {
    return DetailsScreenState();
  }
}

class DetailsScreenState extends State<DetailsScreen> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "خير زاد ",
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
      // body: WebView(
      //   initialUrl: 'about:blank',
      //   javascriptMode: JavascriptMode.unrestricted,
      //   onWebViewCreated: (WebViewController webViewController) {
      //     _controller = webViewController;
      //
      //     _loadHtmlFromAssets();
      //   },
      // ),
    );
  }

  _loadHtmlFromAssets() async {
    log("Getting Data${' ${widget.url!}.html'}");

    var fileText =
        await DefaultAssetBundle.of(context).loadString('${widget.url!}.html');

    // await rootBundle.loadString('${widget.url!}.html', cache: false);
    log("Data is already got");
    log(fileText.toString());

    var fontCss =
        'blockquote{    font-size: 50px;} h1{    font-size: 80px;} body{ font-size: 50px;}';
    var finalstyle = '<style>$fontCss</style>$fileText';
    // _controller!.loadUrl(Uri.dataFromString(finalstyle,
    //         mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
    //     .toString());
  }
}

class ItemsScreen extends StatefulWidget {
  String? title;
  String? id;
  int? count;

  ItemsScreen(this.title, this.id, this.count, {Key? key}) : super(key: key);
  @override
  itemsScreenState createState() {
    return itemsScreenState();
  }
}

class itemsScreenState extends State<ItemsScreen> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget!.title!)),
        body: GridView.builder(
          itemCount: widget.count!,
          itemBuilder: (ctx, indx) {
            return GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(
                        "خير زاد", "assets/${widget.id!}/${indx + 1}", ""),
                  ),
                );
              },
              child: Card(
                elevation: 15,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.asset(
                    "assets/${widget.id!}/${indx + 1}.jpg",
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3 / 2,
            crossAxisCount: 2,
          ),
        ));
  }
}
