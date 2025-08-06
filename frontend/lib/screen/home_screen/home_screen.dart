import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/apis/auth/auth.dart'; // Your auth service
import 'package:frontend/screen/home_screen/meal/meal_screen.dart';
import 'package:frontend/screen/home_screen/workout/workout_screen.dart';
import 'package:frontend/widgets/snackbar_utils.dart';
import 'package:go_router/go_router.dart';
import '../../utils/Dimensions.dart';
import '../login_screen/login_screen.dart'; // Your login screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Auth authService = Auth();
  // The list of screens to switch between
  final List<Widget> _screens = [
    const WorkoutScreen(),
    const MealScreen(),
  ];

  // Controller to manage the PageView animation and state
  late PageController _pageController;
  // Index to track the selected tab
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the PageController
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the tree
    _pageController.dispose();
    super.dispose();
  }

  /// Handles user logout.
  Future<void> _logout() async {
    try {
      await authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, e.toString());
      }
    }
  }

  /// Function to handle tab selection.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    // Define text styles for active and inactive tabs for clarity
    final activeTextStyle = TextStyle(color: Colors.white, fontSize: d.font18, fontWeight: FontWeight.bold);
    final inactiveTextStyle = TextStyle(color: Colors.grey[600], fontSize: d.font18, fontWeight: FontWeight.normal);

    return Scaffold(
      appBar: AppBar(

        title: Text(
          "AI Fit",
          style: TextStyle(fontSize: d.font24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, size: d.font20, color: Colors.white),
            tooltip: "Logout",
            onPressed: _logout,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: d.height10),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tab for "Workout Plan"
                _buildTabItem("Workout Plan", 0, d, activeTextStyle, inactiveTextStyle),
                // Tab for "Meal Plan"
                _buildTabItem("Meal Plan", 1, d, activeTextStyle, inactiveTextStyle),
              ],
            ),
          ),
          // The PageView which displays the content and handles swiping
          Expanded(
            child: PageView(
              controller: _pageController,
              // The list of screens
              children: _screens,
              // This callback is fired when the user swipes between pages
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  /// Helper widget to build a single tab item to avoid code repetition.
  Widget _buildTabItem(String title, int index, Dimensions d, TextStyle activeStyle, TextStyle inactiveStyle) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: EdgeInsets.only(bottom: d.height10/2),
          // Add a bottom border to the selected tab
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            // Apply active or inactive style based on selection
            style: isSelected ? activeStyle : inactiveStyle,
          ),
        ),
      ),
    );
  }
}