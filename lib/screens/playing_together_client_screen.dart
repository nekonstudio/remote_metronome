import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/nearby/nearby_devices.dart';

class PlayingTogetherClientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read(nearbyDevicesProvider).discover();
    return Scaffold(
      appBar: AppBar(
        title: Text('Wspólne odtwarzanie'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          context.read(nearbyDevicesProvider).finish();
          return true;
        },
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Consumer(
                builder: (context, watch, child) {
                  final nearbyDevices = watch(nearbyDevicesProvider);
                  final isConnected = nearbyDevices.hasConnections;
                  final text = isConnected
                      ? 'Połączono z ${nearbyDevices.connectedDevicesList.first}!'
                      : 'Trwa wyszukiwanie dostępnych urządzeń';
                  return
                      // isConnected
                      //     ? Get.to(ClientControlScreen())
                      //     :
                      Text(
                    text,
                    style: Get.textTheme.caption,
                  );
                },
              ),
              SizedBox(
                height: 5,
              ),
              Consumer(
                builder: (context, watch, child) {
                  final nearbyDevices = watch(nearbyDevicesProvider);
                  final isConnected = nearbyDevices.hasConnections;
                  final text =
                      isConnected ? 'Oczekiwanie na zatwierdzenie sesji.' : '';
                  return Text(
                    text,
                    style: Get.textTheme.caption,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
