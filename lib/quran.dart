import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'package:flutter_tts/flutter_tts.dart';

import 'package:ana_almuslim/QuranAudioGenrator.dart';
import 'package:ana_almuslim/json/jsonSaver.dart';
import 'package:ana_almuslim/model/fahresModel.dart';
import 'package:ana_almuslim/model/modelQuranTranslate.dart';
import 'package:ana_almuslim/model/quranModelData.dart';
import 'package:ana_almuslim/pagemoreQuran.dart';
import 'package:ana_almuslim/repo/repo.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as pathservices;
import 'package:show_more_text_popup/show_more_text_popup.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart';

class InvertColors extends StatelessWidget {
  final Widget child;

  const InvertColors({required this.child});

  @override
  Widget build(BuildContext context) {
    return this.child;
  }
}

class SurahView extends StatefulWidget {
  const SurahView({Key? key, required this.title, required this.index,this.markAya=0})
      : super(key: key);

  final String title;
  final int index;
  final int markAya;

  @override
  State<SurahView> createState() => _SurahViewState();
}

class _SurahViewState extends State<SurahView> {
  TextEditingController word = TextEditingController();
  var pagerIndex = 0;
  int SelectedAya=0;
  int SelectedayaNum=0;
  String Selectedaya='';
  List<Map> list=[];

  bool singlePlay=false;
  List<int> codelist=[];
  String juz = "";

  Color  CurrentColor =Colors.transparent;
  List<AudioSource> ayats = [];
  late Database db;
late Offset postion =Offset(0, 0);
  @override
  void dispose() async {
    player.dispose();
    await db.close();

    super.dispose();
  }

