import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:metronom/bluetooth_manager.dart';
import 'package:metronom/providers/bluetooth/bluetooth_connections_manager.dart';
import 'package:metronom/providers/bluetooth/bluetooth_devices_scanner.dart';
import 'package:metronom/screens/host_control_screen.dart';
import 'package:metronom/widgets/enable_bluetooth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayingTogetherHostScreen extends StatefulWidget {
  @override
  _PlayingTogetherHostScreenState createState() =>
      _PlayingTogetherHostScreenState();
}

class _PlayingTogetherHostScreenState extends State<PlayingTogetherHostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz urządzenia'),
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final isScanning =
                  watch(bluetoothDevicesScannerProvider).isScanning;
              return FutureBuilder<BluetoothState>(
                future: FlutterBluetoothSerial.instance.state,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data.isEnabled)
                    return Container();
                  return IconButton(
                    icon: Icon(isScanning ? null : Icons.refresh),
                    onPressed: isScanning ? null : () => setState(() {}),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: FlutterBluetoothSerial.instance.state,
        builder: (context, initialStateSnapshot) {
          if (initialStateSnapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final initialBluetoothState = initialStateSnapshot.data;
          return StreamBuilder<BluetoothState>(
            initialData: initialBluetoothState,
            stream: FlutterBluetoothSerial.instance.onStateChanged(),
            builder: (context, currentStateSnapshot) {
              final currentBluetoothState = currentStateSnapshot.data;
              return (currentBluetoothState != BluetoothState.STATE_ON)
                  ? EnableBluetooth()
                  : StreamBuilder<List<BluetoothDevice>>(
                      initialData: [],
                      stream: context
                          .read(bluetoothDevicesScannerProvider)
                          .scan(
                              deviceTypeFilter: [BluetoothDeviceType.classic]),
                      builder: (context, devicesSnapshot) {
                        final isScanningDone =
                            devicesSnapshot.connectionState ==
                                ConnectionState.done;
                        final data = devicesSnapshot.data;

                        return Column(
                          children: [
                            (!isScanningDone)
                                ? LinearProgressIndicator()
                                : SizedBox(height: 4),
                            Expanded(
                              child: (data.isNotEmpty)
                                  ? BluetoothDevicesList(data)
                                  : Center(
                                      child: Text((!isScanningDone)
                                          ? 'Trwa wyszukiwanie dostępnych urządzeń'
                                          : 'Brak dostępnych urządzeń'),
                                    ),
                            ),
                          ],
                        );
                      },
                    );
            },
          );
        },
      ),
      floatingActionButton: Consumer(
        builder: (context, watch, child) {
          final hasConnections =
              watch(bluetoothConnectionsManagerProvider).hasConnections;

          return FloatingActionButton(
            backgroundColor:
                hasConnections ? Get.theme.accentColor : Colors.grey,
            child: child,
            onPressed: hasConnections
                ? null
                : () {
                    // _showJoiningDialog(context);
                    // print(_btManager.connectedDevicesCount);
                    // Get.to(
                    //   HostControlScreen(_btManager),
                    // );
                  },
          );
        },
        child: Icon(Icons.done),
      ),
    );
  }
}

class BluetoothDevicesList extends StatelessWidget {
  final List<BluetoothDevice> devices;

  const BluetoothDevicesList(this.devices);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Consumer(
          builder: (_, watch, __) {
            final connectionsProvider =
                watch(bluetoothConnectionsManagerProvider);
            print('rebuildzik!');
            final isConnected = connectionsProvider.isConnectedTo(device);
            final isConnecting = watch(connectingStatusProvider.state);
            return InkWell(
              onLongPress: () async {
                if (!isConnected) {
                  final result = await connectionsProvider.connectTo(device);
                  if (result == BluetoothConnectingResult.socketError) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        behavior: SnackBarBehavior.floating,
                        margin:
                            const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 50.0),
                        content: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Nie można połączyć się z ${device.name}',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: FittedBox(
                            child: Text(
                              'Upewnij się, że urządzenie oczekuje na dołączenie do sesji',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  connectionsProvider.disconnect(device);
                }
              },
              child: ListTile(
                leading: Icon(Icons.phone_android,
                    color: isConnected ? Get.theme.accentColor : null),
                title: Text(device.name ?? 'Nieznane'),
                subtitle: Text(isConnected
                    ? 'Połączono! Przytrzymaj, aby rozłączyć'
                    : isConnecting
                        ? 'Łączenie...'
                        : 'Przytrzymaj, aby połączyć'),
                trailing: (isConnecting)
                    ? ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 24, maxWidth: 24),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(null),
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
