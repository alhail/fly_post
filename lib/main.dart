import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fly_post/screens/LogInScreen.dart';
import 'package:fly_post/screens/MainScreen.dart';
import 'package:fly_post/screens/UserAccountScreen.dart';
import 'AutoService.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //       apiKey: "apiKey",
  //       appId: "appId",
  //       messagingSenderId: "messagingSenderId",
  //       projectId: "projectId",
  //     ),
  //   );
  // } on FirebaseException catch (e) {
  //   if (e.code == 'duplicate-app') {
  //     await Firebase.initializeApp();
  //   }
  // }
  runApp(const MyApp());
}

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_authService.currentUser?.phoneNumber ?? 'Guest'),
              accountEmail: Text(_authService.currentUser != null ? 'Logged In' : 'Logged Out'),
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
              title: const Text('Log Out'),
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
              child: const Text('Traveler'),
              onPressed: () {
                var user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // User is logged in
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAccountScreen()));
                } else {
                  // User is not logged in
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                }
              },
            ),
            ElevatedButton(
              child: const Text('Not Traveler'),
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

// class MyApp extends StatelessWidget {
//   final AuthService _authService = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Auth Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StreamBuilder(
//         stream: _authService.authStateChanges,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.active) {
//             // Check if the user is logged in
//             if (snapshot.hasData) {
//               return HomeScreen(); // User is logged in, show the home screen
//             } else {
//               return HomeScreen(); // User is not logged in, show the login screen
//             }
//           }
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(), // Show a loading spinner while checking the auth state
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),//MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TravelerPage()),
                );
              },
              child: const Text('Traveler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle FlyPost button action
              },
              child: const Text('FlyPost'),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelerPage extends StatelessWidget {
  const TravelerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Traveler',
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              return const FlightsPage();
            } else {
              return AuthPage();
            }
          },
        ),
      ),
    );
  }
}

class AuthPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login / Register',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FlightsPage()),
                  );
                } catch (e) {
                  // Handle sign in error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FlightsPage()),
                  );
                } catch (e) {
                  // Handle registration error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: $e')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final DatabaseReference databaseReference =
  FirebaseDatabase.instance.reference().child('flights');
  final TextEditingController flightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'My Flights',
      body: Column(
        children: [
          Expanded(
            child: FirebaseAnimatedList(
              query: databaseReference,
              itemBuilder: (context, snapshot, animation, index) {
                final data = snapshot.value as Map<dynamic, dynamic>?;
                final flight = data != null ? data['flight'] as String? ?? 'No Flight' : 'No Flight';
                return ListTile(
                  title: Text(flight),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: flightController,
                    decoration: const InputDecoration(labelText: 'New Flight'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String flight = flightController.text;
                    databaseReference.push().set({'flight': flight});
                    flightController.clear();
                  },
                  child: const Text('Add Flight'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;

  const BasePage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const UserDrawer(),
      body: body,
    );
  }
}

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Not Logged In'),
                ),
                ListTile(
                  title: const Text('Login/Register'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthPage()),
                    );
                  },
                ),
              ],
            );
          } else {
            final user = snapshot.data!;
            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user.displayName ?? 'No display name'),
                  accountEmail: Text(user.email ?? 'No email'),
                  currentAccountPicture: CircleAvatar(
                    child: Text(user.displayName?.substring(0, 1) ?? 'A'),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage()),
                    );
                  },
                ),
              ],
            );
          }
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