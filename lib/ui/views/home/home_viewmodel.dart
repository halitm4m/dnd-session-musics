import 'dart:math';

import 'package:dnd_session_musics/app/app.locator.dart';
import 'package:dnd_session_musics/app/models/playlist_button.dart';
import 'package:dnd_session_musics/services/playlist_storage_service.dart';
import 'package:dnd_session_musics/services/spotify_remote_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  final _spotifyRemoteService = locator<SpotifyRemoteService>();
  final _playlistStorageService = locator<PlaylistStorageService>();

  final List<PlaylistButton> _playlists = [];

  bool _busyConnecting = false;
  String? _statusMessage;

  List<PlaylistButton> get playlists => List.unmodifiable(_playlists);
  bool get busyConnecting => _busyConnecting;
  String? get statusMessage => _statusMessage;
  bool get isPlaying => !(_spotifyRemoteService.currentPlayerState?.isPaused ?? true);

  Future<void> initialise() async {
    _playlists
      ..clear()
      ..addAll(await _playlistStorageService.loadPlaylists());
    rebuildUi();
  }

  Future<void> connectSpotify() async {
    if (_busyConnecting) return;
    _busyConnecting = true;
    _statusMessage = null;
    rebuildUi();

    try {
      await _spotifyRemoteService.connect();
      _statusMessage = 'Spotify bağlantısı hazır';
    } catch (e) {
      _statusMessage = 'Spotify bağlantı hatası: $e';
    } finally {
      _busyConnecting = false;
      rebuildUi();
    }
  }

  Future<void> playPlaylist(PlaylistButton playlist) async {
    try {
      await _spotifyRemoteService.playPlaylist(playlist.spotifyUri);
      _statusMessage = 'Çalıyor: ${playlist.label}';
    } catch (e) {
      _statusMessage = 'Çalma başlatılamadı: $e';
    }
    rebuildUi();
  }

  Future<void> togglePlayPause() async {
    try {
      await _spotifyRemoteService.togglePlayPause();
    } catch (e) {
      _statusMessage = 'Oynat/Duraklat başarısız: $e';
    }
    rebuildUi();
  }

  Future<void> skipNext() async {
    try {
      await _spotifyRemoteService.skipNext();
    } catch (e) {
      _statusMessage = 'Sonraki parçaya geçilemedi: $e';
    }
    rebuildUi();
  }

  Future<void> skipPrevious() async {
    try {
      await _spotifyRemoteService.skipPrevious();
    } catch (e) {
      _statusMessage = 'Önceki parçaya geçilemedi: $e';
    }
    rebuildUi();
  }

  Future<void> addPlaylist({
    required String label,
    required String rawUri,
    required Color color,
  }) async {
    final spotifyUri = _normalizeSpotifyUri(rawUri);
    if (spotifyUri == null) {
      _statusMessage = 'Geçerli bir Spotify playlist linki/URI girin';
      rebuildUi();
      return;
    }

    _playlists.add(
      PlaylistButton(
        id: '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}',
        label: label.trim(),
        spotifyUri: spotifyUri,
        baseColorValue: color.value,
      ),
    );

    await _playlistStorageService.savePlaylists(_playlists);
    _statusMessage = '$label eklendi';
    rebuildUi();
  }

  String? _normalizeSpotifyUri(String rawValue) {
    final value = rawValue.trim();
    if (value.startsWith('spotify:playlist:')) {
      return value;
    }

    if (value.contains('open.spotify.com/playlist/')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return null;
      final segments = uri.pathSegments;
      final index = segments.indexOf('playlist');
      if (index == -1 || index + 1 >= segments.length) return null;
      final playlistId = segments[index + 1];
      return 'spotify:playlist:$playlistId';
    }

    return null;
  }

  @override
  void dispose() {
    _spotifyRemoteService.dispose();
    super.dispose();
  }
}
