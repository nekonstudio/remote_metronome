import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class ClockSyncRequestCommand extends RemoteCommand {
  final int hostStartTimestamp;
  final String senderId;

  ClockSyncRequestCommand(this.hostStartTimestamp, {this.senderId})
      : super(RemoteCommandType.ClockSyncRequest);

  factory ClockSyncRequestCommand.fromJson(String source) {
    final Map<String, dynamic> map = json.decode(source);

    return ClockSyncRequestCommand(
      map['hostStartTimestamp'],
      senderId: map['senderId'],
    );
  }

  @override
  void execute(Reader providerReader) {
    final synchronization = providerReader(synchronizationProvider);
    synchronization.onClockSyncRequest(senderId, hostStartTimestamp);
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'hostStartTimestamp': hostStartTimestamp,
      'senderId': senderId,
    };
  }
}
