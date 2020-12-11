import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby/nearby_devices.dart';
import '../providers/remote_synchronization.dart';
import 'remote_connected_devices_panel.dart';

class RemoteModeScreen extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget body;
  final Widget drawer;
  final Widget floatingActionButton;

  const RemoteModeScreen({
    Key key,
    this.title,
    this.subtitle,
    this.body,
    this.drawer,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: ListTile(
        //   title: title,
        //   subtitle: subtitle ?? Text('Wspólne odtwarzanie'),
        // ),
        title: title,
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final nearbyDevices = watch(nearbyDevicesProvider);
              final hasConnections = nearbyDevices.hasConnections;
              // final hasConnections = true;
              final connectionsCount =
                  nearbyDevices.connectedDevicesList.length;

              return hasConnections
                  ? _BadgeIconButton(
                      icon: Icon(Icons.wifi),
                      number: connectionsCount,
                      color: Get.theme.accentColor,
                      onPressed: () {
                        // showBottomSheet(context: null, builder: null)
                        showModalBottomSheet(
                            // isScrollControlled: true,
                            context: context,
                            builder: (context) =>
                                RemoteConnectedDevicesPanel());
                      },
                    )
                  : Container();

              // return IconButton(
              //   icon: Icon(hasConnections ? Icons.wifi : null),
              //   onPressed: hasConnections
              //       ? () {
              // showModalBottomSheet(
              //   context: context,
              //   builder: (context) {
              //     return Center(
              //       child: Text('Hello'),
              //     );
              //   },
              // );
              //         }
              //       : null,
              //   color: Get.theme.accentColor,
              // );
            },
          ),
        ],
      ),
      drawer: drawer,
      body: ProviderListener<NearbyDevices>(
        provider: nearbyDevicesProvider,
        onChange: (context, nearbyDevices) {
          if (nearbyDevices.hasConnections) {
            final disconnectedDeviceName =
                nearbyDevices.lastDisconnectedDeviceName;
            if (disconnectedDeviceName != null) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Urządzenie $disconnectedDeviceName rozłączyło się'),
                ),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Zakończono tryb wspólnego odtwarzania'),
                content: Text('Wszystkie podłączone urządzenia rozłączyły się'),
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
            body,
            // LinearProgressIndicator(
            //   value: 1.0,
            // ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
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
