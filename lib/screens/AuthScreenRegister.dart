import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fly_post/screens/AuthScreenLogIn.dart';


class AuthScreenRegister extends StatefulWidget {
  const AuthScreenRegister({super.key});

  @override
  _AuthScreenRegisterState createState() => _AuthScreenRegisterState();
}

class _AuthScreenRegisterState extends State<AuthScreenRegister> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userName = '';
  String _userPhoneNumber = '';
  String _userPassword = '';

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid!) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );

        // Storing additional user details in Realtime Database
        final dbRef = FirebaseDatabase.instance.reference().child('users/${newUser.user?.uid}');
        await dbRef.set({
          'name': _userName,
          'email': _userEmail,
          'phone': _userPhoneNumber,
        });

        // Proceed to next screen or display success message
      } catch (error) {
        // Error handling
        print(error);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // void _trySubmit() async {
  //   final isValid = _formKey.currentState?.validate();
  //   FocusScope.of(context).unfocus(); // Close the keyboard
  //
  //   if (isValid!) {
  //     _formKey.currentState?.save();
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     try {
  //       // User registration
  //       final newUser = await _auth.createUserWithEmailAndPassword(
  //         email: _userEmail,
  //         password: _userPassword,
  //       );
  //
  //       // Adding user details to Firestore
  //       await FirebaseFirestore.instance.collection('users').doc(newUser.user?.uid).set({
  //         'username': _userName,
  //         'email': _userEmail,
  //         'phone': _userPhoneNumber,
  //       });
  //
  //       // Navigate to another screen or show success message
  //     } catch (err) {
  //       var message = 'An error occurred, please check your credentials!';
  //
  //       // if (err.message != null) {
  //       //   message = err.message;
  //       // }
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(message),
  //           backgroundColor: Theme.of(context).errorColor,
  //         ),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavDrawer(),
      backgroundColor: const Color(0xFF6dbcfe),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                  ),
                  TextFormField(
                    key: const ValueKey('username'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Please enter at least 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userName = value!;
                    },
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextFormField(
                    key: const ValueKey('phone'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid phone number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userPhoneNumber = value!;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: const Text('Signup'),
                    ),
                    TextButton(
                      child: const Text('I already have an account'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AuthScreenLogIn()),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


