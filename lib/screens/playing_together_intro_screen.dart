import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'playing_together_client_screen.dart';
import 'playing_together_host_screen.dart';

class PlayingTogetherIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
                      PlayingTogetherHostScreen(),
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
                Text('Dołącz do istniejącej sesji',
                    style: Get.textTheme.headline5),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
                      PlayingTogetherClientScreen(),
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
