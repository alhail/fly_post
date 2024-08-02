import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditFlightScreen extends StatefulWidget {
  final String flightKey;

  EditFlightScreen({required this.flightKey});

  @override
  _EditFlightScreenState createState() => _EditFlightScreenState();
}

class _EditFlightScreenState extends State<EditFlightScreen> {
  final TextEditingController fromCountryController = TextEditingController();
  final TextEditingController toCountryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController typeOfServiceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  late DatabaseReference flightRef;
  late String emailKey;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailKey = user!.email!.replaceAll('.', ','); // Replace '.' with ',' for Firebase keys
      flightRef = FirebaseDatabase.instance.reference().child('users').child(emailKey).child('flights').child(widget.flightKey);
      fetchFlightDetails();
    }
  }

  Future<void> fetchFlightDetails() async {
    DataSnapshot snapshot = await flightRef.once().then((DatabaseEvent event) => event.snapshot);
    if (snapshot.value != null) {
      Map<dynamic, dynamic> flightData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        fromCountryController.text = flightData['fromCountry'];
        toCountryController.text = flightData['toCountry'];
        dateController.text = flightData['date'];
        typeOfServiceController.text = flightData['typeOfService'];
        weightController.text = flightData['weight'].toString();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void saveFlight() {
    flightRef.update({
      'fromCountry': fromCountryController.text,
      'toCountry': toCountryController.text,
      'date': dateController.text,
      'typeOfService': typeOfServiceController.text,
      'weight': double.parse(weightController.text),
    }).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flight'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fromCountryController,
              decoration: InputDecoration(labelText: 'From Country'),
            ),
            TextField(
              controller: toCountryController,
              decoration: InputDecoration(labelText: 'To Country'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select Date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            TextField(
              controller: typeOfServiceController,
              decoration: InputDecoration(labelText: 'Type of Service'),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveFlight,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
