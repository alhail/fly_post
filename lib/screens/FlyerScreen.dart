import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoggedInFlyerScreen.dart';
import 'NotLoggedInFlyerScreen.dart';

class FlyerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      user.reload();  // Ensure the user data is updated
      if (user.emailVerified) {
        return LoggedInFlyerScreen();
      } else {
        return NotLoggedInFlyerScreen();
      }
    } else {
      return NotLoggedInFlyerScreen();
    }
  }
}
