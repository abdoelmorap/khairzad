import 'dart:convert';

import 'package:ana_almuslim/Blocs/prayTimesBlocs/StatesBlocs.dart';
import 'package:ana_almuslim/Blocs/prayTimesBlocs/eventsBloc.dart';
import 'package:ana_almuslim/model/prayTimesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Blocs/prayTimesBlocs/MainBloc.dart';

class PrayTimePage extends StatefulWidget {
  const PrayTimePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<PrayTimePage> createState() => _PrayTimePageState();
}

class _PrayTimePageState extends State<PrayTimePage> {
  MainBloc? mainBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 242, 242, 242),
            height: double.infinity,
          ),
          Align(
            child: Container(
              child: Image.asset("assets/app_images/bg_image.jpg"),
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
          BlocListener<MainBloc, CardState>(
            // padding: EdgeInsets.symmetric(horizontal: 20),
            listener: (BuildContext context, state) {
              // if (state is GetProfileState) {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) {
              //       return ProfilePage(title: state.id!);
              //     }),
              //   );
              // }
            },
            child: Center(child:
                BlocBuilder<MainBloc, CardState>(builder: (context, state) {
              if (state is IntialState) {
                var Times = json.decode(state.result!);
                final length = 6;

                return GridView.count(
                  childAspectRatio: 3 / 2,
                  crossAxisCount: 2,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "صلاة \n الفجر",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Fajr
                                  .toString())
                            ],
                          )),
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "صلاة \n الظهر",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Dhuhr
                                  .toString())
                            ],
                          )),
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "صلاة \n العصر",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Asr
                                  .toString())
                            ],
                          )),
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "صلاة \n المغرب",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Maghrib
                                  .toString())
                            ],
                          )),
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "صلاة \n العشاء",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Isha
                                  .toString())
                            ],
                          )),
                    ),
                    GestureDetector(
                      child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "شروق \nالشمس",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.reemKufi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Text(AutoGenerate.fromJson(Times)
                                  .data
                                  .timings
                                  .Sunrise
                                  .toString())
                            ],
                          )),
                    ),
                  ],
                );
              } else if (state is LoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container();
              }
            })),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    mainBloc = BlocProvider.of<MainBloc>(context);
    BlocProvider.of<MainBloc>(context).add(startEvent());
  }
}
