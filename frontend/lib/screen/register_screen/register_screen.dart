import 'package:flutter/material.dart';
import 'package:frontend/apis/auth/auth.dart';
import 'package:frontend/model/user.dart';
import 'package:frontend/screen/register_screen/profile_info.dart';
import 'package:frontend/utils/dimensions.dart';
import 'package:frontend/widgets/snackbar_utils.dart';
import 'package:go_router/go_router.dart';
import '../home_screen/home_screen.dart';
import 'account_info.dart';
import 'fitness_info.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final PageController _pageController = PageController();

  final User _data = User();

  int _currentPage = 0;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  late final List<Widget> _pages;

  final Auth _authService = Auth();

  bool _isRegistering = false;

  @override
  @override
  void initState() {
    super.initState();
    //initialize profile
    _data.profile = Profile(
      dateOfBirth: DateTime.now(),
      gender: 'male',
      weight: WeightEntry(date: DateTime.now()),
    );

    // Now, initialize your pages list.
    _pages = [
      // FitnessInfo now receives a user with a guaranteed non-null profile.
      AccountInfo(data: _data, formKey: _formKeys[0]),
      ProfileInfo(data: _data, formKey: _formKeys[1]),
      FitnessInfo(data: _data, formKey: _formKeys[2]),
    ];
  }
  // Function to navigate to the next page.
  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        // This is the final step, where you would submit the data.
        _submitForm();
      }
    }
  }

  Future<void> _submitForm() async {
    try {
      print("register user: ${_data.toString()}");
      setState(() {
        _isRegistering = true;
      });
      await _authService.registerUser(_data);
      // On Success, show snackbar and navigate to HomeScreen
      SnackbarUtils.showSuccess(context, 'Register Successful!');

      // Use pushReplacement to prevent the user from going back to the login screen
      context.go("/home");
    }catch(e){
      SnackbarUtils.showError(context, e.toString());
    }finally{
    setState(() {
      _isRegistering = false;
    });
  }
  }

  // Function to navigate to the previous page.
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to your desired color
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: d.width45, vertical: d.height30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step ${(_currentPage+1)} of ${_pages.length}",
              style: TextStyle(
                color: Colors.white,
                fontSize: d.font10
              ),
            ),
            SizedBox(height: d.height10 /2,),
            LinearProgressIndicator(
              value: (_currentPage +1) / _pages.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA34BFA)!),
            ),
            SizedBox(height: d.height15),
            Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page){
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  physics: NeverScrollableScrollPhysics(),
                  children: _pages,
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _previousPage,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                _isRegistering ?
                SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)):
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage < _pages.length - 1 ? 'Next' : 'Register'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}