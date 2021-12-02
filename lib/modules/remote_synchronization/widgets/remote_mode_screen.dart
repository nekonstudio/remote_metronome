import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../logic/metronome/remote_synchronized_metronome.dart';
import '../logic/nearby_devices.dart';
import '../providers/nearby_devices_provider.dart';
import '../providers/remote_launch_indicator_controller_provider.dart';
import '../providers/remote_synchronization_provider.dart';
import 'remote_connected_devices_panel.dart';

class RemoteModeScreen extends ConsumerWidget {
  final Widget title;
  final Widget body;
  final Widget subtitle;
  final Widget drawer;
  final Widget floatingActionButton;

  const RemoteModeScreen({
    Key key,
    @required this.title,
    @required this.body,
    this.subtitle,
    this.drawer,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NearbyDevices>(nearbyDevicesProvider, (_, nearbyDevices) {
      if (!ModalRoute.of(context).isCurrent) return;

      if (nearbyDevices.hasConnections) {
        final disconnectedDeviceName = nearbyDevices.lastDisconnectedDeviceName;
        if (disconnectedDeviceName != null) {
          ScaffoldMessenger.of(context).showSnackBar(
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
            content: Text('Rozłączono ze wszystkimi urządzniami'),
            actions: [
              TextButton(onPressed: Get.back, child: Text('OK')),
            ],
          ),
        );

        ref.read(synchronizationProvider).end();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final nearbyDevices = ref.watch(nearbyDevicesProvider);
              final hasConnections = nearbyDevices.hasConnections;
              final connectionsCount =
                  nearbyDevices.connectedDevicesList.length;

              return hasConnections
                  ? _BadgeIconButton(
                      icon: Icon(Icons.wifi),
                      number: connectionsCount,
                      color: Get.theme.colorScheme.secondary,
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                RemoteConnectedDevicesPanel());
                      },
                    )
                  : Container();
            },
          ),
        ],
      ),
      drawer: drawer,
      body: Stack(
        children: [
          body,
          _RemoteLaunchIndicator(),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _RemoteLaunchIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicatorController =
        ref.watch(remoteLaunchIndicatorControllerProvider);
    return indicatorController.isActive
        ? TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: RemoteSynchronizedMetronome.commandExecutionDuration,
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
            ),
          )
        : Container();
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
