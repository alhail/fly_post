import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../AutoService.dart';
import '../FlightDialog.dart';
import '../Flight.dart';
import '../main.dart';
import 'LogInScreen.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final AuthService _authService = AuthService();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Flight> flights = []; // Your Flight model class

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  _loadFlights() {
    // Assuming your database structure, adjust as necessary
    _dbRef.child('users/${FirebaseAuth.instance.currentUser!.phoneNumber}/flights').onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        flights = data.entries.map((e) => Flight.fromJson(Map<String, dynamic>.from(e.value))).toList();
      });
    });
  }

  // void saveFlight(String from, String to, String date, String offers,
  //     String language, String money) {
  //   final User? user = auth.currentUser;
  //   final uid = user?.phoneNumber;
  //
  //   if (uid != null) {
  //     databaseRef.child('users').child(uid).child('flights').push().set({
  //       'place': from,
  //       'from': to,
  //       'date': date,
  //       'offers': offers,
  //       'language': language,
  //       'money': money,
  //     });
  //   }
  // }

  void showAddFlightDialog() {
    // Your TextFields controllers
    TextEditingController fromController = TextEditingController();
    TextEditingController toController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController offersController = TextEditingController();
    TextEditingController languageController = TextEditingController();
    TextEditingController moneyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Flight"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: fromController,
                    decoration: const InputDecoration(hintText: "From")),
                TextField(
                    controller: toController,
                    decoration: const InputDecoration(hintText: "To")),
                TextField(
                    controller: dateController,
                    decoration: const InputDecoration(hintText: "Date")),
                TextField(
                    controller: offersController,
                    decoration: const InputDecoration(hintText: "Offers")),
                TextField(
                    controller: languageController,
                    decoration: const InputDecoration(hintText: "Language")),
                TextField(
                    controller: moneyController,
                    decoration: const InputDecoration(hintText: "Money")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                // saveFlight(
                //     fromController.text,
                //     toController.text,
                //     dateController.text,
                //     offersController.text,
                //     languageController.text,
                //     moneyController.text);
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
        title: const Text('User Account'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  Text(_authService.currentUser?.phoneNumber ?? 'No Name'),
              accountEmail: Text(_authService.currentUser != null
                  ? 'Logged In'
                  : 'Not Logged In'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  _authService.currentUser != null ? 'L' : 'N',
                  style: const TextStyle(fontSize: 24.0),
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
              title: const Text('Log Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                await _authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: flights.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(flights[index].fromTo), // Customize based on your Flight model
            // Add more details as required
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Left side
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFlightDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  _showAddFlightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FlightDialog(onSubmit: (Flight flight) {
          _addFlight(flight);
        });
      },
    );
  }

  _addFlight(Flight flight) {
    final phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber; // Ensure user is logged in
    final id = _dbRef.child('users/$phoneNumber/flights').push().key; // Unique key for the flight
    _dbRef.child('users/$phoneNumber/flights/$id').set(flight.toJson()).then((_) {
      print("Flight added to the database");
      // Optionally, close the dialog or show a confirmation message
    }).catchError((error) {
      print("Failed to add flight: $error");
      // Handle errors, e.g., show an error dialog
    });
  }
}
