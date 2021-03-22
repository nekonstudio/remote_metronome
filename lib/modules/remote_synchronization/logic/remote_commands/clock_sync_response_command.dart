import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class ClockSyncResponseCommand extends RemoteCommand {
  final int hostStartTimestamp;
  final int clientResponseTimestamp;
  final String senderId;

  ClockSyncResponseCommand(this.hostStartTimestamp, this.clientResponseTimestamp, {this.senderId})
      : super(RemoteCommandType.ClockSyncResponse);

  factory ClockSyncResponseCommand.fromJson(String source) =>
      ClockSyncResponseCommand.fromMap(json.decode(source));

  factory ClockSyncResponseCommand.fromMap(Map<String, dynamic> map) {
    return ClockSyncResponseCommand(
      map['hostStartTimestamp'],
      map['clientResponseTimestamp'],
      senderId: map['senderId'],
    );
  }

  @override
  void execute(Reader providerReader) {
    final synchronization = providerReader(synchronizationProvider);
    final hostStartTime = DateTime.fromMillisecondsSinceEpoch(hostStartTimestamp);
    final clientResponseTime = DateTime.fromMillisecondsSinceEpoch(clientResponseTimestamp);

    synchronization.onClockSyncResponse(senderId, hostStartTime, clientResponseTime);
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'hostStartTimestamp': hostStartTimestamp,
      'clientResponseTimestamp': clientResponseTimestamp,
      'senderId': senderId,
    };
  }
}
