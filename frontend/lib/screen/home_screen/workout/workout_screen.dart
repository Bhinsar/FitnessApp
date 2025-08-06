import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/apis/workout/workout.dart';
import 'package:frontend/widgets/skeleten.dart';
import 'package:frontend/utils/Dimensions.dart';

import '../../../widgets/refresh_page.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final Workout _workout = Workout();
  String? _day;
  String? _focus;
  List<dynamic> _workoutItems = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _getWorkoutPlan();
  }

  Future<void> _getWorkoutPlan() async {
    // This function remains the same
    setState((){
      loading = true;
      error = false;
    });
    try {
      final res = await _workout.getWorkoutPlan();
      final List<dynamic> exercisesList = res['planDetails']['exercises'];
      setState(() {
        _workoutItems = exercisesList;
        _day = res['planDetails']['dayName'];
        _focus = res['planDetails']['focus'];
      });
    } catch (e) {
      print('Failed to load workout plan: $e');
      setState(() {
        error = true;
      });
    } finally {
      setState((){
        loading = false;
      });
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return '';
    }
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF434343)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: d.width10, vertical: d.height10 / 2),
                  child: Skeleten(height: d.height * 0.15, width: d.width * 0.2)
              );
            }
            ):  error
            ? RefreshPage(onRefresh: _getWorkoutPlan) :Column(
          children: [
            SizedBox(height: d.height20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: d.width20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _day ?? 'Day',
                    style: TextStyle(fontSize: d.font20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _focus ?? 'Focus',
                    style: TextStyle(fontSize: d.font20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: d.height10),
            Expanded(

              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _workoutItems.length,
                itemBuilder: (context, index) {
                  final exerciseData = _workoutItems[index] as Map<
                      String,
                      dynamic>;
                  return _buildExerciseItem(exerciseData, d);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Map<String, dynamic> exercise, Dimensions d) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: d.width20, vertical: d.height15),
      margin: EdgeInsets.symmetric(
          horizontal: d.width10, vertical: d.height10 / 2),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        // Aligns the image and the text block to the top.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GIF Container (No changes needed here)
          Container(
            width: d.width * 0.2,
            height: d.height * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black26,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder<Uint8List?>(
                future: _workout.getExerciseGif(exercise['gifUrl']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    );
                  }
                  return const Icon(
                      Icons.image_not_supported, color: Colors.grey);
                },
              ),
            ),
          ),

          // Add some space between the image and the text
          SizedBox(width: d.width15),

          // 1. Use Expanded to make the Column take up the remaining space
          Expanded(
            child: Column(
              // 2. Align all text to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(exercise['name'] as String),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: d.font16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: d.height10),
                Text(
                  "Set: ${exercise['sets']} X ${exercise['reps']}",
                  style: TextStyle(fontSize: d.font12, color: Colors.white),
                ),
                SizedBox(height: d.height10),
                Text(
                  // 3. Cleaned up the text and applied the helper function
                  "Target: ${_capitalize(exercise['targetMuscle'] as String)}",
                  maxLines: 1, // Added to prevent unwanted wrapping
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: d.font12, color: Colors.white),
                ),
                SizedBox(height: d.height10),
                Text(
                  "Equipment: ${_capitalize(exercise['equipment'] as String)}",
                  maxLines: 1, // Added to prevent unwanted wrapping
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: d.font12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}