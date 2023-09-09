import 'package:ana_almuslim/QuranAudioGenrator.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {

    return SettingsPageState();
  }

}
class SettingsPageState extends State<SettingsPage>{
  late SharedPreferences preferences;
  int _EnableAzan=1;
  int _WakeUp=1;
  int _RemmberPhrophet=1;
  int _StyDileReciter=1;
  int _MushafDarkMode=1;
  int ayaMark=0;
  int dropdownvalue=1;
  int dropdownvalueRec=1;
  int dropdownvalueRecSingleAya=12;
  List<String> recArray=["عبدالباسط عبد الصمد(مجود)",
    "عبدالباسط عبد الصمد(مرتل)",
    "عبدالرحمن السديس","أبوبكر الشاطري",
  "هاني الرافعي",
    "محمود خليل الحصري",
    "مشاري راشد العفاسي",""
        "محمد صديق المنشاوي(مجود)",
    "محمد صديق المنشاوي(مرتل)",
    "سعود الشريم","محمد الطبلاوي"
  ,"محمود خليل الحصري(معلم)",];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(
      title: Text("الإعدادات" , style: GoogleFonts.reemKufi(fontSize: 18),
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
        )
    ),

        body: ListView(children: [
      SizedBox(height: 5,),
Text("          الإعدادات العامة  بالتطبيق   ", style: GoogleFonts.amiriQuran(fontSize: 18,fontWeight:
FontWeight.bold),),
      Container(height: 1,width: double.infinity,color: Colors.black,
      margin: EdgeInsets.all(10),),
      SizedBox(height: 20,),
Row(children: [const SizedBox(width: 10,),
  ToggleSwitch(
    minWidth: 70.0,
    cornerRadius: 20.0,
    activeBgColors: [[Colors.green[800]!], [Colors.red[800]!]],
    activeFgColor: Colors.white,
    inactiveBgColor: Colors.grey,
    inactiveFgColor: Colors.white,
    initialLabelIndex: _EnableAzan,
    totalSwitches: 2,
    labels: const ['تشغيل', 'إيقاف'],
    radiusStyle: true,
    onToggle: (index) {

      _EnableAzan=index!;
      SetPrefrenss("AzanEnabled",index);

      print('switched to: $index');
    },
  ),     const SizedBox(width: 55,),  Text("تشغيل المؤذن في التطبيق",
    style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold
    ),),
    ],),   SizedBox(height: 10,),Row(children: [const SizedBox(width: 10,),
        ToggleSwitch(
          minWidth: 70.0,
          cornerRadius: 20.0,
          activeBgColors: [[Colors.pink[800]!], [Colors.purple[800]!]],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _WakeUp,
          totalSwitches: 2,
          labels: const ['تشغيل', 'إيقاف'],
          radiusStyle: true,
          onToggle: (index) {

            _WakeUp=index!;
            SetPrefrenss("wakeUpAlways",index);

            print('switched to: $index');
          },
        ),     const SizedBox(width: 50,),  Text("إبقاء الهاتف في وضع اليقظة ",
          style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold
          ),),
      ],),
        // Container(child:

