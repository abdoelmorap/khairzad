import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ana_almuslim/json/jsonSaver.dart';
import 'package:ana_almuslim/model/fahresModel.dart';
import 'package:ana_almuslim/model/modelQuranTranslate.dart';
import 'package:ana_almuslim/model/quranModelData.dart';
import 'package:ana_almuslim/repo/repo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as pathservices;
import 'package:sqflite/sqflite.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'QuranAudioGenrator.dart';

class SurahMoreDetails extends StatefulWidget {
  const SurahMoreDetails(
      {Key? key, required this.title, required this.index, required this.list})
      : super(key: key);
  final List<Map> list;
  final String title;
  final int index;

  @override
  State<SurahMoreDetails> createState() => _SurahMoreDetailsState();
}

class _SurahMoreDetailsState extends State<SurahMoreDetails> {
  final player = AudioPlayer();

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
          ),
        ),
        body: SafeArea(
            child: Container(

          child: ListView.builder(
            itemBuilder: (ctx, indx) {
              void oncopy(text) {
                Clipboard.setData(ClipboardData(text: text,));

                Fluttertoast.showToast(
                    msg: 'اضيف الي الحافظة',
                    backgroundColor: Colors.black,
                    textColor: Colors.red);
              }

              void onshare(text) async {
                await FlutterShare.share(
                  title: 'مشاركة من التطبيق',
                  text: text,
                );
              }

              return Container(
                  margin: EdgeInsets.all(10),
                  child: InputDecorator(
                      decoration: InputDecoration(
                         labelText:
                            'الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                suffixIcon: Column(
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.pink,
                                      ),
                                      onTap: () => onshare(
                                          widget.list[indx]['aya'].toString()),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.copy,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => oncopy(
                                          widget.list[indx]['aya'].toString()),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.multitrack_audio_rounded,
                                        color: Colors.green,
                                      ),
                                      onTap: () async {
                                        log("AudioStart");
                                        // await player.setUrl(
                                        //     'https://cdn.islamic.network/quran/audio/64/ar.alafasy/${widget.list[indx]['id_quran_ayat']}.mp3');

                                        await player.setUrl(
                                            await QuranAudio().AyatWithApiSingle(widget.list[indx]['id_quran_ayat']));

                                        player.play();
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                                labelText:
                                    'الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                widget.list[indx]['aya'].toString(),
                                style: GoogleFonts.amiriQuran(fontSize: 28,fontWeight:FontWeight.w600),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: InputDecorator(
                              decoration: InputDecoration(

                                labelText:
                                    'تفسير الميسر الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Column(children: [

                                Row(
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.deepPurple,
                                      ),
                                      onTap: () => onshare(widget.list[indx]
                                      ['tafsir_moysar']
                                          .toString()),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.copy,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => oncopy(widget.list[indx]
                                      ['tafsir_moysar']
                                          .toString()),
                                    ),
                                  ],
                                ), SizedBox(height: 10,),Text(
                                  widget.list[indx]['tafsir_moysar'].toString(),
                                  style:  GoogleFonts.jomhuria(fontSize: 26,fontWeight: FontWeight.w100),  textAlign: TextAlign.right,
                                ),
                              ],)
                            ),
                          ), Row(
                            children: [SizedBox(width: 10,),
                              GestureDetector(
                                child: Icon(
                                  Icons.share,
                                  color: Colors.red,
                                ),
                                onTap: () => onshare(
                                    widget.list[indx]['aya'].toString() +
                                        "(وتفسيرها) " +
                                        widget.list[indx]['tafsir_moysar']
                                            .toString()),
                              ),
                              SizedBox(
                                height: 10,width: 20,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.copy,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onTap: () => oncopy(
                                    widget.list[indx]['aya'].toString() +
                                        "(وتفسيرها) " +
                                        widget.list[indx]['tafsir_moysar']
                                            .toString()),
                              ),
                            ],
                          ),SizedBox(height: 15,),
                          ExpansionTile(
                              title: Text(
                                "المزيد",
                                style: GoogleFonts.elMessiri(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      suffixIcon: Column(
                                        children: [
                                          GestureDetector(
                                            child: Icon(Icons.share),
                                            onTap: () => onshare(widget
                                                .list[indx]['ma3ny_aya']
                                                .toString()),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.copy),
                                            onTap: () => oncopy(widget
                                                .list[indx]['ma3ny_aya']
                                                .toString()),
                                          ),
                                        ],
                                      ),
                                      labelText:
                                          'معاني الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(widget.list[indx]['ma3ny_aya']
                                        .toString(),style: GoogleFonts.cairoPlay(fontSize: 21,fontWeight: FontWeight.w800),
                                      textAlign: TextAlign.right,),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(

                                      labelText:
                                          'تفسير السعدي الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child:Column(children: [
              Row(
              children: [
              GestureDetector(
              child: Icon(Icons.share),
              onTap: () => onshare(widget
                  .list[indx]['tafsir_saadi']
                  .toString()),
              ),
              SizedBox(
              height: 10,
              ),
              GestureDetector(
              child: Icon(Icons.copy),
              onTap: () => oncopy(widget
                  .list[indx]['tafsir_saadi']
                  .toString()),
              ),
              ],
              ),
                                      Text(widget.list[indx]
                                      ['tafsir_saadi']
                                          .toString(),style: GoogleFonts.cairoPlay(fontSize: 21,fontWeight: FontWeight.w800),
                                        textAlign: TextAlign.right,),  ],)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText:
                                          'تفسير البغوي الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child:Column(children: [

              Column(
              children: [
              GestureDetector(
              child: Icon(Icons.share),
              onTap: () => onshare(widget
                  .list[indx]['tafsir_baghawi']
                  .toString()),
              ),
              SizedBox(
              height: 10,
              ),
              GestureDetector(
              child: Icon(Icons.copy),
              onTap: () => oncopy(widget
                  .list[indx]['tafsir_baghawi']
                  .toString()),
              ),
              ],
              ),

                                      Text(widget.list[indx]
                                      ['tafsir_baghawi']
                                          .toString(),style: GoogleFonts.cairoPlay(fontSize: 21,fontWeight: FontWeight.w800),
                                        textAlign: TextAlign.right,),
              ],)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      suffixIcon: Column(
                                        children: [
                                          GestureDetector(
                                            child: Icon(Icons.share),
                                            onTap: () => onshare(widget
                                                .list[indx]['e3rab_quran']
                                                .toString()),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.copy),
                                            onTap: () => oncopy(widget
                                                .list[indx]['e3rab_quran']
                                                .toString()),
                                          ),
                                        ],
                                      ),
                                      labelText:
                                          'الاعراب الاية رقم : ${widget.list[indx]['aya_num']} سورة : ${widget.list[indx]['sura']}',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(widget.list[indx]['e3rab_quran']
                                        .toString(),style: GoogleFonts.cairoPlay(fontSize: 21,fontWeight: FontWeight.w800),
                                      textAlign: TextAlign.right,),
                                  ),
                                ),
                              ]),
                        ],
                      )));
              //Text(widget.list[indx].toString());
            },
            itemCount: widget.list.length,
          ),
        )));
  }
}
