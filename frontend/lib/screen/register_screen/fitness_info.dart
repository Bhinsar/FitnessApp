import 'package:flutter/material.dart';
import 'package:frontend/model/user.dart';
import 'package:frontend/utils/dimensions.dart';

class FitnessInfo extends StatefulWidget {
  final User data;
  final GlobalKey<FormState> formKey;
  const FitnessInfo({super.key, required this.data, required this.formKey});

  @override
  State<FitnessInfo> createState() => _FitnessInfoState();
}

class _FitnessInfoState extends State<FitnessInfo> {

  final List<String> _allGoals = [
    'lose_weight',
    'build_muscle',
    'improve_stamina',
    'maintain_fitness',
    'learn_exercises'
  ];

  final List<String> _allEquipment = [
    'Dumbbells',
    'Barbell',
    'Kettlebell',
    'Resistance Bands',
    'Treadmill',
    'Stationary Bike',
    'Yoga Mat'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fitness Profile', style: TextStyle(fontSize: Dimensions.font24, color: Colors.white,fontWeight: FontWeight.bold)),
                SizedBox(height: Dimensions.height10,),
                DropdownButtonFormField<String>(
                  value: widget.data.profile?.mealType.toLowerCase(),
                  selectedItemBuilder: (BuildContext context) {
                    return ['Vegetarian', 'Non-Vegetarian', 'Vegan'].map<Widget>((String item) {
                      return Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    }).toList();
                  },
                  decoration: const InputDecoration(
                    labelText: "Meal Type",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.black,

                  ),
                  items: ['Vegetarian', 'Non-Vegetarian', 'Vegan'].map((label) => DropdownMenuItem<String>(
                    value: label.toLowerCase(),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.black),
                    ),
                  )).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      // Safer way to handle the update
                      if (value != null) {
                        widget.data.profile?.mealType = value;
                      }
                    });
                  },
                  validator: (String? value) => value == null ? 'Meal Type is required.' : null,
                ),
                SizedBox(height: Dimensions.height10,),
                DropdownButtonFormField<String>(
                  value: widget.data.profile?.activityLevel.toLowerCase().replaceAll(" ", "_"),
                  selectedItemBuilder: (BuildContext context) {
                    return ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'].map<Widget>((String item) {
                      return Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    }).toList();
                  },
                  decoration: const InputDecoration(
                    labelText: "Activity Level",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                  items: ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'].map((label) => DropdownMenuItem<String>(
                    value: label.toLowerCase().replaceAll(" ", "_"),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.black),
                    ),
                  )).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        widget.data.profile?.activityLevel = value;
                      }
                    });
                  },
                  validator: (String? value) => value == null ? 'Activity Level is required.' : null,
                ),
                SizedBox(height: Dimensions.height10,),
                Text(
                  "Your Fitness Goal",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: Dimensions.height10,),
                ..._allGoals.map((goal) => CheckboxListTile(
                  title: Text(goal.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: Colors.white),),
                  value: widget.data.profile?.goals.contains(goal)?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        // Now this will work because profile is guaranteed to be non-null
                        widget.data.profile!.goals.add(goal);
                      } else {
                        widget.data.profile!.goals.remove(goal);
                      }
                    });
                  },
                )),
                SizedBox(height: Dimensions.height10,),
                Text(
                  "Available Equipment",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: Dimensions.height10,),
                ..._allEquipment.map((equipment) => CheckboxListTile(
                  title: Text(equipment.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: Colors.white),),
                  value: widget.data.profile?.availableEquipment.contains(equipment) ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        widget.data.profile!.availableEquipment.add(equipment);
                      } else {
                        widget.data.profile!.availableEquipment.remove(equipment);
                      }
                    });
                  },
                )),
              ],
            )
        )
    );
  }
}
