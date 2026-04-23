import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Fullscreen video overlay opened via [Navigator.push].
///
/// Receives an already-initialised [VideoPlayerController] from the grid tile
/// so there is NO re-initialisation delay — the video resumes seamlessly.
///
/// On pop, the controller is handed back to the caller (still alive), so the
/// tile can resume playback without re-init.
class FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController videoController;
  final String heroTag;
  final String title;
  final String author;

  const FullscreenVideoPage({
    super.key,
    required this.videoController,
    required this.heroTag,
    required this.title,
    required this.author,
  });

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage>
    with SingleTickerProviderStateMixin {
  late ChewieController _chewieController;
  late AnimationController _uiAnimController;
  late Animation<double> _uiFade;

  bool _uiVisible = true;

  @override
  void initState() {
    super.initState();

    // Allow landscape in fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Immersive fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _uiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _uiFade = CurvedAnimation(
      parent: _uiAnimController,
      curve: Curves.easeInOut,
    );

    // Build a fresh ChewieController around the SAME VideoPlayerController
    // (no re-init needed — controller already initialized and positioned)
    _chewieController = ChewieController(
      videoPlayerController: widget.videoController,
      autoPlay: true,
      looping: true,
      allowFullScreen: false, // we ARE fullscreen; hide the button
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFF4C5E),
        handleColor: const Color(0xFFFF4C5E),
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
    );
  }

  @override
  void dispose() {
    // Restore portrait + system UI on exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // ⚠️ Dispose only the ChewieController, NOT the VideoPlayerController.
    // The VideoPlayerController is owned by the tile — it will keep playing
    // (or be paused) by the tile after we pop.
    _chewieController.dispose();
    _uiAnimController.dispose();
    super.dispose();
  }

  void _toggleUi() {
    if (_uiVisible) {
      _uiAnimController.reverse();
    } else {
      _uiAnimController.forward();
    }
    _uiVisible = !_uiVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUi,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video (Hero wraps the player for smooth transition) ─────────
            Hero(
              tag: widget.heroTag,
              child: Chewie(controller: _chewieController),
            ),

            // ── Top overlay: back + title ──────────────────────────────────
            FadeTransition(
              opacity: _uiFade,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      _GlassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.author,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helper ─────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
