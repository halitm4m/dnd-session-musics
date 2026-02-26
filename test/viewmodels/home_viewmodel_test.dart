import 'package:dnd_session_musics/app/app.locator.dart';
import 'package:dnd_session_musics/app/models/playlist_button.dart';
import 'package:dnd_session_musics/services/playlist_storage_service.dart';
import 'package:dnd_session_musics/services/spotify_remote_service.dart';
import 'package:dnd_session_musics/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSpotifyRemoteService extends Mock implements SpotifyRemoteService {}

class MockPlaylistStorageService extends Mock implements PlaylistStorageService {}

void main() {
  late MockSpotifyRemoteService spotifyRemoteService;
  late MockPlaylistStorageService playlistStorageService;

  HomeViewModel getModel() => HomeViewModel();

  setUp(() {
    spotifyRemoteService = MockSpotifyRemoteService();
    playlistStorageService = MockPlaylistStorageService();

    if (locator.isRegistered<SpotifyRemoteService>()) {
      locator.unregister<SpotifyRemoteService>();
    }
    if (locator.isRegistered<PlaylistStorageService>()) {
      locator.unregister<PlaylistStorageService>();
    }

    locator.registerSingleton<SpotifyRemoteService>(spotifyRemoteService);
    locator.registerSingleton<PlaylistStorageService>(playlistStorageService);
  });

  tearDown(() => locator.reset());

  group('HomeViewModel -', () {
    test('initialise loads playlists from storage', () async {
      final storedPlaylists = [
        const PlaylistButton(
          id: 'id-1',
          label: 'Epic',
          spotifyUri: 'spotify:playlist:123',
          baseColorValue: 0xFF123456,
        ),
      ];
      when(
        playlistStorageService.loadPlaylists(),
      ).thenAnswer((_) async => storedPlaylists);

      final model = getModel();
      await model.initialise();

      expect(model.playlists, storedPlaylists);
    });

    test('addPlaylist normalizes Spotify url and saves it', () async {
      when(
        playlistStorageService.savePlaylists(any<List<PlaylistButton>>()),
      ).thenAnswer((_) async {});

      final model = getModel();
      await model.addPlaylist(
        label: 'Fight Music',
        rawUri: 'https://open.spotify.com/playlist/abc123?si=xyz',
        color: Colors.red,
      );

      expect(model.playlists, hasLength(1));
      expect(model.playlists.first.spotifyUri, 'spotify:playlist:abc123');
      expect(model.statusMessage, 'Fight Music eklendi');
      verify(
        playlistStorageService.savePlaylists(any<List<PlaylistButton>>()),
      ).called(1);
    });

    test('addPlaylist sets an error for invalid Spotify links', () async {
      final model = getModel();
      await model.addPlaylist(
        label: 'Invalid',
        rawUri: 'https://example.com/not-spotify',
        color: Colors.blue,
      );

      expect(model.playlists, isEmpty);
      expect(model.statusMessage, 'Geçerli bir Spotify playlist linki/URI girin');
      verifyNever(
        playlistStorageService.savePlaylists(any<List<PlaylistButton>>()),
      );
    });
  });
}
