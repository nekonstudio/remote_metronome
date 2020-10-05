import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:metronom/bluetooth_manager.dart';
import 'package:metronom/screens/host_control_screen.dart';
import 'package:metronom/widgets/enable_bluetooth.dart';
import 'package:provider/provider.dart';

class PlayingTogetherHostScreen extends StatefulWidget {
  @override
  _PlayingTogetherHostScreenState createState() =>
      _PlayingTogetherHostScreenState();
}

class _PlayingTogetherHostScreenState extends State<PlayingTogetherHostScreen> {
  var _isInitialized = false;
  var _isConnecting = false;
  BluetoothManager _btManager;
  List<BluetoothDevice> _devices = [];

  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  Map<BluetoothDevice, BluetoothConnection> connections = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    _btManager = Provider.of<BluetoothManager>(context);
    _btManager.waitForState().then((state) {
      print('no doczekał sie');
      if (state.isEnabled) {
        _scan();
      }
    });

    _btManager.stateChangedCallback = (state) {
      if (state.isEnabled) {
        _scan();
      }
    };

    _isInitialized = true;
  }

  @override
  void dispose() {
    super.dispose();

    _btManager.dispose();
    print('DISPOSE');
  }

  void _scan() {
    _btManager.scanAvailableDevices(
        deviceTypeFilter: [BluetoothDeviceType.classic],
        onDeviceListChanged: (devices) {
          setState(() {
            _devices = devices;
          });
          print(_devices);
        });
  }

  void _enableBluetoothAndScan() async {
    final isEnabled = await _btManager.enableBluetotoh();
    // if (isEnabled) {
    // }
    // future() async {
    //   await FlutterBluetoothSerial.instance.requestEnable();
    // }

    // future().then((value) {
    //   setState(() {
    //     FlutterBluetoothSerial.instance.state.then((state) {
    //       setState(() {
    //         _bluetoothState = state;
    //       });
    //       if (_bluetoothState == BluetoothState.STATE_ON) {
    //         _scan();
    //       }
    //     });
    //   });
    // });
  }

  void _showPairingDialog(String deviceName) {
    Get.defaultDialog(
      title: 'Parowanie urządzenia',
      barrierDismissible: false,
      content: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Trwa parowanie z urządzeniem:\n$deviceName',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoiningDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Oczekiwanie'),
                    subtitle: FittedBox(
                      child: Text(
                        'Wybrane urządzenia muszą dołączyć do sesji',
                      ),
                    ),
                    trailing: CircleAvatar(
                      child: Text('0/3'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: RaisedButton(
                      child: Text('Anuluj'),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Wspólne odtwarzanie'),
          subtitle: Text(_btManager.state == null || _btManager.isScanning
              ? 'Trwa wyszukiwanie urządzeń'
              : 'Wybierz urządzenia'),
        ),
        actions: [
          _btManager.state == null || _btManager.isScanning
              ? SizedBox(
                  width: 35,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                      right: 20,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : IconButton(icon: Icon(Icons.refresh), onPressed: _scan),
        ],
      ),
      body: _btManager.state == null
          ? Center(
              child: Text('${_btManager.state}'),
            )
          : !_btManager.state.isEnabled
              ? EnableBluetooth(_btManager.enableBluetotoh)
              : Container(
                  child: _btManager.isScanning && _devices.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _devices.isEmpty
                          ? Center(
                              child: Text('Brak dostępnych urządzeń'),
                            )
                          : ListView.separated(
                              itemCount: _devices.length,
                              itemBuilder: (context, index) {
                                final device = _devices[index];
                                final isConnected =
                                    _btManager.isConnected(device);
                                return InkWell(
                                  onLongPress: () async {
                                    if (isConnected) {
                                      _btManager.disconnect(device);
                                    } else {
                                      if (!device.isBonded) {
                                        _btManager.pair(device).then((value) {
                                          _btManager.connect(device);
                                          setState(() {
                                            _isConnecting = false;
                                          });
                                          Get.back();
                                        });
                                        _showPairingDialog(device.name);
                                        setState(() {
                                          _isConnecting = true;
                                        });
                                      } else {
                                        _btManager.connect(device);
                                      }
                                    }
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.phone_android,
                                        color: isConnected
                                            ? Get.theme.accentColor
                                            : null),
                                    title: Text(device.name),
                                    subtitle: Text(isConnected
                                        ? 'Połączono! Przytrzymaj, aby rozłączyć'
                                        : 'Przytrzymaj, aby połączyć'),
                                    trailing: _isConnecting
                                        ? CircularProgressIndicator()
                                        : null,
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(),
                            ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _btManager.connectedDevicesCount > 0
            ? Get.theme.accentColor
            : Colors.grey,
        child: Icon(Icons.done),
        onPressed: _btManager.connectedDevicesCount == 0
            ? null
            : () {
                // _showJoiningDialog(context);
                print(_btManager.connectedDevicesCount);
                Get.to(
                  HostControlScreen(_btManager),
                );
              },
      ),
    );
  }
}
