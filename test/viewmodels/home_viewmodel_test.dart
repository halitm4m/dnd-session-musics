import 'package:dnd_session_musics/app/app.locator.dart';
import 'package:dnd_session_musics/app/models/playlist_button.dart';
import 'package:dnd_session_musics/services/playlist_storage_service.dart';
import 'package:dnd_session_musics/services/spotify_remote_service.dart';
import 'package:dnd_session_musics/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSpotifyRemoteService extends SpotifyRemoteService {
  bool connected = false;
  String? lastPlayedUri;
  bool toggleCalled = false;
  bool nextCalled = false;
  bool previousCalled = false;

  @override
  Future<void> connect() async {
    connected = true;
  }

  @override
  Future<void> playPlaylist(String spotifyUri) async {
    lastPlayedUri = spotifyUri;
  }

  @override
  Future<void> togglePlayPause() async {
    toggleCalled = true;
  }

  @override
  Future<void> skipNext() async {
    nextCalled = true;
  }

  @override
  Future<void> skipPrevious() async {
    previousCalled = true;
  }

  @override
  Future<void> dispose() async {}
}

class _FakePlaylistStorageService extends PlaylistStorageService {
  List<PlaylistButton> inMemory = [];

  @override
  Future<List<PlaylistButton>> loadPlaylists() async => List.of(inMemory);

  @override
  Future<void> savePlaylists(List<PlaylistButton> playlists) async {
    inMemory = List.of(playlists);
  }
}

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewmodelTest -', () {
    late _FakeSpotifyRemoteService spotify;
    late _FakePlaylistStorageService storage;

    setUp(() {
      locator.reset();
      spotify = _FakeSpotifyRemoteService();
      storage = _FakePlaylistStorageService();
      locator.registerSingleton<SpotifyRemoteService>(spotify);
      locator.registerSingleton<PlaylistStorageService>(storage);
    });

    tearDown(() => locator.reset());

    test('connectSpotify connects and sets ready status', () async {
      final model = getModel();
      await model.connectSpotify();

      expect(spotify.connected, isTrue);
      expect(model.statusMessage, contains('hazır'));
    });

    test('addPlaylist accepts Spotify web url and persists normalized uri', () async {
      final model = getModel();

      await model.addPlaylist(
        label: 'Fight Music',
        rawUri: 'https://open.spotify.com/playlist/37i9dQZF1DX0XUsuxWHRQd?si=abc',
        color: Colors.blue,
      );

      expect(model.playlists, hasLength(1));
      expect(model.playlists.first.spotifyUri, 'spotify:playlist:37i9dQZF1DX0XUsuxWHRQd');
      expect(storage.inMemory, hasLength(1));
    });

    test('playback actions call spotify service', () async {
      final model = getModel();
      const playlist = PlaylistButton(
        id: '1',
        label: 'Boss',
        spotifyUri: 'spotify:playlist:abc123',
        baseColorValue: 0xFF0000FF,
      );

      await model.playPlaylist(playlist);
      await model.togglePlayPause();
      await model.skipNext();
      await model.skipPrevious();

      expect(spotify.lastPlayedUri, playlist.spotifyUri);
      expect(spotify.toggleCalled, isTrue);
      expect(spotify.nextCalled, isTrue);
      expect(spotify.previousCalled, isTrue);
    });
  });
}
