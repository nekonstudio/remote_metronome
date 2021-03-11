import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_drawer.dart';
import '../../../widgets/icon_circle_button.dart';
import '../../local_storage/local_storage_provider.dart';
import '../../remote_synchronization/controllers/remote_storage_metronome_settings_controller.dart';
import '../../remote_synchronization/logic/remote_command.dart';
import '../../remote_synchronization/providers/nearby_devices_provider.dart';
import '../../remote_synchronization/providers/remote_synchronization_provider.dart';
import '../../remote_synchronization/widgets/remote_mode_screen.dart';
import '../controllers/metronome_settings_controller.dart';
import '../controllers/storage_metronome_settings_controller.dart';
import '../logic/tap_tempo_detector.dart';
import '../providers/metronome_provider.dart';
import '../widgets/metronome_settings_panel.dart';
import '../widgets/metronome_visualization.dart';
import '../widgets/tap_tempo_detector_button.dart';

class SimpleMetronomeScreen extends ConsumerWidget {
  final _tapTempoDetectorProvider = ChangeNotifierProvider(
    (ref) => NotifierTapTempoDetector(),
  );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final remoteSynchronization = watch(synchronizationProvider);
    final storage = context.read(localStorageProvider);
    final isSynchronized = remoteSynchronization.synchronizationMode.isSynchronized;
    final metronomeSettingsController = isSynchronized
        ? RemoteStorageMetronomeSettingsController(
            context.read(nearbyDevicesProvider),
            storage,
            context.read(metronomeProvider),
          )
        : StorageMetronomeSettingsController(storage);

    metronomeSettingsController.addListener(() {
      context.read(_tapTempoDetectorProvider).reset();
      context.read(metronomeProvider).change(metronomeSettingsController.value);
    });

    if (isSynchronized) {
      remoteSynchronization.simpleMetronomeSettingsGetter = () => metronomeSettingsController.value;
      remoteSynchronization.broadcastRemoteCommand(
        RemoteCommand.setMetronomeSettings(metronomeSettingsController.value),
      );
    }

    return WillPopScope(
      onWillPop: () {
        context.read(metronomeProvider).stop();
        return Future.value(true);
      },
      child: RemoteModeScreen(
        title: Text('Metronom'),
        drawer: AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ValueListenableBuilder(
                  valueListenable: metronomeSettingsController,
                  builder: (context, metronomeSettings, child) =>
                      MetronomeVisualization(metronomeSettings.beatsPerBar),
                ),
              ),
              MetronomeSettingsPanel(
                metronomeSettingsController: metronomeSettingsController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, watch, child) {
                        final isPlaying = watch(isMetronomePlayingProvider);
                        return IconCircleButton(
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.red,
                          onPressed: () => _handleMetronomePlaying(
                            context,
                            metronomeSettingsController,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, watch, child) {
                        final tapTempoDetector = watch(_tapTempoDetectorProvider);
                        final isMetronomePlaying = watch(metronomeProvider).isPlaying;

                        return TapTempoDetectorButton(
                          isTempoDetectionActive: tapTempoDetector.isActive,
                          isDisabled: isMetronomePlaying,
                          onPressed: () {
                            _onTapTempoDetectorButtonPress(
                              isMetronomePlaying,
                              tapTempoDetector,
                              metronomeSettingsController,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapTempoDetectorButtonPress(
    bool isMetronomePlaying,
    NotifierTapTempoDetector tapTempoDetector,
    MetronomeSettingsController metronomeSettingsController,
  ) {
    if (!isMetronomePlaying) {
      tapTempoDetector.registerTap();
      final tempo = tapTempoDetector.calculatedTempo;
      if (tempo != null) {
        metronomeSettingsController.setTempo(tempo);
      }
    }
  }

  void _handleMetronomePlaying(
    BuildContext context,
    MetronomeSettingsController metronomeSettingsController,
  ) {
    final metronome = context.read(metronomeProvider);
    if (!metronome.isPlaying) {
      metronome.start(metronomeSettingsController.value);
      context.read(_tapTempoDetectorProvider).reset();
    } else {
      metronome.stop();
    }
  }
}