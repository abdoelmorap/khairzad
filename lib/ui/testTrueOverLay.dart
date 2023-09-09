import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_windows_plugin/overlay_message.dart';
import 'package:overlay_windows_plugin/overlay_window_view.dart';
import 'package:overlay_windows_plugin/overlay_windows_plugin.dart';

class TextFieldOverlay extends StatefulWidget {
  const TextFieldOverlay({Key? key}) : super(key: key);

  @override
  State<TextFieldOverlay> createState() => _TextFieldOverlayState();
}

class _TextFieldOverlayState extends State<TextFieldOverlay> {
  final view = OverlayWindowView();
  // OverlayWindowView? view;
  //
  // String? viewId;
  // String? message;
  final _overlayWindowsPlugin = OverlayWindowsPlugin.defaultInstance;
  @override
  void initState() {
    super.initState();

    // view?.messageStream.listen(onMessage);


  }

  // void onMessage(OverlayMessage mes) {
  //   setState(() {
  //     message = mes.message as String;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    // view = OverlayWindowView();
    return Stack(children:[Image.network("https://www.dostor.org/UploadCache/libfiles/369/1/600x338o/544.jpg",
      fit: BoxFit.fill,),Align(
      child:Padding(child:  ElevatedButton( style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          fixedSize: const Size(300 ,50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50))),onPressed: () async {
        final _overlayWindowsPlugin = OverlayWindowsPlugin.defaultInstance;
         print("pressed");
         await view.sendMessage("message");
         await view.close();
        view.sendMessage('Hello from overlay ').catchError((error) => print(error));
         print("done");



      }, child: Text("إيقاف الأذان",
        style: GoogleFonts.amiriQuran().copyWith(fontSize: 22),)),padding: EdgeInsets.all(20)),alignment: Alignment.bottomCenter,
    )]
    );
  }
}