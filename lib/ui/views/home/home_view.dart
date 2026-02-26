import 'package:dnd_session_musics/app/models/playlist_button.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _TopBar(viewModel: viewModel),
              const SizedBox(height: 14),
              Expanded(
                child: viewModel.playlists.isEmpty
                    ? _EmptyState(onAddPressed: () => _showAddPlaylistSheet(context, viewModel))
                    : _PlaylistGrid(
                        playlists: viewModel.playlists,
                        onTap: viewModel.playPlaylist,
                      ),
              ),
              const SizedBox(height: 12),
              _PlaybackControls(viewModel: viewModel),
              if (viewModel.statusMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  viewModel.statusMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlaylistSheet(context, viewModel),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.playlist_add_rounded),
        label: const Text('Yeni liste ekle'),
      ),
    );
  }

  Future<void> _showAddPlaylistSheet(BuildContext context, HomeViewModel viewModel) async {
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController();
    final uriController = TextEditingController();
    Color selectedColor = const Color(0xFF8B5CF6);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1F2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Yeni Playlist', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: labelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Uygulamada görünecek isim'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'İsim gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: uriController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Spotify playlist linki veya URI'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Link gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Buton rengi', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: selectedColor.withOpacity(0.35), blurRadius: 12),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: 360,
                            value: HSVColor.fromColor(selectedColor).hue,
                            onChanged: (value) {
                              setState(() {
                                selectedColor = HSVColor.fromAHSV(1, value, 0.62, 0.88).toColor();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          await viewModel.addPlaylist(
                            label: labelController.text,
                            rawUri: uriController.text,
                            color: selectedColor,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: const Text('Ekle'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF111625),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.initialise();
    viewModel.connectSpotify();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'D&D Session Musics',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (viewModel.busyConnecting)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            onPressed: viewModel.connectSpotify,
            icon: const Icon(Icons.link_rounded, color: Colors.white70),
          ),
      ],
    );
  }
}

class _PlaylistGrid extends StatelessWidget {
  const _PlaylistGrid({required this.playlists, required this.onTap});

  final List<PlaylistButton> playlists;
  final void Function(PlaylistButton) onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCrossAxisExtent = width > 1000 ? 290.0 : 240.0;

    return GridView.builder(
      itemCount: playlists.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisExtent: 145,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        final gradient = [
          playlist.baseColor.withOpacity(0.95),
          Color.lerp(playlist.baseColor, Colors.black, 0.28)!,
        ];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 240 + (index * 35)),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.92, end: 1),
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => onTap(playlist),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          playlist.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191E2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: viewModel.skipPrevious,
            icon: const Icon(Icons.skip_previous_rounded, size: 34, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: viewModel.togglePlayPause,
              child: SizedBox(
                width: 58,
                height: 52,
                child: Icon(
                  viewModel.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: viewModel.skipNext,
            icon: const Icon(Icons.skip_next_rounded, size: 34, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF171D2A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 10),
            const Text(
              'Henüz playlist yok',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Spotify linki ile yeni bir buton ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Playlist ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
