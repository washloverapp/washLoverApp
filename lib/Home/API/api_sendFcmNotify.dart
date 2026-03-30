import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class api_sendFcmNotify {
  static Future<bool> sendFcmNotify(String title, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      print('get-token');
      final dio = Dio();
      String path = 'https://fcm.washlover.com/api/registers';
      print(path);
      //
      // print(header);
      final resApi = await dio.get(
        path,
        // data: {'device_id': device_id},
        // options: Options(headers: header, validateStatus: (_) => true),
      );
      print('resApi.data');
      // print(resApi.data);
      // print(resApi.data['status']);
      // print(resApi.data['data']);
      print(resApi.statusCode);
      if (resApi.statusCode == 200) {
        List<dynamic> listData = resApi.data['data'] ?? [];
        print(listData);
        if (listData.isNotEmpty) {
          for (var x in listData) {
            // print(x);
            // print(x['token']);
            // print(x['customer_id']);
            print('data----------22');
            var dataJson = {
              'customer_id': x['customer_id'],
              'title': '📢 ${title}',
              'body': body,
              'project': 'driver',
            };
            String path = 'https://fcm.washlover.com/api/send-to-user';
            print(path);
            final resApi = await dio.post(
              path,
              data: dataJson,
              options: Options(validateStatus: (_) => true),
            );
            print('resApi-------send');
            print(resApi);

            print(resApi.statusCode);
            // Map<String, dynamic> res = Map<String, dynamic>();
            if (resApi.statusCode == 200) {
              return true;
            } else {
              return false;
            }
          }
        }
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
