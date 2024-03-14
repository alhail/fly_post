import 'package:flutter/material.dart';

import '../main.dart';

class MyNewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('My New Screen'),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: Center(
        child: Text('Content goes here'),
      ),
    );
  }
}
