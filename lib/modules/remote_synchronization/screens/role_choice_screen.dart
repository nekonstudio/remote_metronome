import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../metronome/providers/metronome_provider.dart';
import 'client_connecting_screen.dart';
import 'host_connecting_screen.dart';

class RoleChoiceScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(metronomeProvider).stop();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wspólne odtwarzanie'),
      ),
      body: Column(
        children: [
          _Option(
            title: 'Utwórz nową sesję',
            subtitle:
                'Wybierz urządzenia, które zostaną zsynchronizowane z Twoim urządzeniem i zarządzaj sesją odtwarzania metronomu.',
            buttonText: 'Utwórz',
            nextScreen: HostConnectingScreen(),
          ),
          Divider(thickness: 2),
          _Option(
            title: 'Dołącz do sesji',
            subtitle:
                'Gospodarz sesji będzie zarządzał metronomem, który zostanie odtworzony na Twoim urządzeniu.',
            buttonText: 'Dołącz',
            nextScreen: ClientConnectingScreen(),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Widget nextScreen;

  const _Option({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.buttonText,
    @required this.nextScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: Get.textTheme.headline5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Get.textTheme.caption,
            ),
          ),
          RaisedButton(
            child: Text(buttonText),
            onPressed: () {
              Get.to(
                () => nextScreen,
              );
            },
          ),
        ],
      ),
    );
  }
}
