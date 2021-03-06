// ignore_for_file: avoid_renaming_method_parameters

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() async => await _player.play();

  @override
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> seek(Duration position) async => await _player.seek(position);

  @override
  Future<void> stop() async => await _player.stop();

  @override
  Future<void> playMediaItem(MediaItem _mediaItem) async {
    // Load the player then get duration.
    Duration? duration =
        await _player.setAudioSource(AudioSource.uri(Uri.parse(_mediaItem.id)));

    // the current media item via mediaItem.
    mediaItem.add(_mediaItem.copyWith(duration: duration));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode;
    if (repeatMode == AudioServiceRepeatMode.one) {
      loopMode = LoopMode.one;
    } else {
      loopMode = LoopMode.off;
    }

    await _player.setLoopMode(loopMode);
  }

  AudioServiceRepeatMode getAudioServiceRepeatMode(LoopMode loopMode) {
    if (loopMode == LoopMode.one) {
      return AudioServiceRepeatMode.one;
    } else {
      return AudioServiceRepeatMode.none;
    }
  }

  /// Transform a just_audio event into an audio_service state.
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setRepeatMode,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
      repeatMode: getAudioServiceRepeatMode(_player.loopMode),
    );
  }
}
