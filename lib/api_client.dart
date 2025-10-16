import 'dart:convert';

import 'package:crud_api_sample/main.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  late String apiUrl;

  ApiClient(this.apiUrl) {
    _init();
  }

  void _init() async {
    print("ApiClient terinisialisasi");
  }

  Future<void> createItem(Map<String, String> requests) async {
    try {
      var postUri = Uri.parse("$apiUrl/create");
      var request = http.MultipartRequest("POST", postUri);

      requests.forEach((key, value) {
        request.fields[key] = value;
      });

      await request.send();
    } catch (e) {
      //
    }
  }

  Future<void> updateItem(Map<String, String> requests, String key) async {
    try {
      var postUri = Uri.parse("$apiUrl/update/$key");
      var request = http.MultipartRequest("POST", postUri);

      requests.forEach((key, value) {
        request.fields[key] = value;
      });
      
      await request.send();
    } catch (e) {
      //
    }
  }

  Future<String?> getItem(String key) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get/$key"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body[0]['data'];
      } else {
        return null;
      }
    } catch (e) {
      //
    }
    return null;
  }

  Future<List<Data>?> getAll() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get"));

      if (response.statusCode == 200) {
        List<Data> returnData = <Data>[];
        List<dynamic> body = await jsonDecode(response.body);
        for (var value in body) {
          var data = Data(value['id'].toString(), value['nama'].toString());
          returnData.add(data);
        }
        return returnData;
      } else {
        return null;
      }
    } catch (e) {
      //
    }
    return null;
  }

  Future<void> deleteItem(String key) async {
    try {
      var postUri = Uri.parse("$apiUrl/delete/$key");
      var request = http.MultipartRequest("DELETE", postUri);

      await request.send();
    } catch (e) {
      //
    }
  }
}
