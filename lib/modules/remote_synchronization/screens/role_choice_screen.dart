import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../metronome/providers/metronome_provider.dart';
import 'client_connecting_screen.dart';
import 'host_connecting_screen.dart';

class RoleChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read(metronomeProvider).stop();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wspólne odtwarzanie'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Utwórz nową sesję', style: Get.textTheme.headline5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  child: Text(
                    'Wybierz urządzenia, które zostaną zsynchronizowane z Twoim urządzeniem i zarządzaj sesją odtwarzania metronomu.',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.caption,
                  ),
                ),
                RaisedButton(
                  child: Text('Utwórz'),
                  onPressed: () {
                    Get.to(
                      HostConnectingScreen(),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Dołącz do sesji', style: Get.textTheme.headline5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  child: Text(
                    'Gospodarz sesji będzie zarządzał metronomem, który zostanie odtworzony na Twoim urządzeniu.',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.caption,
                  ),
                ),
                RaisedButton(
                  child: Text('Dołącz'),
                  onPressed: () {
                    Get.to(
                      ClientConnectingScreen(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
