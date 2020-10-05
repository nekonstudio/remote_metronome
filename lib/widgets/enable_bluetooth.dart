import 'package:flutter/material.dart';

class EnableBluetooth extends StatelessWidget {
  final Function enableHandler;

  const EnableBluetooth(this.enableHandler);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Włącz Bluetooth, aby skorzystać z funkcjonalności'),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: enableHandler,
            child: Text('Włącz'),
          ),
        ],
      ),
    );
  }
}
