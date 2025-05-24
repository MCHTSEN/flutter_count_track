import 'package:audioplayers/audioplayers.dart';

enum SoundType {
  success,
  warning,
  error,
}

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static final SoundService _instance = SoundService._internal();

  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> playSound(SoundType type) async {
    try {
      String path;
      switch (type) {
        case SoundType.success:
          path = 'sounds/success.mp3';
          break;
        case SoundType.warning:
          path = 'sounds/warning.mp3';
          break;
        case SoundType.error:
          path = 'sounds/error.mp3';
          break;
      }
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      // Ses çalma hatalarını sessizce işle
      print('Ses çalınamadı: $e');
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
