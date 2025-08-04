import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../apis/auth/auth.dart';
import '../../utils/dimensions.dart';
import '../../widgets/snackbar_utils.dart';
import '../home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _isLoading = false;
  final Auth _authService = Auth();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose(); 
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // The login service now returns tokens, though we don't need them here
      await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // On Success, show snackbar and navigate to HomeScreen
      SnackbarUtils.showSuccess(context, 'Login Successful!');

      // Use pushReplacement to prevent the user from going back to the login screen
      context.go("/home");

    } catch (e) {
      SnackbarUtils.showError(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // Use a SingleChildScrollView to prevent overflow when the keyboard appears
        child: SingleChildScrollView(
          // 1. Wrap your input fields in a Form widget
          child: Form(
            key: _formKey, // 2. Assign the GlobalKey to the Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/splash-image.png',
                  width: width * 0.5,
                  height: height * 0.3,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: d.height20),
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: d.font24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: d.height20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      // 3. Change TextField to TextFormField
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        // The validator property now works correctly
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: d.height10),
                      // 4. Change TextField to TextFormField here as well
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          // A cleaner way to add the visibility icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: d.height20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.32),
                    elevation: 5, // Shadow effect
                    shadowColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Submit'),
                ),
                SizedBox(height: d.height15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Haven't any account?",
                      style: TextStyle(
                        fontSize: d.font12,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(width: 2,),
                    InkWell(
                      onTap: () {
                        context.go('/register');
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: d.font12,
                          color: Colors.blue, // Changed color to indicate it's a link
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

