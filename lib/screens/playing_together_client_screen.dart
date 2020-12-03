import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metronom/bluetooth_manager.dart';
import 'package:metronom/screens/client_control_screen.dart';
import 'package:metronom/widgets/enable_bluetooth.dart';
import 'package:provider/provider.dart';

class PlayingTogetherClientScreen extends StatefulWidget {
  @override
  _PlayingTogetherClientScreenState createState() =>
      _PlayingTogetherClientScreenState();
}

class _PlayingTogetherClientScreenState
    extends State<PlayingTogetherClientScreen> {
  var _isInitialized = false;

  BluetoothManager _btManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      _btManager = Provider.of<BluetoothManager>(context);
      // _btManager.waitForState().then((value) => null);

    }
  }

  @override
  Widget build(BuildContext context) {
    print(_btManager.connectedDevicesCount);
    if (_btManager.connectedDevicesCount > 0) {
      print('mamy to! ${_btManager.connectedDevicesCount}');
      Future.delayed(Duration(milliseconds: 200), () {
        Get.off(ClientControlScreen(_btManager));
      });
      // Get.off(ClientControlScreen());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Wspólne odtwarzanie'),
      ),
      body: _btManager.state == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : !_btManager.state.isEnabled
              ? EnableBluetooth()
              : Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Oczekiwanie',
                        style: Get.textTheme.headline5,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Twórca sesji musi połączyć się z Twoim urządzeniem',
                        style: Get.textTheme.caption,
                      ),
                    ],
                  ),
                ),
    );
  }
}
