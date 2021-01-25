import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby/nearby_devices.dart';
import '../providers/remote/remote_synchronization.dart';
import 'remote_connected_devices_panel.dart';

abstract class RemoteSynchronizedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final synchronization = context.read(synchronizationProvider);

    if (synchronization.isSynchronized) {
      initSynchronization(context, synchronization);
    }

    return Scaffold(
      appBar: AppBar(
        title: buildTitle(context),
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final nearbyDevices = watch(nearbyDevicesProvider);
              final hasConnections = nearbyDevices.hasConnections;
              final connectionsCount = nearbyDevices.connectedDevicesList.length;

              return hasConnections
                  ? _BadgeIconButton(
                      icon: Icon(Icons.wifi),
                      number: connectionsCount,
                      color: Get.theme.accentColor,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => RemoteConnectedDevicesPanel(),
                        );
                      },
                    )
                  : Container();
            },
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: WillPopScope(
        onWillPop: () => onScreenClosing(context, synchronization),
        child: ProviderListener<NearbyDevices>(
          provider: nearbyDevicesProvider,
          onChange: (context, nearbyDevices) {
            if (!ModalRoute.of(context).isCurrent) return;

            if (nearbyDevices.hasConnections) {
              final disconnectedDeviceName = nearbyDevices.lastDisconnectedDeviceName;
              if (disconnectedDeviceName != null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Urządzenie $disconnectedDeviceName rozłączyło się'),
                  ),
                );
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Zakończono tryb wspólnego odtwarzania'),
                  content: Text('Rozłączono ze wszystkimi urządzniami'),
                  actions: [
                    FlatButton(onPressed: Get.back, child: Text('OK')),
                  ],
                ),
              );

              context.read(synchronizationProvider).end();
            }
          },
          child: Stack(
            children: [
              buildBody(context),
              _RemoteLaunchIndicator(),
            ],
          ),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  void initSynchronization(BuildContext context, RemoteSynchronization synchronization);
  Future<bool> onScreenClosing(BuildContext context, RemoteSynchronization synchronization);
  Widget buildTitle(BuildContext context);
  Widget buildBody(BuildContext context);

  Widget buildDrawer(BuildContext context) => null;
  Widget buildFloatingActionButton(BuildContext context) => null;
}

class _BadgeIconButton extends StatelessWidget {
  final Icon icon;
  final Function onPressed;
  final Color color;
  final int number;

  const _BadgeIconButton({
    Key key,
    this.icon,
    this.onPressed,
    this.color,
    this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: icon,
          onPressed: onPressed,
          color: color,
        ),
        Positioned(
          bottom: 14,
          right: 8,
          child: CircleAvatar(
            radius: 7,
            child: Text(
              '$number',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _RemoteLaunchIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final useIndicator = watch(remoteActionNotifierProvider.state);
    return useIndicator
        ? TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
            ),
          )
        : Container();
  }
}
