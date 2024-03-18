import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fly_post/screens/AuthScreenLogIn.dart';
import 'package:fly_post/screens/LogInScreen.dart';
import 'package:fly_post/screens/NewScrren.dart';
import 'package:fly_post/screens/UserAccountScreen.dart';
import 'AutoService.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_authService.currentUser?.phoneNumber ?? 'Guest'),
              accountEmail: Text(_authService.currentUser != null ? 'Logged In' : 'Logged Out'),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () async {
                await _authService.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Traveler'),
              onPressed: () {
                var user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // User is logged in
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserAccountScreen()));
                } else {
                  // User is not logged in
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                }
              },
            ),
            ElevatedButton(
              child: Text('Not Traveler'),
              onPressed: () {
                // Handle the Not Traveler case
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is logged in
            if (snapshot.hasData) {
              return HomeScreen(); // User is logged in, show the home screen
            } else {
              return HomeScreen(); // User is not logged in, show the login screen
            }
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Show a loading spinner while checking the auth state
            ),
          );
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FLY-POST App',
//       theme: ThemeData(
//         // Define the default brightness and colors.
//         primaryColor: Color(0xFF6dbcfe),
//         scaffoldBackgroundColor: Color(0xFF6dbcfe),
//
//         // Define the default font family.
//         fontFamily: 'Georgia',
//
//         // Define the default TextTheme. Use this to specify the default
//         // text styling for headlines, titles, bodies of text, and more.
//         textTheme: TextTheme(
//           headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//           headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//           bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
//         ),
//       ),
//       //home: isUserLogout() ? HomeScreen() : MyNewScreen(),
//       home: MyApp_(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: NavDrawer(),
//       appBar: AppBar(
//         title: Text('FLY-POST App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               child: Text('Travelers', style: TextStyle(color: Colors.black)), // White text for buttons
//               onPressed: () {
//                 FirebaseAuth.instance
//                     .authStateChanges()
//                     .listen((User? user) {
//                   if (user == null) {
//                     // Navigate to AuthScreen
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => AuthScreenLogIn()),
//                     );
//                     print('User is currently signed out!');
//                   } else {
//                     // Navigate to AuthScreen
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => MyNewScreen()),
//                     );
//                     print('User is signed in!');
//                   }
//                 });
//               },
//             ),
//
//             SizedBox(height: 10),
//
//             ElevatedButton(
//               child: Text('Seeking Travelers', style: TextStyle(color: Colors.black)), // Black text for contrast on light buttons if needed
//               onPressed: () {
//                 // Navigate to Seeking Travelers screen
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// bool isUserLogout(){
//   bool result = false;
//   FirebaseAuth.instance
//       .authStateChanges()
//       .listen((User? user) {
//     if (user == null) {
//       result = true;
//       print("sign out!!!!!!!!!!!!!!!!!!!");
//     } else {
//       result = false;
//       print("sign in###################");
//     }
//   });
//
//   return result;
// }
//
//
// class NavDrawer extends StatelessWidget {
//
//   String logInfo = "log out";
//
//   @override
//   Widget build(BuildContext context) {
//
//     isUserLogout();
//
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           const DrawerHeader(
//             decoration: BoxDecoration(
//                 color: Color(0xFF6dbcfe),
//                 // image: DecorationImage(
//                 //     fit: BoxFit.fill,
//                 //     image: AssetImage('assets/images/cover.jpg'))
//             ),
//             child: Text(
//               'Side menu',
//               style: TextStyle(color: Colors.white, fontSize: 25),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.input),
//             title: Text('Welcome'),
//             onTap: () => {},
//           ),
//           ListTile(
//             leading: Icon(Icons.verified_user),
//             title: Text('Profile'),
//             onTap: () => {Navigator.of(context).pop()},
//           ),
//           ListTile(
//             leading: Icon(Icons.settings),
//             title: Text('Settings'),
//             onTap: () => {Navigator.of(context).pop()},
//           ),
//           ListTile(
//             leading: Icon(Icons.border_color),
//             title: Text('Feedback'),
//             onTap: () => {Navigator.of(context).pop()},
//           ),
//           ListTile(
//             leading: Icon(Icons.exit_to_app),
//             title: Text(logInfo),
//             onTap: () async  {
//               await FirebaseAuth.instance.signOut();
//              logInfo = "Log In";
//               Navigator.of(context).pop();
//               // Navigate to AuthScreen
//               // Navigator.of(context).push(
//               //   MaterialPageRoute(builder: (context) => HomeScreen()),
//               // );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }