import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/apis/meal/meal.dart';

import '../../../utils/Dimensions.dart';
import '../../../widgets/refresh_page.dart';
import '../../../widgets/skeleten.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final Meal _meal = Meal();
  List<dynamic> _mealPlan = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _getMealPlan();
  }

  Future<void> _getMealPlan() async {
    // This function remains the same
    setState((){
      loading = true;
      error = false;
    });
    try {
      final res = await _meal.getMealPlan();
      final List<dynamic> mealList = res['planDetails']['meals'];
      setState(() {
        _mealPlan = mealList;
      });
    } catch (e) {
      print('Failed to load meal plan: $e');
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
            ? RefreshPage(onRefresh: _getMealPlan) :Column(
          children: [
            SizedBox(height: d.height20),
            Expanded(

              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _mealPlan.length,
                itemBuilder: (context, index) {
                  final exerciseData = _mealPlan[index] as Map<
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

  Widget _buildExerciseItem(Map<String, dynamic> meal, Dimensions d) {
    return Container(
      // This container provides the margin and outer decoration for the card
      margin: EdgeInsets.symmetric(
        horizontal: d.width10,
        vertical: d.height10 / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      // Use ClipRRect to ensure the Stack's children respect the rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: d.width20, vertical: d.height15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  CachedNetworkImage(
                    imageUrl: meal['imageUrl'],
                    width: d.width * 0.2,
                    height: d.height * 0.1,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                  SizedBox(width: d.width15),

                  // Description
                  // It's expanded to fill the remaining space
                  Expanded(
                    child: Padding(
                      // We add top padding to push the description down,
                      // leaving an empty space for the 'name' to be overlaid.
                      padding: EdgeInsets.only(top: d.height30),
                      child: Text(
                        _capitalize(meal['description'] as String),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: d.font16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: d.height15,
              right: d.width20,
              child: Text(
                _capitalize(meal['name'] as String),
                style: TextStyle(
                  fontSize: d.font16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
