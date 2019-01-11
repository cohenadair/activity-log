import 'package:flutter/material.dart';

class NewTimerPage extends StatefulWidget {
  @override
  _NewTimerPageState createState() => _NewTimerPageState();
}

class _NewTimerPageState extends State<NewTimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Timer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Save timer',
            onPressed: _onPressedSaveButton,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Add timer page',
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
