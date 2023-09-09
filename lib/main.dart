import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:ana_almuslim/Blocs/prayTimesBlocs/MainBloc.dart';
import 'package:ana_almuslim/Posts.dart';
import 'package:ana_almuslim/azkar.dart';
import 'package:ana_almuslim/dross/drosElalm.dart';
import 'package:ana_almuslim/duaPage.dart';
import 'package:ana_almuslim/model/prayTimesModel.dart';
import 'package:ana_almuslim/mosabka.dart';
import 'package:ana_almuslim/prayTimes.dart';
import 'package:ana_almuslim/qibla.dart';
import 'package:ana_almuslim/quran.dart';
import 'package:ana_almuslim/repo/repo.dart';
import 'package:ana_almuslim/ui/configFirebase.dart';
import 'package:ana_almuslim/ui/testTrueOverLay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_windows_plugin/overlay_windows_api.g.dart';
import 'package:overlay_windows_plugin/overlay_windows_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wakelock/wakelock.dart';

import 'Blocs/prayTimesBlocs/StatesBlocs.dart';
import 'Settings.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);

  SharedPreferences? prefs;
  prefs = await SharedPreferences.getInstance();
  await initializeService();

  runApp(MyApp());
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {}
  var name = prefs.getString('nickname') ?? '';
  var id = prefs.getString('id') ?? '';

  if (name == '' && id == '') {
    prefs.setString('nickname', "زائر");
    prefs.setString(
        'id',
        DateTime.now().millisecondsSinceEpoch.toString() +
            Random().nextInt(150).toString());
  }
}

@pragma("vm:entry-point")
void overlayMain2() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child:TextFieldOverlay( ))
  ));
}

@pragma("vm:entry-point")
void overlayMain1() {
  runApp(
     MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: TextFieldOverlay(),
      ),
    ),
  );
}

final _overlayWindowsPlugin = OverlayWindowsPlugin.defaultInstance;

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;
bool flag =false;
bool flagAzanUpdate =true;
final player = AudioPlayer();



Future<void> initializeSettings() async {
  SharedPreferences preferences=await SharedPreferences.getInstance();
var  _WakeUp = preferences.getInt("wakeUpAlways")??1;
if(_WakeUp==0){
  Wakelock.enable();

}else{
  Wakelock.disable();

}

  // _receivePort.listen((event) {
  //   print("Current Event: $event");
  // });

}
Future<void> initializeService() async {
  initializeSettings();
  final service = FlutterBackgroundService();

  await service.configure(
      androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
        autoStartOnBoot:true,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
  ), iosConfiguration: IosConfiguration(),);
}

Future<void> onStart(ServiceInstance service) async {
SharedPreferences preferences= await SharedPreferences.getInstance();
print("ServiceStart");

  Timer.periodic(const Duration(seconds: 30), (timer) async {
   var Dindex = preferences.getInt("AzanEnabled")??1;
   var  dropdownvalueAzan = preferences.getInt("dropdownvalueAzan")??1;


   if(Dindex ==0) {
      if (flagAzanUpdate) {
        flagAzanUpdate = false;

        print("GettingAzan");
        var func = await RepoHttpSer().prayTime();
        print(AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Asr!);
        preferences.setStringList('azanTimes', [AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Fajr!, AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Dhuhr!, AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Asr!, AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Maghrib!, AutoGenerate
            .fromJson(json.decode(func))
            .data
            .timings!
            .Isha!
        ]);
      }
      var currentTime = "${DateTime
          .now()
          .hour < 10 ? "0"+ DateTime
          .now()
          .hour
          .toString()  : DateTime
          .now()
          .hour
          .toString()
      }:${DateTime
          .now()
          .minute < 10 ?"0" + DateTime
          .now()
          .minute
          .toString() :
      (DateTime
          .now()
          .minute).toString()}";
      var AzanArray = await preferences.getStringList("azanTimes");

      print(AzanArray![0] + "Now:$currentTime");
      if (AzanArray!.contains(currentTime) && flag == false) {

        print("StartAzan");

        _overlayWindowsPlugin.showOverlayWindow(
            "AzanOverLay",
            "overlayMain1",
            OverlayWindowConfig(
              width: 300,
              height: 100,
              enableDrag: true,
            ));
        flag = true;
        await player.setAsset(
            'assets/azanAudio/azan$dropdownvalueAzan.mp3');
        player.play().then((value) async{

          flag = false;
        });
      }
    }

  });

  Timer.periodic(const Duration(minutes: 50), (timer) async {
    flagAzanUpdate=true;


  });

Timer.periodic(const Duration(minutes: 15), (timer) async {

  var pioo = preferences.getInt("AzanEnabled")??1;
  if(pioo==0) {
    await player.setAsset(
        'assets/azanAudio/prophetPrayUpon.mp3');
    player.play().then((value) async{

      flag = false;
    });
  }

});

