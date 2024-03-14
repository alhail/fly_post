import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly_post/screens/NewScrren.dart';
import '../AutoService.dart';
import 'UserAccountScreen.dart';

class LoginScreen extends StatefulWidget {
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
          title: Text("Verification Error"),
          content: Text("The verification code entered is incorrect. Please try again."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
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
        title: Text('Login'),
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
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              title: Text('Close'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
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
            SizedBox(height: 16.0),
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
              child: Text('Send Verification Code'),
            ),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signInWithPhoneNumber(
                    _smsController.text,
                    _verificationId,
                  );
                  // Navigate to User Account Screen on success
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserAccountScreen()),
                  );
                } catch (e) {
                  // If verification fails, show error dialog
                  _showVerificationErrorDialog();
                }
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}