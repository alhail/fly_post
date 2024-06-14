import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly_post/main.dart';
import '../AutoService.dart';
import 'UserAccountScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String _verificationId = '';


  void _showVerificationErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verification Error"),
          content: const Text("The verification code entered is incorrect. Please try again."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_authService.currentUser?.phoneNumber ?? 'Guest'),
              accountEmail: Text(_authService.currentUser != null ? 'Logged In' : 'Not Logged In'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _authService.currentUser != null ? 'L' : 'N',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).push(
                       MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Close'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefix: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('+'),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _authService.verifyPhoneNumber(
                  '+${_phoneNumberController.text}',
                      (verificationId) {
                    _verificationId = verificationId;
                    // Optionally prompt user to enter the code, depending on your app flow
                  },
                );
              },
              child: const Text('Send Verification Code'),
            ),
            TextField(
              controller: _smsController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signInWithPhoneNumber(
                    _smsController.text,
                    _verificationId,
                  );
                  var user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // User is logged in
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAccountScreen()));
                  } else {
                    // User is not logged in
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                } on FirebaseAuthException catch (e) {
                  print("is the verfication code is invalid*****");
                  if (e.code == 'invalid-verification-code') {
                    print("is the verfication code is invalid*****");
                    _showVerificationErrorDialog();
                  } else {
                    // Handle other Firebase Auth errors or show a generic error dialog
                  }
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}