      // CSCPicker(
      //   onCountryChanged: (value) {
      //     setState(() {
      //       //countryValue = value;
      //     });
      //   },
      //   onStateChanged:(value) {
      //     setState(() {
      //       // stateValue = value;
      //     });
      //   },
      //   onCityChanged:(value) {
      //     setState(() {
      //       //   cityValue = value;
      //     });
      //   },
      // ),
      //     ),
          SizedBox(height: 10,),Row(children: [const SizedBox(width: 10,),
        ToggleSwitch(
          minWidth: 70.0,
          cornerRadius: 20.0,
          activeBgColors: [[Colors.blue[800]!], [Colors.brown[800]!]],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _RemmberPhrophet,
          totalSwitches: 2,
          labels: const ['تشغيل', 'إيقاف'],
          radiusStyle: true,
          onToggle: (index) {

            _RemmberPhrophet=index!;
            SetPrefrenss('ProphetPrayUpon',index);

            print('switched to: $index');
          },
        ),     const SizedBox(width: 30,),  Text("التذكير بالصلاة علي النبي(15.د)",
          style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold
          ),),
      ],),   SizedBox(height: 10,),Row(children: [const SizedBox(width: 10,),
        ToggleSwitch(
          minWidth: 70.0,
          cornerRadius: 20.0,
          activeBgColors: [[Colors.black!], [Colors.blueGrey!]],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _MushafDarkMode,
          totalSwitches: 2,
          labels: const ['تشغيل', 'إيقاف'],
          radiusStyle: true,
          onToggle: (index) {

            _EnableAzan=index!;
            SetPrefrenss("MushafDarkMode",index);

            print('switched to: $index');
          },
        ),     const SizedBox(width: 30 ,),  Text("تشغيل الوضع المظلم بالمصحف",
          style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold
          ),),
      ],),
      SizedBox(height: 10,),
      Text("          الإعدادات  الخاصة بالتلاوة   ", style: GoogleFonts.amiriQuran(fontSize: 18,fontWeight:
      FontWeight.bold),),
      Container(height: 1,width: double.infinity,color: Colors.black,
        margin: EdgeInsets.all(5),),
    //   SizedBox(height: 10,),Row(children: [const SizedBox(width: 5,),
    //     ToggleSwitch(
    //       minWidth: 70.0,
    //       cornerRadius: 20.0,
    //       activeBgColors: [[Colors.orange[800]!], [Colors.blue[800]!]],
    //       activeFgColor: Colors.white,
    //       inactiveBgColor: Colors.grey,
    //       inactiveFgColor: Colors.white,
    //       initialLabelIndex: _StyDileReciter,
    //       totalSwitches: 2,
    //       labels: const ['مجود', 'مرتل'],
    //       radiusStyle: true,
    //       onToggle: (index) {
    //
    //         _StyDileReciter=index!;
    //         SetPrefrenss("style_reciter",index);
    //
    //         print('switched to: $index');
    //       },
    //     ),     const SizedBox(width: 5,),  Text("نوع القراءة المسموعة(غير متاح دائماً)",
    //       style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
    // ),),
    // ],),

          SizedBox(height: 10,),Row(children: [const SizedBox(width: 10,),
            ToggleSwitch(
              minWidth: 70.0,
              cornerRadius: 20.0,
              activeBgColors: [[Colors.blueGrey!], [Colors.pink[800]!]],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              initialLabelIndex: ayaMark,
              totalSwitches: 2,
              labels: const ['تشغيل', 'إيقاف'],
              radiusStyle: true,
              onToggle: (index) {

                ayaMark=index!;
                SetPrefrenss("style_reciter",index);

                print('switched to: $index');
              },
            ),     const SizedBox(width: 50,),  Text("تحديد الإية أثناء القراءة",
              style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
              ),),
      ],),

      SizedBox(height: 10,),
