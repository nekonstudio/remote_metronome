import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_drawer.dart';
import '../../../widgets/icon_circle_button.dart';
import '../../remote_synchronization/logic/remote_commands/set_metronome_settings_command.dart';
import '../../remote_synchronization/providers/device_synchronization_mode_notifier_provider.dart';
import '../../remote_synchronization/providers/remote_synchronization_provider.dart';
import '../../remote_synchronization/widgets/remote_mode_screen.dart';
import '../controllers/metronome_settings_controller.dart';
import '../logic/tap_tempo_detector.dart';
import '../providers/metronome_provider.dart';
import '../providers/simple_metronome_settings_controller_provider.dart';
import '../widgets/metronome_settings_panel.dart';
import '../widgets/metronome_visualization.dart';
import '../widgets/tap_tempo_detector_button.dart';

class SimpleMetronomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SimpleMetronmeScreenState();
}

class _SimpleMetronmeScreenState extends ConsumerState<SimpleMetronomeScreen> {
  final _tapTempoDetectorProvider = ChangeNotifierProvider(
    (ref) => NotifierTapTempoDetector(),
  );

  late final MetronomeSettingsController metronomeSettingsControllerReadonly;

  @override
  void initState() {
    super.initState();

    metronomeSettingsControllerReadonly = ref
        .read(simpleMetronomeSettingsControllerProvider)
      ..addListener(_onMetronomeSettingsChanged);
  }

  @override
  void dispose() {
    metronomeSettingsControllerReadonly
        .removeListener(_onMetronomeSettingsChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remoteSynchronization = ref.watch(synchronizationProvider);

    final metronomeSettingsController =
        ref.watch(simpleMetronomeSettingsControllerProvider);

    final isSynchronized =
        ref.watch(deviceSynchronizationModeNotifierProvider).isSynchronized;
    if (isSynchronized) {
      remoteSynchronization.broadcastRemoteCommand(
        SetMetronomeSettingsCommand(metronomeSettingsController.value),
      );
    }

    return WillPopScope(
      onWillPop: () {
        ref.read(metronomeProvider).stop();
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
                  builder: (context, dynamic metronomeSettings, child) =>
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
                      builder: (context, ref, child) {
                        final isPlaying = ref.watch(isMetronomePlayingProvider);
                        return IconCircleButton(
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.red,
                          onPressed: () => _handleMetronomePlaying(
                            ref,
                            metronomeSettingsController,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final tapTempoDetector =
                            ref.watch(_tapTempoDetectorProvider);
                        final isMetronomePlaying =
                            ref.watch(metronomeProvider).isPlaying;

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

  void _onMetronomeSettingsChanged() {
    ref.read(_tapTempoDetectorProvider).reset();
    ref
        .read(metronomeProvider)
        .change(ref.read(simpleMetronomeSettingsControllerProvider).value);
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
    WidgetRef ref,
    MetronomeSettingsController metronomeSettingsController,
  ) {
    final metronome = ref.read(metronomeProvider);
    if (!metronome.isPlaying) {
      metronome.start(metronomeSettingsController.value);
      ref.read(_tapTempoDetectorProvider).reset();
    } else {
      metronome.stop();
    }
  }
}
