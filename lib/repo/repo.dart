import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RepoHttpSer {
  Future<String> getfullSurah(String number) async {
    var url = Uri.parse(
        "http://api.alquran.cloud/v1/surah/" + number + "/ar.alafasy");
    var response = await http.get(url);
    return response.body;
  }

  Future<String> getfullSurahEthman(String number) async {
    var url = Uri.parse("http://api.alquran.cloud/v1/surah/" +
        number +
        "/editions/quran-uthmani,en.asad,en.pickthall");
    var response = await http.get(url);
    return response.body;
  }

  Future<String> getafasyByPage(String number) async {
    var url =
        Uri.parse("http://api.alquran.cloud/v1/page/" + number + "/ar.alafasy");
    var response = await http.get(url);
    return response.body;
  }

  Future<String> getTranslatePage(String number) async {
    var url =
        Uri.parse("http://api.alquran.cloud/v1/page/" + number + "/en.asad");
    var response = await http.get(url);
    return response.body;
  }

  Future<String> Surah() async {
    var url = Uri.parse("http://api.alquran.cloud/v1/surah");
    var response = await http.get(url);
    return response.body;
  }

  Future<String> prayTime() async {
    String country = "";
    String city = "";

    try {
      var value = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 2));
      if (value.statusCode == 200) {
        if (json.decode(value.body)['status'] == "success") {
          country = (json.decode(value.body)['countryCode'].toString());
          city = (json.decode(value.body)['city'].toString());
        } else {
          final response =
              await http.get(Uri.parse('https://api.ipregistry.co?key=tryout'));

          if (response.statusCode == 200) {
            country =
                (json.decode(response.body)['location']['country']['code']);
            city = (json.decode(response.body)['location']['city']);
          } else {
            throw Exception('Failed to get user country from IP address');
          }
        }
      } else {
        final response =
            await http.get(Uri.parse('https://api.ipregistry.co?key=tryout'));

        if (response.statusCode == 200) {
          country = (json.decode(response.body)['location']['country']['code']);
          city = (json.decode(response.body)['location']['city']);
        } else {
          throw Exception('Failed to get user country from IP address');
        }
      }
    } catch (err) {
      final response =
          await http.get(Uri.parse('https://api.ipregistry.co?key=tryout'));

      if (response.statusCode == 200) {
        country = (json.decode(response.body)['location']['country']['code']);
        city = (json.decode(response.body)['location']['city']);
      } else {
        throw Exception('Failed to get user country from IP address');
      }
    }
    log(country!);
    log(city!);
    var url = Uri.parse(
        "https://api.aladhan.com/v1/timingsByCity?country=$country&city=$city");

    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-Rapidapi-Host": "aladhan.p.rapidapi.com",
      "X-Rapidapi-Key": "2e7ed01f33mshd3523acc83bc089p170919jsncb595014f4a8"
    });
    log(response.body);
    return response.body;
  }
}
