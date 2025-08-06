import 'package:dio/dio.dart';

import '../dio_client.dart';

class Meal{
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getMealPlan() async{
    try{
      final res = await _dio.get("/aiPlan/generateAIMealPlan");
      if(res.statusCode == 200 || res.statusCode == 201 ){
        final resData = res.data['plan'];
        return resData;
      }else{
        throw Exception("Something went wrong please try again");
      }
    }catch(e){
      print(e);
      rethrow;
    }
  }

}