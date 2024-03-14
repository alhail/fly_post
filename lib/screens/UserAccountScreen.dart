import 'package:flutter/material.dart';

import '../AutoService.dart';
import 'LogInScreen.dart';


class UserAccountScreen extends StatefulWidget {
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('User Account'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user?.phoneNumber ?? 'No Name'),
              accountEmail: Text('Logged In'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user != null ? 'L' : 'N',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () async {
                await _authService.signOut();
                // Navigate back to login screen upon logout
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('User Account Page', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}