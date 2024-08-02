import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'AddFlightScreen.dart';
import 'LogInScreen.dart';
import 'MainScreen.dart';

class LoggedInFlyerScreen extends StatefulWidget {
  @override
  _LoggedInFlyerScreenState createState() => _LoggedInFlyerScreenState();
}

class _LoggedInFlyerScreenState extends State<LoggedInFlyerScreen> {
  late DatabaseReference flightsRef;
  late String emailKey;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailKey = user!.email!.replaceAll('.', ','); // Replace '.' with ',' for Firebase keys
      flightsRef = FirebaseDatabase.instance.reference().child('users').child(emailKey).child('flights');
    }
  }

  void deleteFlight(String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this flight?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (user != null) {
                  flightsRef.child(key).remove();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void editFlight(String key) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFlightScreen(flightKey: key)),
    );
  }

  void activateFlight(String key) {
    if (user != null) {
      flightsRef.child(key).update({'active': true});
    }
  }

  void deactivateFlight(String key) {
    if (user != null) {
      flightsRef.child(key).update({'active': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlyPost'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Flyer: ${user!.email}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Flights',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFlightScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: flightsRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> flightsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> flightsList = flightsMap.entries.map((entry) {
                    Map<dynamic, dynamic> flight = entry.value;
                    flight['key'] = entry.key;
                    return flight;
                  }).toList();

                  return ListView.builder(
                    itemCount: flightsList.length,
                    itemBuilder: (context, index) {
                      Map<dynamic, dynamic> flight = flightsList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From: ${flight['fromCountry']}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'To: ${flight['toCountry']}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'On: ${flight['date']}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String result) {
                                      switch (result) {
                                        case 'delete':
                                          deleteFlight(flight['key']);
                                          break;
                                        case 'edit':
                                          editFlight(flight['key']);
                                          break;
                                        case 'activate':
                                          activateFlight(flight['key']);
                                          break;
                                        case 'deactivate':
                                          deactivateFlight(flight['key']);
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete),
                                          title: Text('Delete Flight'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit Flight'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'activate',
                                        child: ListTile(
                                          leading: Icon(Icons.check_circle),
                                          title: Text('Activate Flight'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'deactivate',
                                        child: ListTile(
                                          leading: Icon(Icons.cancel),
                                          title: Text('Deactivate Flight'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text('Service Type: ${flight['typeOfService']}'),
                              Text('Weight: ${flight['weight']} kg'),
                              Text('Status: ${flight['active'] ? "Active" : "Inactive"}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('No flights available'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'FlyPost',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Flight'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFlightScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