  void getdatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = pathservices.join(databasesPath, "demo_asset_example.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(pathservices.dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data =
          await rootBundle.load(pathservices.join("assets", "quran.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    db = await openDatabase(path, readOnly: true);
    List<Map> list =
        await db.rawQuery('SELECT * FROM quran where sura_num = 1');
    log(list.toString());
    juz = (list[0]['juz'].toString());
    setState(() {});
  }

  @override
  void initState() {
    pagerIndex = widget.index;
    getdatabase();
    for (var surahinfo
        in surahFahresModel.fromJson(json.decode(jsons().Fahres))!.data!) {
      surahitems.add(SurahFehres(
          surahinfo.name!, surahinfo!.number!.toString(), surahinfo.pager!));
    }
    super.initState();
  }

  final player = AudioPlayer();

  showMenu(String TranslateBody) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(),
              color: Color(0x232f34),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                    height: (56 * 6).toDouble(),
                    child: Container(
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
                          children: <Widget>[
                            Positioned(child: GestureDetector(
                              child: Icon(Icons.book),
                              onTap: () async{
// await FlutterTts().speak("Hello World");
                              },
                            )),
                            Image.asset(
                              "assets/quran/page_bg.png",
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              top: -36,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(
                                        color: Colors.white, width: 10)),
                                child: Center(
                                  child: ClipOval(
                                      child: Icon(
                                    Icons.translate,
                                    color: Colors.white,
                                  )),
                                ),
                              ),
                            ),
                            Positioned(
                              child: ListView.builder(
                                itemBuilder: (ctx, indx) {
                                  return Text(
                                    modelQuranTranslate
                                            .fromJson(
                                                json.decode(TranslateBody))
                                            .data!
                                            .ayahs![indx]
                                            .text! +
                                        "(${modelQuranTranslate.fromJson(json.decode(TranslateBody)).data!.ayahs![indx].numberInSurah})",
                                    style: GoogleFonts.elMessiri(
                                        fontSize: 22, color: Colors.brown),
                                  );
                                },
                                itemCount: modelQuranTranslate
                                    .fromJson(json.decode(TranslateBody))
                                    .data!
                                    .ayahs
                                    ?.length,
                              ),
                            )
                          ],
                        ))),
              ],
            ),
          );
        });
  }

  CarouselController buttonCarouselController = CarouselController();

  Widget SurahFehres(String Name, String Number, int PageNumber) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.brown, // red as border color
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              child: Container(
                child: Text(
                  "$Number",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.reemKufi(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              ),
              bottom: 10,
            ),
            SizedBox(
              height: 50,
            ),
            Positioned(
              child: Text(
                "$Name",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              left: 60,
              bottom: 10,
            ),
            SizedBox(
              width: 110,
            ),
            Positioned(
              child: Icon(Icons.arrow_right),
              right: 5,
              bottom: 0,
              top: 0,
            ),
            SizedBox(
              width: 110,
            ),
          ],
        ),
      ),
      onTap: () {
        buttonCarouselController.jumpToPage(PageNumber - 1);
        scaffoldKey.currentState!.openEndDrawer();
      },
    );
  }

  var iconmedial = Icons.play_circle_fill;
  Widget translator = Icon(
    Icons.translate,
    size: 30,
  );
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> surahitems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: new Drawer(
        child: Stack(
          children: [
            Image.asset(
              "assets/quran/page_bg.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            ListView(
              children: surahitems,
            )
          ],
        ),
      ),
      body: Container(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/quran/page_bg.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            // Container(
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   color: Colors.black,
            // ),


            CarouselSlider.builder(
                carouselController: buttonCarouselController,
                itemCount: 604,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {

                  return Container(
                    child: InvertColors(
                      child:

                      Stack(children: [
                        Image.asset(
                          "assets/quran/p${itemIndex + 1}.png",
                          fit: BoxFit.fill,
                          height: double.maxFinite,
                        ),

                        Padding(padding: const EdgeInsets.fromLTRB(8, 10, 2, 5),child:
                        StreamBuilder(stream: player.currentIndexStream,
                          builder: (ctx,curntIndex){
                            List<TextSpan> aya=   list
                                .map((e) {
                              int ayaNum =e['aya_num'];

                              if (ayaNum ==1){

                                return TextSpan(text:"\n"+e['aya']+'    '
                                    , recognizer: TapGestureRecognizer()
                                      ..onTapUp = (t) { print('Tap Here onTap');}
                                    ,

                                    style:const TextStyle(
                                        fontFamily: 'Othmani',
                                        fontSize: 21,fontWeight: FontWeight.bold,color: Colors.transparent,backgroundColor: Colors.white)
                                );
                              }else {

                                return

                                TextSpan(
                                    text:e['aya']+'       ',
                                   onExit: (pointer){


                                    },
                                    recognizer:
                                    TapGestureRecognizer()..onTapUp = (t) {


if(postion ==Offset(0, 0)) {

   codelist=[e['aya_num'],e['sura_num']];
  SelectedAya = e['id_quran_ayat'];
  SelectedayaNum = ayaNum;
  Selectedaya = e['aya'];
  postion = t.globalPosition;
}else {
  postion = Offset(0, 0);
  SelectedayaNum = 0;
}

  CurrentColor=Colors.white.withOpacity(.5);

  setState(() {

});
                                  print('Tap ${SelectedAya}  Here onTap ${e['aya']}');
                                  },

                                    style: TextStyle(height: MediaQuery.of(context).size.height/310,
                                        fontFamily: 'Othmani',
                                        fontSize: MediaQuery.of(context).size.aspectRatio*40,fontWeight: FontWeight.bold,color: Colors.transparent
                                        ,backgroundColor:

                                        singlePlay?SelectedayaNum==ayaNum?CurrentColor:
                                        widget.markAya==0?((SelectedayaNum==ayaNum||curntIndex.data==e['aya_num']-list[0]['aya_num']) && singlePlay==false? CurrentColor:Colors.transparent           )
                                    :Colors.transparent:SelectedayaNum==ayaNum||curntIndex.data==e['aya_num']-list[0]['aya_num']? CurrentColor:Colors.transparent)
                                );}})
                                .toList(); //
                            return Container(child:
                            AutoSizeText.rich(
                                TextSpan(children: aya,)
                                ,textAlign: TextAlign.justify,textDirection:TextDirection.rtl


                            ),height: MediaQuery.of(context).size.height-150,);

                          },)),
                        (postion.dx != 0 && postion.dy != 0 )?  Positioned(child: Card(child:
                        Row(children: [

                          IconButton(onPressed: () async{
                            print("object");

 singlePlay=true;
 setState(() {

                            });
                            await player.setUrl(
                                await QuranAudio().AyatWithApiSingle(SelectedAya));

                            // await player.setUrl(
                            //     'https://cdn.islamic.network/quran/audio/64/ar.alafasy/${SelectedAya}.mp3');
                            player.play().then((value) {

                            });

                          }, icon: Icon(Icons.volume_up_outlined)),
                          Container(color: Colors.black,height: 10,width: 1,),
                          IconButton(onPressed: (){

                            Clipboard.setData(ClipboardData(text: Selectedaya));

                            Fluttertoast.showToast(
                                msg: 'اضيف الي الحافظة',
                                backgroundColor: Colors.black,
                                textColor: Colors.red);
                          }, icon: Icon(Icons.copy))
                        ],),)
                          , left: postion.dx,
                          top: postion.dy-40,
                        ):SizedBox(width: 0,height: 0,),   ],)
                    ),
                    margin: EdgeInsets.fromLTRB(0, 65, 0, 65),
                  );
                },
                options: CarouselOptions(
                  height: double.infinity,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 2.0,
                  initialPage: widget.index,
                  enableInfiniteScroll: false,
                  reverse: true,
                  autoPlay: false,
                  onPageChanged: (indx, cts) async {
                    print(indx);
                    pagerIndex = indx;
                    list = await db.rawQuery(
                        'SELECT * FROM quran where page_aya = ${indx + 1}');
                    juz = (list[0]['juz'].toString());
                    setState(() {});
                  },
                  scrollDirection: Axis.horizontal,
                )),
            Align(
              child: Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: Text(
                        "الجزء :$juz",
                        style: GoogleFonts.elMessiri(
                            fontSize: 16, color: Colors.brown),
                      ),
                      padding: EdgeInsets.only(left: 15, right: 15),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      height: 30,
                      child: TypeAheadField<SuggestionsModel?>(
                        hideSuggestionsOnKeyboardHide: false,
                        minCharsForSuggestions: 3,
                        textFieldConfiguration: TextFieldConfiguration(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                bottom: 5.0, left: 5.0, right: 5.0, top: 5),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            hintText: 'البحث بالاية ',
                          ),
                        ),
                        suggestionsCallback: getUserSuggestions,
                        itemBuilder: (context, SuggestionsModel? suggestion) {
                          final user = suggestion!;

                          return Container(
                            child:
                                Text(user.aya_taskel + "(سورة :${user.sura})"),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.brown)),
                          );
                        },
                        noItemsFoundBuilder: (context) => Container(
                          height: 100,
                          child: Center(
                            child: Text(
                              'لا يوجد نتائج مشابهة',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        onSuggestionSelected: (SuggestionsModel? suggestion) {
                          final user = suggestion!;
                          //
                          // ScaffoldMessenger.of(context)
                          //   ..removeCurrentSnackBar()
                          //   ..showSnackBar(SnackBar(
                          //     content: Text('Selected user: ${user.aya}'),
                          //   ));
                          buttonCarouselController.jumpToPage(user.page - 1);
                        },
                      ),
                    ),
                  ],
                ),
                margin: EdgeInsets.fromLTRB(5, 30, 5, 20),
              ),
              alignment: Alignment.topRight,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    // Image.asset(
                    //   "assets/quran/page_bg.png",
                    //   height: 45,
                    //   fit: BoxFit.fill,
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Positioned(
                            child: FloatingActionButton(
                              tooltip: 'Save',
                              heroTag: "btn111",
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();

// Save an integer value to 'counter' key.
                                await prefs.setInt('pageNumber', pagerIndex);

                                Fluttertoast.showToast(
                                    msg: 'تم حفظ الصفحة',
                                    backgroundColor: Colors.black,
                                    textColor: Colors.red);
                              },
                              child: const Icon(
                                Icons.bookmark,
                                size: 30,
                              ),
                            ),
                            left: 60,
                          ),

                          Positioned(
                            child: StreamBuilder<PlayerState>(
                                stream: player.playerStateStream,
                                builder: (context, snapshot) {
                                  var playerState = snapshot.data;
                                  var processingState =
                                      playerState?.processingState;
                                  var playing = playerState?.playing;
                                  if (processingState ==
                                          ProcessingState.loading ||
                                      processingState ==
                                          ProcessingState.buffering) {
                                    return FloatingActionButton(
                                      child: Container(
                                          padding: EdgeInsets.all(5),
                                          width: 30.0,
                                          height: 30.0,
                                          child: CircularProgressIndicator()),
                                      tooltip: 'play',
                                      heroTag: "btn11142",
                                      onPressed: () {},
                                    );
                                  } else if (playing != true) {
                                    return FloatingActionButton(
                                      tooltip: 'play',
                                      heroTag: "btn21",
                                      onPressed: () async {
                                        singlePlay=false;

                                        var playing =
                                            player.playerState.playing;
                                        print("$playing");
                                        if (!playing) {
                                          setState(() {
                                            iconmedial =
                                                Icons.now_widgets_outlined;
                                          });
                                          // var surah = await RepoHttpSer()
                                          //     .getafasyByPage(
                                          //         (pagerIndex + 1).toString());
                                          // print(surah);
                                          ayats =
                                              (       await QuranAudio().AyatWithApi(list!.first['page_aya']!))
        .map((e) {
          return
            AudioSource.uri(
                Uri.parse(
e
                    ));
    }).toList();
//                                           for (var e in list) {
//                                             ayats.add(
//                                             AudioSource.uri(
//                                                 Uri.parse(   await QuranAudio().AyatWithApi(e['page_aya']))));
//
//                                           }
                                          setState(() {
                                            iconmedial = Icons.download;
                                          });
                                          await player.setAudioSource(
                                            ConcatenatingAudioSource(
                                              // Start loading next item just before reaching it.
                                              useLazyPreparation:
                                                  true, // default
                                              // Customise the shuffle algorithm.
                                              shuffleOrder:
                                                  DefaultShuffleOrder(), // default
                                              // Specify the items in the playlist.
                                              children: ayats,
                                            ),
                                            // Playback will be prepared to start from track1.mp3
                                            initialIndex: 0,
                                            // default
                                            // Playback will be prepared to start from position zero.
                                            initialPosition:
                                                Duration.zero, // default
                                          );

                                          player.play().then((value) => () {

                                          });

                                          setState(() {
                                            iconmedial = Icons.play_circle_fill;
                                          });

                                        }
                                      },
                                      child: Icon(
                                        iconmedial,
                                        size: 30,
                                      ),
                                    );
                                  } else if (processingState !=
                                      ProcessingState.completed) {
                                    singlePlay=false;

                                    return FloatingActionButton(
                                      child: const Icon(
                                        Icons.pause,
                                        size: 30,
                                      ),
                                      tooltip: 'play',
                                      heroTag: "btn21",
                                      onPressed: player.pause,
                                    );
                                  } else{
                                  singlePlay=false;
                                  return FloatingActionButton(
                                    tooltip: 'play',
                                    heroTag: "btn21",
                                    onPressed: () async {

                                      var playing =
                                          player.playerState.playing;
                                      print("$playing");
                                      if (!playing) {
                                        setState(() {
                                          iconmedial =
                                              Icons.now_widgets_outlined;
                                        });
                                        // var surah = await RepoHttpSer()
                                        //     .getafasyByPage(
                                        //         (pagerIndex + 1).toString());
                                        // print(surah);
                                        ayats =
                                            (       await QuranAudio().AyatWithApi(list!.first['page_aya']!))
                                                .map((e) {
                                              return
                                                AudioSource.uri(
                                                    Uri.parse(
                                                        e
                                                    ));
                                            }).toList();
//                                           for (var e in list) {
//                                             ayats.add(
//                                             AudioSource.uri(
//                                                 Uri.parse(   await QuranAudio().AyatWithApi(e['page_aya']))));
//
//                                           }
                                        setState(() {
                                          iconmedial = Icons.download;
                                        });
                                        await player.setAudioSource(
                                          ConcatenatingAudioSource(
                                            // Start loading next item just before reaching it.
                                            useLazyPreparation:
                                            true, // default
                                            // Customise the shuffle algorithm.
                                            shuffleOrder:
                                            DefaultShuffleOrder(), // default
                                            // Specify the items in the playlist.
                                            children: ayats,
                                          ),
                                          // Playback will be prepared to start from track1.mp3
                                          initialIndex: 0,
                                          // default
                                          // Playback will be prepared to start from position zero.
                                          initialPosition:
                                          Duration.zero, // default
                                        );

                                        player.play().then((value) => () {

                                        });

                                        setState(() {
                                          iconmedial = Icons.play_circle_fill;
                                        });

                                      }
                                    },
                                    child: Icon(
                                      iconmedial,
                                      size: 30,
                                    ),
                                  );
                                  }
                                }),
                            left: 0,
                          ),
                          Positioned(
                            child: FloatingActionButton(
                              tooltip: 'play',
                              heroTag: "btn1552",
                              onPressed: () async {
                                setState(() {
                                  translator = Container(
                                      padding: EdgeInsets.all(5),
                                      width: 30.0,
                                      height: 30.0,
                                      child: CircularProgressIndicator());
                                });
                                var body = await RepoHttpSer().getTranslatePage(
                                    (pagerIndex + 1).toString());
                                showMenu(body);
                                setState(() {
                                  translator = Icon(
                                    Icons.translate,
                                    size: 30,
                                  );
                                });
                              },
                              child: translator,
                            ),
                            left: 120,
                          ),
                          Positioned(
                            child: FloatingActionButton(
                              heroTag: "btn13",
                              tooltip: 'play',
                              onPressed: () async {
                                scaffoldKey.currentState!.openDrawer();
                              },
                              child: const Icon(
                                Icons.list,
                                size: 20,
                              ),
                            ),
                            right: 0,
                          ),
                          Positioned(
                            child: FloatingActionButton(
                              heroTag: "btn3ss11",
                              tooltip: 'back',
                              onPressed: () async {
                                List<Map> list = await db.query('quran',
                                    where: 'page_aya =?',
                                    whereArgs: ['${pagerIndex + 1}']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SurahMoreDetails(
                                            title: list[0]['sura'],
                                            index: pagerIndex + 1,
                                            list: list,
                                          )),
                                );
                              },
                              child: const Icon(
                                Icons.info_outline,
                                size: 30,
                              ),
                            ),
                            right: 120,
                          ),
                          Positioned(
                            child: FloatingActionButton(
                              heroTag: "btn311",
                              tooltip: 'back',
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_outlined,
                                size: 30,
                              ),
                            ),
                            right: 60,
                          ),
                        ],
                      ),
                      margin: EdgeInsets.all(5),
                    ),
                    Align(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white54,
                        ),
                        child: Text(
                          "${pagerIndex + 1}",
                          style: GoogleFonts.elMessiri(
                              fontSize: 22, color: Colors.brown),
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: Row(
      //   children: [
      //     const SizedBox(
      //       width: 20,
      //     ),
      //     FloatingActionButton(
      //       child: const Icon(Icons.search),
      //       onPressed: () => context.read<ayahCubit>().Search(word.text),
      //     ),
      //     // FloatingActionButton(
      //     //   child: const Icon(Icons.add),
      //     //   onPressed: () => context.read<CounterCubit>().increment(),
      //     // ),
      //     const SizedBox(height: 4),
      //     const SizedBox(
      //       width: 20,
      //     ),
      //     // FloatingActionButton(
      //     //   onPressed: () => context.read<CounterCubit>().decrement(),
      //     //   tooltip: 'Increment',
      //     //   child: const Icon(Icons.remove),
      //     // ),
      //     const SizedBox(
      //       width: 20,
      //     ),
      //   ],
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<SuggestionsModel>> getUserSuggestions(String pattern) async {
    List<Map> list = await db.query("quran",
        where: "search_aya LIKE ?", whereArgs: ['%$pattern%'], limit: 10);
    log(list.toString());
    List<SuggestionsModel> smallist = [];
    for (var mysmallist in list) {
      smallist.add(SuggestionsModel(
          aya: mysmallist['search_aya'],
          page: mysmallist['page_aya'],
          sura: mysmallist['sura'],
          num_aya: mysmallist['aya_num'],
          aya_taskel: mysmallist['aya']));
    }
    return smallist;
  }


  }


class SuggestionsModel {
  String aya;
  String aya_taskel;
  int page;
  String sura;
  int num_aya;
  SuggestionsModel({
    required this.aya,
    required this.page,
    required this.sura,
    required this.num_aya,
    required this.aya_taskel,
  });
}
