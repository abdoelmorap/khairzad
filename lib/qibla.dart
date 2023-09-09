import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torch_light/torch_light.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widget = (Platform.isAndroid)
        ? CircularProgressIndicator()
        : CupertinoActivityIndicator();
    return Container(
      alignment: Alignment.center,
      child: widget,
    );
  }
}

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({Key? key, this.error, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(height: 32);
    final errorColor = Color(0xffb00020);

    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.location_off,
              size: 150,
              color: errorColor,
            ),
            box,
            Text(
              error!,
              style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
            ),
            box,
            ElevatedButton(
              child: Text("Retry"),
              onPressed: () {
                if (callback != null) callback!();
              },
            )
          ],
        ),
      ),
    );
  }
}

class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return LoadingIndicator();
          if (snapshot.data!.enabled == true) {
            switch (snapshot.data!.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return QiblahCompassWidget();

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "Location service permission denied",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "Location service Denied Forever !",
                  callback: _checkLocationStatus,
                );
              // case GeolocationStatus.unknown:
              //   return LocationErrorWidget(
              //     error: "Unknown Location service error",
              //     callback: _checkLocationStatus,
              //   );
              default:
                return Container();
            }
          } else {
            return LocationErrorWidget(
              error: "Please enable Location service",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else
      _locationStreamController.sink.add(locationStatus);
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
}

class QiblahCompassWidget extends StatelessWidget {
  final _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    height: 300,
    alignment: Alignment.center,
  );
  void vivrateit() async {
    // Check if the device can vibrate
    bool canVibrate = await Vibrate.canVibrate;
    try {
      final isTorchAvailable = await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      // Handle error
    }
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {
      // Handle error
    }

    Vibrate.vibrate();

    if (canVibrate) {
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          TorchLight.disableTorch();
        } on Exception catch (_) {
          // Handle error
        }
      });
    }
    log("هزهز يسطا Virbrate me ");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return LoadingIndicator();
        var colorArrow;
        final qiblahDirection = snapshot.data!;
        var didd = qiblahDirection.direction - qiblahDirection.offset;
        if (didd > -8 && didd < 8) {
          vivrateit();
          colorArrow = Colors.green;
        } else {
          colorArrow = Colors.red;
        }

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 400),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 50,
                  color: colorArrow,
                ),
              ),
            ),
            Transform.rotate(
              angle: (qiblahDirection.direction * (pi / 180) * -1),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(250.0),
                  child: Image.asset(
                    "assets/compass.png",
                    fit: BoxFit.fill,
                  )),
            ),
            Transform.rotate(
              angle: (qiblahDirection.qiblah * (pi / 180) * -1),
              alignment: Alignment.center,
              child: Container(
                child: _needleSvg,
                height: 150,
              ),
            ),
            // Positioned(
            //   bottom: 5,
            //   child: Text(
            //     "${(didd).toStringAsFixed(3)}°",
            //     style: TextStyle(color: Colors.black),
            //   ),
            // )
          ],
        );
      },
    );
  }
}

class Qiblapage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Qiblapage> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff0c7b93),
        primaryColorLight: Color(0xff00a8cc),
        primaryColorDark: Color(0xff27496d),
        //accentColor: Color(0xffecce6d),
      ),
      //darkTheme: ThemeData.dark().copyWith(accentColor: Color(0xffecce6d)),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "تحديد القبلة",
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          centerTitle: true,
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
        body: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Text("LOading"),
              );
            if (snapshot.hasError)
              return Center(
                child: Text("Error: ${snapshot.error.toString()}"),
              );
            return Stack(
              children: [
                Container(
                  color: Color.fromARGB(255, 242, 242, 242),
                  height: double.infinity,
                ),
                Align(
                  child: Container(
                    // child: Image.network(
                    //     "https://i.pinimg.com/736x/9c/7e/70/9c7e70b58b4010bea3f3a8631fd393c9.jpg" //Lottie.asset('assets/girlrecitingholyquran.json'),
                    //     ),
                    height: 950,
                    margin: EdgeInsets.only(bottom: 0),
                  ),
                  alignment: Alignment.bottomCenter,
                ),
                Align(
                  child: ClipPath(
                    clipper: WaveClipperTwo(reverse: true),
                    child: Container(
                      height: 120,
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
                  alignment: Alignment.bottomCenter,
                ),
                QiblahCompass()
              ],
            );
            // if (snapshot.data!)
            // return ;
            // else
            //   return QiblahMaps();
          },
        ),
      ),
    );
  }
}
