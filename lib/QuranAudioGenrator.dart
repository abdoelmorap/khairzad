
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class QuranAudio {


  String AyaUrlGenrator(List<int> codelist) {

    var ayaNum = codelist[0].toString();
    if (ayaNum.length==1){
      ayaNum="00"+ayaNum;
    }else  if (ayaNum.length==2)
      ayaNum="0"+ayaNum;
    var SuraNum = codelist[1].toString();
    if (SuraNum.length==1){
      SuraNum="00"+SuraNum;
    }else  if (SuraNum.length==2)
      SuraNum="0"+SuraNum;
    print('IDSURA$SuraNum$ayaNum');
    return '$SuraNum$ayaNum';}

  String AyatUrlMaker(List<int> codelist,int Type,int recId) {

return '';



  }
Future<String> AyatWithApiAndRec(AyaId,recId) async{

  var url = Uri.parse("https://api.quran.com/api/v4/recitations/$recId/by_ayah/$AyaId");
  var response = await http.get(url);
 if(recId!.toString()! !="12"){
   return    "https://verses.quran.com/"+json.decode(response.body)['audio_files'][0]['url'].toString();
}else{
   print(json.decode(response.body)['audio_files'][0]['url'].toString());
return "https:"+json.decode(response.body)['audio_files'][0]['url'].toString();
  }
}
Future<List<String>> AyatWithApi(PageID) async{
  SharedPreferences preferences= await SharedPreferences.getInstance();

  var recId=    await preferences.getInt("dropdownvalueRec")??1;

var url = Uri.parse("https://api.quran.com/api/v4/recitations/$recId/by_page/$PageID");
    var response = await http.get(url);
    List<String> Urls=[];
    if(recId!.toString()! !="12"){
      for(var e in json.decode(response.body)['audio_files']){
        Urls.add("https://verses.quran.com/"+e['url'].toString());
      }
      return  Urls  ;
    }else{
      for(var e in json.decode(response.body)['audio_files']){
        Urls.add("https:"+e['url'].toString());
      }
      return  Urls  ;

    }
  }
  Future<String> AyatWithApiSingle(AyaId) async{
    SharedPreferences preferences= await SharedPreferences.getInstance();

    var recId=    await preferences.getInt("dropdownvalueRecSingleAya")??12;

    var url = Uri.parse("https://api.quran.com/api/v4/recitations/$recId/by_ayah/$AyaId");
    var response = await http.get(url);
    if(recId!.toString()! !="12"){
      return    "https://verses.quran.com/"+json.decode(response.body)['audio_files'][0]['url'].toString();
    }else{
      print(json.decode(response.body)['audio_files'][0]['url'].toString());
      return "https:"+json.decode(response.body)['audio_files'][0]['url'].toString();
    }
  }


}