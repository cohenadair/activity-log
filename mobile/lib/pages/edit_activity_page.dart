import 'package:flutter/material.dart';

import 'package:mobile/widgets/my_app_bar.dart';

class EditActivityPage extends StatefulWidget {
  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text('Add Activity'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Save activity',
            onPressed: _onPressedSaveButton,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Add activity page',
            ),
          ],
        ),
      ),
    );
  }

  void _onPressedSaveButton() {
    Navigator.pop(context);
  }
}
