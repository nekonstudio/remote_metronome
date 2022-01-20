import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/remote_synchronization_provider.dart';
import 'remote_command.dart';
import 'remote_command_type.dart';

class ClockSyncSuccessCommand extends RemoteCommand {
  final int? hostTimeDifference;
  final int? clockSyncLatency;

  ClockSyncSuccessCommand(this.hostTimeDifference, this.clockSyncLatency)
      : super(RemoteCommandType.ClockSyncSuccess);

  factory ClockSyncSuccessCommand.fromJson(String source) =>
      ClockSyncSuccessCommand.fromMap(json.decode(source));

  factory ClockSyncSuccessCommand.fromMap(Map<String, dynamic> map) {
    return ClockSyncSuccessCommand(
      map['hostTimeDifference'],
      map['clockSyncLatency'],
    );
  }

  @override
  void execute(Reader providerReader) {
    final synchronization = providerReader(synchronizationProvider);

    synchronization.onClockSyncSuccess(hostTimeDifference, clockSyncLatency);
  }

  @override
  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'hostTimeDifference': hostTimeDifference,
      'clockSyncLatency': clockSyncLatency,
    };
  }
}