Row(children: [ const SizedBox(width: 25,),
  DropdownButton(

    // Initial Value
    value: dropdownvalue.toString(),

    // Down Arrow Icon
    icon: const Icon(Icons.keyboard_arrow_down),

    // Array list of items
    items: ["1","2","3",
    "4","5"].map((String items) {
      return DropdownMenuItem(
        value: items,
        child: Container(margin: EdgeInsets.all(10),child: Text("أذان$items", style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
        ),),width: 80,),
      );
    }).toList(),
    // After selecting the desired option,it will
    // change button value to selected value
    onChanged: (String? newValue) async{
      AudioPlayer player=AudioPlayer();
      await player.setAsset(
          'assets/azanAudio/azan$newValue.mp3');

      await player.setClip(start: Duration(seconds: 2), end: Duration(seconds: 10));

      setState(() {
        dropdownvalue = int.parse(newValue!);
        SetPrefrenss("dropdownvalueAzan", dropdownvalue);
      });
      player.play();
    },
  ),const SizedBox(width: 50,),  Text("صوت الأذان",
    style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
    ),textAlign: TextAlign.right,textDirection: TextDirection.rtl,),
],)
,
      Column(children: [   Text("صوت التلاوة :       ",
        style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
        ),textAlign: TextAlign.right,textDirection: TextDirection.rtl,),
Container(child:
DropdownButton(

  // Initial Value
  value: dropdownvalueRec,

  // Down Arrow Icon
  icon: const Icon(Icons.keyboard_arrow_down),

  // Array list of items
  items: [1,2,3,4,5,6,7,8,9,10,11,12].map((int items) {
    return DropdownMenuItem(
      value: items,
      child: Container(margin: EdgeInsets.all(10),child: Text("${recArray[items-1]}", style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
      ),),width: MediaQuery.of(context).size.width*70/100,),
    );
  }).toList(),
  // After selecting the desired option,it will
  // change button value to selected value
  onChanged: (int? newValue) async{
    setState(() {
      dropdownvalueRec = (newValue!);
    });
    SetPrefrenss("dropdownvalueRec", dropdownvalueRec);
    AudioPlayer player=AudioPlayer();
    print(await (QuranAudio().AyatWithApiAndRec(2,dropdownvalueRec)));
    await player.setUrl( await (QuranAudio().AyatWithApiAndRec(2,dropdownvalueRec)));

    await player.setClip(start: Duration(seconds: 0), end: Duration(seconds: 10));


    player.play();

  },
),  margin: EdgeInsets.only(right: 25),) ],)
    ,  Column(children: [   Text("صوت التلاوة للاية الواحدة:       ",
        style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
        ),textAlign: TextAlign.right,textDirection: TextDirection.rtl,),
        Container(child:
        DropdownButton(

          // Initial Value
          value: dropdownvalueRecSingleAya,

          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: [1,2,3,4,5,6,7,8,9,10,11,12].map((int items) {
            return DropdownMenuItem(
              value: items,
              child: Container(margin: EdgeInsets.all(10),child: Text("${recArray[items-1]}", style: GoogleFonts.marhey(fontSize: 15,fontWeight: FontWeight.bold,
              ),),width: MediaQuery.of(context).size.width*70/100,),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (int? newValue) async{
            setState(() {
              dropdownvalueRecSingleAya = (newValue!);
            });
            SetPrefrenss("dropdownvalueRecSingleAya", dropdownvalueRecSingleAya);
            AudioPlayer player=AudioPlayer();
            print(await (QuranAudio().AyatWithApiAndRec(2,dropdownvalueRecSingleAya)));
            await player.setUrl( await (QuranAudio().AyatWithApiAndRec(2,dropdownvalueRecSingleAya)));

            await player.setClip(start: Duration(seconds: 0), end: Duration(seconds: 10));


            player.play();

          },
        ),  margin: EdgeInsets.only(right: 25),) ],),


    ]
          ));
  }

  @override
  void initState() {

    GetSolmRate();
  }
  void SetPrefrenss(key,i){
    preferences.setInt(key,i);
  }

  void GetSolmRate() async{
    preferences=await SharedPreferences.getInstance();
    _EnableAzan = preferences.getInt("AzanEnabled")??1;
    _WakeUp = preferences.getInt("wakeUpAlways")??1;
    _RemmberPhrophet = preferences.getInt("ProphetPrayUpon")??1;
    _StyDileReciter = preferences.getInt("style_reciter")??1;
    _MushafDarkMode = preferences.getInt("MushafDarkMode")??1;
    ayaMark = preferences.getInt("ayaMark")??0;
    dropdownvalueRec = preferences.getInt("dropdownvalueRec")??1;
    dropdownvalue = preferences.getInt("dropdownvalueAzan")??1;
    dropdownvalueRecSingleAya = preferences.getInt("dropdownvalueRecSingleAya")??1;


    setState(() {

    });
  }
}