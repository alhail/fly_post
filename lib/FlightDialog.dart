import 'package:flutter/material.dart';

import 'Flight.dart';


class FlightDialog extends StatefulWidget {
  final Function(Flight) onSubmit;

  const FlightDialog({super.key, required this.onSubmit});

  @override
  _FlightDialogState createState() => _FlightDialogState();
}

class _FlightDialogState extends State<FlightDialog> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _offersController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();

  // Add more controllers for each field

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Flight"),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(controller: _placeController, decoration: const InputDecoration(hintText: "Place")),
            // Add more TextFields for each flight detail
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            // Collect data from fields and create a Flight object
            // Assume Flight is a model class for your flight details
            final flight = Flight(
              place: _placeController.text,
              fromTo: _fromController.text,
              date: _dateController.text,
              offers: _offersController.text,
              language: _languageController.text,
              money: _moneyController.text

              // Initialize other fields
            );
            widget.onSubmit(flight);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
