import 'package:dnd_session_musics/app/models/playlist_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistStorageService {
  static const _playlistsKey = 'saved_playlist_buttons';

  Future<List<PlaylistButton>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return PlaylistButton.decodeList(raw);
  }

  Future<void> savePlaylists(List<PlaylistButton> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, PlaylistButton.encodeList(playlists));
  }
}
