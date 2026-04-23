import 'package:flutter/material.dart';
import 'lazy_video_tile.dart';
import 'video_player_manager.dart';

const List<VideoItem> _kVideos = [
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@artimind_1772089063.mp4',
    title: 'artimind clip',
    author: '@artimind',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@justnimsay_1772089085.mp4',
    title: 'justnimsay clip',
    author: '@justnimsay',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@pervapin_1772089005.mp4',
    title: 'pervapin clip',
    author: '@pervapin',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@sooyaa2_29_1772089040.mp4',
    title: 'sooyaa2_29 clip',
    author: '@sooyaa2_29',
  ),
  VideoItem(
    assetPath: 'assets/PinDown.io_@YZAVoku_1772089024.mp4',
    title: 'YZAVoku clip',
    author: '@YZAVoku',
  ),
];

/// Root screen.
///
/// Responsibilities:
///  - Builds the 2-column lazy scrollable grid
///  - Observes AppLifecycleState → pauses all on background
///  - Handles orientation changes (grid just reflows; tiles keep controllers)
///  - Zero rebuild propagation to children on lifecycle events
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  // GlobalKeys let us call pause() on tiles imperatively — no setState needed
  final List<GlobalKey<LazyVideoTileState>> _tileKeys = List.generate(
    _kVideos.length,
    (_) => GlobalKey<LazyVideoTileState>(),
  );

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    VideoPlayerManager.instance.silentClear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _pauseAll();
        VideoPlayerManager.instance.silentClear();
        break;
      case AppLifecycleState.resumed:
        // VisibilityDetector will re-fire for visible tiles and
        // they will self-resume via _applyVisibility(). No action needed.
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Orientation changes: Flutter re-lays out but widgets are NOT recreated.
  /// Tile controllers survive orientation — no extra handling needed.
  @override
  void didChangeMetrics() {
    // Grid reflows automatically; tiles keep their VideoPlayerController.
    // No action required.
  }

  void _pauseAll() {
    for (final key in _tileKeys) {
      key.currentState?.pause();
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: _buildAppBar(),
      body: _buildGrid(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: const Row(
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            color: Color(0xFFFF4C5E),
            size: 22,
          ),
          SizedBox(width: 8),
          Text(
            'Reel Grid',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.pause_circle_outline_rounded,
            color: Colors.white54,
          ),
          tooltip: 'Pause all',
          onPressed: _pauseAll,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        // cacheExtent: keep tiles alive 300px beyond viewport.
        // Too high → holds more controllers in memory.
        // Too low → excessive dispose/reinit on slow scroll.
        cacheExtent: 300,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 9 / 17, // portrait 9:16-ish tiles
        ),
        itemCount: _kVideos.length,
        itemBuilder: (context, index) {
          return LazyVideoTile(
            key: _tileKeys[index],
            videoItem: _kVideos[index],
            index: index,
          );
        },
      ),
    );
  }
}
