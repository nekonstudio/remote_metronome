class BluetoothMessageExecutor {
  static Future<void> awaitExecute(int timestamp) async {
    final executeTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    print('teraz jest ${DateTime.now().toIso8601String()}');
    print('odpalić mam o ${executeTime.toIso8601String()}');

    final waitTime = executeTime.difference(DateTime.now());

    print('czyli musze czekać ${waitTime.inMilliseconds} ms');

    await Future.delayed(waitTime);
  }
}
