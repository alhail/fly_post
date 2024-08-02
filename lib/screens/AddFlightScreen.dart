import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Hinzugefügt
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'LogInScreen.dart';
import 'MainScreen.dart';

class AddFlightScreen extends StatefulWidget {
  final String? flightKey;

  AddFlightScreen({this.flightKey});

  @override
  _AddFlightScreenState createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? selectedFromCountry;
  String? selectedFromCity;
  String? selectedToCountry;
  String? selectedToCity;
  String? selectedServiceType;
  String? selectedWeightUnit;
  File? ticketFile;

  List<String> countries = [];
  Map<String, String> countryCodes = {};
  Map<String, List<String>> cities = {};
  List<String> serviceTypes = [];
  List<String> weightUnits = ['g', 'kg'];

  @override
  void initState() {
    super.initState();
    fetchServiceTypes();
    fetchCountries();
    if (widget.flightKey != null) {
      loadFlightDetails();
    }
  }

  Future<void> fetchServiceTypes() async {
    DatabaseReference serviceTypesRef = FirebaseDatabase.instance.reference().child('serviceTypes');
    DatabaseEvent event = await serviceTypesRef.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic> serviceTypesData = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      serviceTypes = serviceTypesData.keys.cast<String>().toList();
    });
  }

  Future<void> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10'),
      headers: {
        'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
        'x-rapidapi-key': 'd749bea547mshebac7e5dfc95922p1f33bdjsn461cad796f20', // Fügen Sie hier Ihren RapidAPI-Schlüssel ein
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<String> countryList = [];
      Map<String, String> countryCodeMap = {};

      for (var country in data['data']) {
        String countryName = country['name'];
        String countryCode = country['code'];
        countryList.add(countryName);
        countryCodeMap[countryName] = countryCode;
      }

      countryList.sort(); // Sort countries alphabetically

      setState(() {
        countries = countryList;
        countryCodes = countryCodeMap;
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<void> fetchCities(String country) async {
    String? countryCode = countryCodes[country];
    if (countryCode == null) {
      setState(() {
        cities[country] = [];
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://wft-geo-db.p.rapidapi.com/v1/geo/cities?countryIds=$countryCode&limit=10'),
      headers: {
        'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
        'x-rapidapi-key': 'd749bea547mshebac7e5dfc95922p1f33bdjsn461cad796f20', // Fügen Sie hier Ihren RapidAPI-Schlüssel ein
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<String> cityList = [];
      for (var city in data['data']) {
        cityList.add(city['name']);
      }
      setState(() {
        cities[country] = cityList;
      });
    } else {
      setState(() {
        cities[country] = [];
      });
      throw Exception('Failed to load cities');
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        ticketFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        ticketFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      Reference storageRef = FirebaseStorage.instance.ref().child('tickets').child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void validateAndSubmit() async {
    String errorMessage = '';

    if (selectedFromCountry == null) {
      errorMessage += 'Please select a from country.\n';
    }
    if (selectedFromCity == null) {
      errorMessage += 'Please select a from city.\n';
    }
    if (selectedToCountry == null) {
      errorMessage += 'Please select a to country.\n';
    }
    if (selectedToCity == null) {
      errorMessage += 'Please select a to city.\n';
    }
    if (dateController.text.isEmpty) {
      errorMessage += 'Please select a date.\n';
    }
    if (selectedServiceType == null) {
      errorMessage += 'Please select a service type.\n';
    }
    if (weightController.text.isEmpty) {
      errorMessage += 'Please enter the weight.\n';
    }
    if (selectedWeightUnit == null) {
      errorMessage += 'Please select the weight unit.\n';
    }
    if (ticketFile == null && widget.flightKey == null) {
      errorMessage += 'Please upload a ticket image or file.\n';
    }

    if (errorMessage.isNotEmpty) {
      showSnackBarMessage(errorMessage.trim());
      return;
    }

    String? ticketFileUrl;
    if (ticketFile != null) {
      ticketFileUrl = await _uploadFile(ticketFile!);
      if (ticketFileUrl == null) {
        showSnackBarMessage('Failed to upload ticket image or file. Please try again.');
        return;
      }
    }

    if (widget.flightKey != null) {
      updateFlight(ticketFileUrl);
    } else {
      submitFlight(ticketFileUrl!);
    }
  }

  void submitFlight(String ticketFileUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String emailKey = user.email!.replaceAll('.', ','); // Replace '.' with ',' for Firebase keys
        DatabaseReference flightsRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(emailKey)
            .child('flights');
        await flightsRef.push().set({
          'fromCountry': selectedFromCountry,
          'fromCity': selectedFromCity,
          'toCountry': selectedToCountry,
          'toCity': selectedToCity,
          'date': dateController.text,
          'typeOfService': selectedServiceType,
          'weight': '${weightController.text} $selectedWeightUnit',
          'ticketFileUrl': ticketFileUrl,
          'active': true, // All flights are active by default
        });
        showSnackBarMessage('Flight added successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBarMessage('Failed to add flight. Please try again.');
    }
  }

  void updateFlight(String? ticketFileUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String emailKey = user.email!.replaceAll('.', ','); // Replace '.' with ',' for Firebase keys
        DatabaseReference flightRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(emailKey)
            .child('flights')
            .child(widget.flightKey!);
        Map<String, dynamic> updateData = {
          'fromCountry': selectedFromCountry,
          'fromCity': selectedFromCity,
          'toCountry': selectedToCountry,
          'toCity': selectedToCity,
          'date': dateController.text,
          'typeOfService': selectedServiceType,
          'weight': '${weightController.text} $selectedWeightUnit',
          'active': true, // Ensure flights remain active when updated
        };
        if (ticketFileUrl != null) {
          updateData['ticketFileUrl'] = ticketFileUrl;
        }
        await flightRef.update(updateData);
        showSnackBarMessage('Flight updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBarMessage('Failed to update flight. Please try again.');
    }
  }

  void loadFlightDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String emailKey = user.email!.replaceAll('.', ','); // Replace '.' with ',' for Firebase keys
      DatabaseReference flightRef = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(emailKey)
          .child('flights')
          .child(widget.flightKey!);
      DataSnapshot snapshot = await flightRef.once().then((DatabaseEvent event) => event.snapshot);
      if (snapshot.value != null) {
        Map<dynamic, dynamic> flightData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          selectedFromCountry = flightData['fromCountry'];
          fetchCities(selectedFromCountry!);
          selectedFromCity = flightData['fromCity'];
          selectedToCountry = flightData['toCountry'];
          fetchCities(selectedToCountry!);
          selectedToCity = flightData['toCity'];
          dateController.text = flightData['date'];
          selectedServiceType = flightData['typeOfService'];
          weightController.text = flightData['weight'].split(' ')[0];
          selectedWeightUnit = flightData['weight'].split(' ')[1];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flightKey != null ? 'Edit Flight' : 'Add Flight'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'From (Country, City)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildDropdownButtonFormField(
                hint: 'Select From Country',
                value: selectedFromCountry,
                items: countries,
                onChanged: (newValue) {
                  setState(() {
                    selectedFromCountry = newValue;
                    selectedFromCity = null; // Reset city selection
                    if (newValue != null) {
                      fetchCities(newValue);
                    }
                  });
                },
              ),
              if (selectedFromCountry != null && cities.containsKey(selectedFromCountry))
                buildDropdownButtonFormField(
                  hint: 'Select From City',
                  value: selectedFromCity,
                  items: cities[selectedFromCountry]!,
                  onChanged: (newValue) {
                    setState(() {
                      selectedFromCity = newValue;
                    });
                  },
                ),
              Text(
                'To (Country, City)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildDropdownButtonFormField(
                hint: 'Select To Country',
                value: selectedToCountry,
                items: countries,
                onChanged: (newValue) {
                  setState(() {
                    selectedToCountry = newValue;
                    selectedToCity = null; // Reset city selection
                    if (newValue != null) {
                      fetchCities(newValue);
                    }
                  });
                },
              ),
              if (selectedToCountry != null && cities.containsKey(selectedToCountry))
                buildDropdownButtonFormField(
                  hint: 'Select To City',
                  value: selectedToCity,
                  items: cities[selectedToCountry]!,
                  onChanged: (newValue) {
                    setState(() {
                      selectedToCity = newValue;
                    });
                  },
                ),
              buildTextField(
                controller: dateController,
                label: 'Date',
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              buildDropdownButtonFormField(
                hint: 'Select Service Type',
                value: selectedServiceType,
                items: serviceTypes,
                onChanged: (newValue) {
                  setState(() {
                    selectedServiceType = newValue;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: weightController,
                      label: 'Weight',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: buildDropdownButtonFormField(
                      hint: 'Unit',
                      value: selectedWeightUnit,
                      items: weightUnits,
                      onChanged: (newValue) {
                        setState(() {
                          selectedWeightUnit = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showUploadOptions(context),
                      child: Text('Upload Ticket'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    if (ticketFile != null) buildFilePreview(ticketFile!),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: validateAndSubmit,
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Upload PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFilePreview(File file) {
    String fileName = file.path.split('/').last;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (fileName.endsWith('.pdf'))
            Icon(Icons.picture_as_pdf, size: 50)
          else
            Image.file(file, width: 50, height: 50),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownButtonFormField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
        ),
        value: value,
        hint: Text(hint),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
        ),
        onTap: onTap,
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
