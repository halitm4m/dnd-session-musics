import 'dart:async';

import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyRemoteService {
  static const clientId = '837e77a020ca478db26be52b52a4645a';
  static const redirectUrl = 'dnd-sm://callback';
  static const _scopes =
      'app-remote-control,user-modify-playback-state,user-read-playback-state,streaming';

  StreamSubscription<PlayerState>? _playerStateSubscription;
  PlayerState? _currentPlayerState;

  PlayerState? get currentPlayerState => _currentPlayerState;

  Future<void> connect() async {
    await SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: redirectUrl,
    );
    await SpotifySdk.getAccessToken(
      clientId: clientId,
      redirectUrl: redirectUrl,
      scope: _scopes,
    );
    _playerStateSubscription ??=
        SpotifySdk.subscribePlayerState().listen((playerState) {
      _currentPlayerState = playerState;
    });
  }

  Future<void> playPlaylist(String spotifyUri) async {
    await SpotifySdk.play(spotifyUri: spotifyUri);
    await SpotifySdk.setShuffle(shuffle: true);
    await SpotifySdk.setRepeatMode(repeatMode: RepeatMode.context);
  }

  Future<void> togglePlayPause() async {
    final state = _currentPlayerState;
    if (state == null || state.isPaused) {
      await SpotifySdk.resume();
      return;
    }
    await SpotifySdk.pause();
  }

  Future<void> skipNext() => SpotifySdk.skipNext();

  Future<void> skipPrevious() => SpotifySdk.skipPrevious();

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
  }
}