// _overlayWindowsPlugin.messageStream.listen((event) {
//   _overlayWindowsPlugin.closeOverlayWindow("AzanOverLay");
//     print(event);
//
// });
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainBloc>(
          create: (BuildContext context) =>
              MainBloc(IntialState(), RepoHttpSer()),
        ),
        // BlocProvider<ProfileBloc>(
        //   create: (BuildContext context) =>
        //       ProfileBloc(IntialStateProfile(), RepoGetCards()),
        // ),
        // BlocProvider<BlocC>(
        //   create: (BuildContext context) => BlocC(),
        // ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          /* light theme settings */
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.light,
        /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
        debugShowCheckedModeBanner: false,
        //  home: AzkarPage(),
        // home: MosabpkaView(
        //   title: "اختبر معلوماتك الدينية",
        //   index: 0,
        // ),
        // home: SurahView(
        //   title: "",
        //   index: '',
        // ),
        // home: Qiblapage(),
        home: MyHomePage(title: "خير زاد "),
        // home: PrayTimePage(
        //   title: "مواقيت الصلاة",
        // ),
        // home: DrosEEleam(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
bool playingRadioFlag =true;
  @override
  Widget build(BuildContext context) {
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
        ),actions: [

        IconButton(onPressed: () async{
if(playingRadioFlag){
          await player.setUrl(
              'http://n11.radiojar.com/8s5u5tpdtwzuv?rj-ttl=5&rj-tok=AAABinO1fdcATMoteyGVL18AvQ');
       await   player.play().then((value) {
          });
  playingRadioFlag = false;
}else{
  await player.stop();
  playingRadioFlag = true;
}
setState(() {

});
        }, icon:  Icon(playingRadioFlag ==true?Icons.radio:Icons.stop)),
        IconButton(onPressed: ()async{
          // _overlayWindowsPlugin.closeOverlayWindow("AzanOverLay");

          // _overlayWindowsPlugin.showOverlayWindow(
          //     "AzanOverLay",
          //     "overlayMain2",
          //     OverlayWindowConfig(
          //       width: 600,
          //       height: 400,
          //       enableDrag: true,
          //
          //     ));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(              ),
            ),
          );
        }, icon: const Icon(Icons.settings)),

      ],
      ),
      body: Container(
        color: Color.fromARGB(255, 242, 242, 242),
        child: Stack(
          children: <Widget>[
            Align(
              child: Container(
                child: Image.asset(
                    "assets/app_images/bg_image.jpg" //Lottie.asset('assets/girlrecitingholyquran.json'),
                    ),
                height: 950,
                margin: EdgeInsets.only(bottom: 0),
              ),
              alignment: Alignment.bottomCenter,
            ),
            Align(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: GridView.count(
                    childAspectRatio: 3 / 2,
                    crossAxisCount: 2,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          var pagerIndex = prefs.getInt('pageNumber') ?? 0;
                          var ayaMark = prefs.getInt('ayaMark') ?? 0;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahView(
                                title: "مواقيت الصلاة",
                                index: pagerIndex,
                                markAya: ayaMark,

                              ),
                            ),
                          );
                        },
                        child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/quran_Icon.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "القران",
                                  style: GoogleFonts.reemKufi(fontSize: 18),
                                )
                              ],
                            )),
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/lukpedclub200500482.jpg",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "مواقيت الصلاة",
                                  style: GoogleFonts.reemKufi(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrayTimePage(
                                title: "مواقيت الصلاة",
                              ),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/muslimprayer.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "الاذكار",
                                  style: GoogleFonts.cairo(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AzkarPage(),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/images_screen.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "دروس العلم",
                                  style: GoogleFonts.reemKufi(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (ctcx) => DrosEEleam())),
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/champ-1580223-1335330.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "مسابقات",
                                  style: GoogleFonts.reemKufi(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MosabpkaView(
                                title: "اختبر معلوماتك الدينية",
                                index: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/duah.jpeg",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "ادعية",
                                  style: GoogleFonts.cairo(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DuaPage(),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Posts(
                                peerId: "peerId", peerAvatar: "peerAvatar"),
                          ),
                        ),
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/3113416.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "كن عون اخيك",
                                  style: GoogleFonts.cairo(fontSize: 18),
                                )
                              ],
                            )),
                      ),
                      GestureDetector(
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "assets/app_images/84649.png",
                                  width: 50,
                                  height: 50,
                                ),
                                Text(
                                  "القبلة",
                                  style: GoogleFonts.cairo(fontSize: 18),
                                )
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Qiblapage()),
                          );
                        },
                      )
                    ]),
              ),
              alignment: Alignment.center,
            ),
            Container(
              child: Lottie.asset('assets/ramadanmoubarak.json'),
              height: 120,
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future<void> _checkLocationStatus() async {
    await FlutterQiblah.checkLocationStatus();
    await FlutterQiblah.requestPermissions();
    /// check if overlay permission is granted
    //  await FlutterOverlayWindow.isPermissionGranted();

    /// request overlay permission
    /// it will open the overlay settings page and return `true` once the permission granted.
//  await FlutterOverlayWindow.requestPermission();
//     await FlutterOverlayWindow.closeOverlay();



  }


  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }
}
