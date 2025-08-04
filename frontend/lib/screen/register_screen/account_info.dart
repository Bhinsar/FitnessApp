import 'package:flutter/material.dart';
import 'package:frontend/utils/dimensions.dart';
import '../../model/user.dart';

class AccountInfo extends StatefulWidget {
  final User data;
  final GlobalKey<FormState> formKey;
  const AccountInfo({super.key, required this.data, required this.formKey});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  bool isPasswordVisible = false;
  bool _passwordMatch = true;
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _confirmPassword.dispose();
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
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: d.font24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: d.height10/2),
            TextFormField(
              initialValue: widget.data.name,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),

              ),
              onChanged: (String? value) {
                setState(() {
                  widget.data.name = value!;
                });
              },
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: d.height10),
            TextFormField(
              initialValue: widget.data.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (String? value) {
                setState(() {
                  widget.data.email = value!;
                });
              },
            ),
            SizedBox(height: d.height10),
            TextFormField(
              initialValue: widget.data.password,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
              onChanged: (String? value) {
                setState(() {
                  widget.data.password = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: d.height10),
            TextFormField(
              controller: _confirmPassword,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
              onChanged: (value) {
                setState(() {
                  _passwordMatch = value == widget.data.password;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                }
                if (value != widget.data.password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: isPasswordVisible,
                  onChanged: (value) {
                    setState(() {
                      isPasswordVisible = value ?? false;
                    });
                  },
                ),
                Text(
                  "Show Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: d.font12,
                  ),
                ),
              ],
            ),
            if (!_passwordMatch)
              Text(
                "Your Password and Confirm Password don't match",
                style: TextStyle(
                  fontSize: d.font12,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}