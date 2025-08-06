import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontend/apis/dio_client.dart';

class Workout{
  final Dio _dio = DioClient().dio;
  Future <Map<String, dynamic>> getWorkoutPlan() async{
    try{
      final res = await _dio.get("/aiPlan/generateAIWorkoutPlan");
      if(res.statusCode == 200 || res.statusCode == 201){
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
  Future<Uint8List?> getExerciseGif(String exerciseId) async {
    try {
      // The fix is to add Options and set the responseType to 'bytes'
      final res = await _dio.get(
        "/aiPlan/get-gif?exerciseId=$exerciseId",
        options: Options(responseType: ResponseType.bytes), // <-- THIS IS THE FIX
      );

      if (res.statusCode == 200) {
        // The data is now correctly typed as Uint8List
        return res.data;
      }
      return null;
    } catch (e) {
      print("Failed to fetch exercise GIF data: $e");
      return null;
    }
  }
}