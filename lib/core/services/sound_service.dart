import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal() {
    _initAudioPlayer();
  }

  late final AudioPlayer _audioPlayer;
  String? _customSoundPath;
  String _currentSound = 'Default';
  bool _hasCustomSound = false;

  // List of available sounds
  static const List<String> availableSounds = [
    'Default',
    'Select Sound from Device'
  ];

  String get currentSound => _currentSound;

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      print('AudioPlayer initialized successfully');
    } catch (e) {
      print('Error initializing AudioPlayer: $e');
    }
  }

  Future<String?> pickCustomSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        _customSoundPath = result.files.single.path;
        _currentSound = 'Custom Sound';
        _hasCustomSound = true;
        print('Custom sound selected: $_customSoundPath');
        return _customSoundPath;
      }
    } catch (e) {
      print('Error picking sound: $e');
    }
    return null;
  }

  void setSound(String soundName) {
    if (availableSounds.contains(soundName)) {
      _currentSound = soundName;
      if (soundName == 'Default') {
        _customSoundPath = null;
        _hasCustomSound = false;
      }
      print('Sound set to: $_currentSound');
    }
  }

  Future<void> playTimerCompleteSound() async {
    try {
      print('Attempting to play timer complete sound...');
      if (_hasCustomSound && _customSoundPath != null) {
        print('Playing custom sound from: $_customSoundPath');
        final result =
            await _audioPlayer.play(DeviceFileSource(_customSoundPath!));
      } else {
        print('Playing default sound: assets/sounds/kitchen-timer-33043.mp3');
        final result = await _audioPlayer
            .play(AssetSource('sounds/kitchen-timer-33043.mp3'));
      }
    } catch (e) {
      print('Error playing sound: $e');
      print(
          'Current sound path: ${_customSoundPath ?? 'assets/sounds/kitchen-timer-33043.mp3'}');
    }
  }

  Future<void> stopSound() async {
    try {
      print('Stopping sound playback');
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  void dispose() {
    print('Disposing AudioPlayer');
    _audioPlayer.dispose();
  }
}
