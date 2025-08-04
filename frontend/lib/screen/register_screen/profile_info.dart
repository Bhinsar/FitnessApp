import 'package:flutter/material.dart';
import 'package:frontend/model/user.dart';
import 'package:intl/intl.dart';

import '../../utils/dimensions.dart';

class ProfileInfo extends StatefulWidget {
  final User data;
  final GlobalKey<FormState> formKey;
  const ProfileInfo({super.key, required this.data, required this.formKey});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final TextEditingController _dateController = TextEditingController();
  @override
  void initState(){
    super.initState();
    if(widget.data.profile?.dateOfBirth != null){
      print(_dateController);
      _dateController.text = DateFormat('yyyy-MM-dd').format(widget.data.profile!.dateOfBirth!);
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.data.profile?.dateOfBirth ?? DateTime.now(),
        firstDate: DateTime(1900), lastDate: DateTime.now()
    );
    if (picked != null && picked != widget.data.profile?.dateOfBirth) {
      setState(() {
        widget.data.profile?.dateOfBirth = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Center(
        child: Form(
          key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Details', style: TextStyle(fontSize: d.font24, color: Colors.white, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: "Date Of Birth",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) => value!.isEmpty ? 'Date of Birth is required.' : null,
                ),
                SizedBox(height: d.height10,),
                DropdownButtonFormField<String>(
                  value: widget.data.profile?.gender?.toLowerCase(),
                  // The 'selectedItemBuilder' gives you full control over the selected item's appearance.
                  selectedItemBuilder: (BuildContext context) {
                    return ['Male', 'Female'].map<Widget>((String item) {
                      // This is the widget that will be displayed when the dropdown is closed.
                      return Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white, // Set the color of the selected item's text
                        ),
                      );
                    }).toList();
                  },
                  decoration: const InputDecoration(
                    labelText: "Gender",
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
                  // This 'items' builder styles the options inside the dropdown menu when it's open.
                  items: ['Male', 'Female'].map((label) => DropdownMenuItem<String>(
                    value: label.toLowerCase(),
                    child: Text(
                      label,
                      // The style for the items in the list can remain black (or whatever you need).
                      style: const TextStyle(color: Colors.black),
                    ),
                  )).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      widget.data.profile?.gender = value!;
                    });
                  },
                  validator: (String? value) => value == null ? 'Gender is required.' : null,
                ),
                SizedBox(height: d.height10,),
                TextFormField(
                  initialValue: widget.data.profile?.heightCm?.toString(),
                  style: TextStyle(
                    color: Colors.white
                  ),
                  decoration: const InputDecoration(
                    labelText: "Height (cm)",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.data.profile?.heightCm = double.tryParse(value),
                  validator: (value) => value!.isEmpty ? 'Height is required.' : null,
                ),
                SizedBox(height: d.height10,),
                TextFormField(
                  initialValue: widget.data.profile?.weight?.valueKg?.toString(),
                  style: TextStyle(
                      color: Colors.white
                  ),
                  decoration: const InputDecoration(
                    labelText: "Weight (kg)",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.data.profile?.weight?.valueKg = double.tryParse(value) as double?,
                  validator: (value) => value!.isEmpty ? 'Weight is required.' : null,
                ),
              ],
            )
          )
        );
  }
}
