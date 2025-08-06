import 'package:flutter/material.dart';
import '../utils/Dimensions.dart';

class RefreshPage extends StatelessWidget {
  final VoidCallback onRefresh;
  const RefreshPage({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Center(
      child: Column(
        children: [
          SizedBox(height: d.height *0.3,),
          Text("Something went error please try again", style: TextStyle(fontSize: d.font16, color: Colors.white),),
          SizedBox(height: d.height15,),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: d.width * 0.1),
            elevation: 5,
            shadowColor: Colors.white,
          ),child: Text("Refresh Page", )
          )
        ],
      ),
    );
  }
}
