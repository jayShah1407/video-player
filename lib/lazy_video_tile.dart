import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'video_player_manager.dart';
import 'fullscreen_video_page.dart';

/// Production-grade lazy video tile — crash-safe edition.
///
/// KEY FIX: The crash "VideoPlayerController used after being disposed" happened
/// because Chewie's internal controls (material_desktop_controls) held a
/// reference to the VideoPlayerController and called .play() on it after
/// _releaseControllers() disposed it. This is a timing race between:
///   (a) the Flutter gesture pipeline firing a tap callback, and
///   (b) our dispose path running synchronously.
///
/// Solution: a THREE-PHASE teardown sequence:
///   1. Null out _chewieController in state → triggers rebuild → Chewie widget
///      leaves the tree → its internal listeners/callbacks are torn down.
///   2. addPostFrameCallback → after the frame where Chewie is gone, dispose
///      ChewieController safely.
///   3. Another addPostFrameCallback → after ChewieController is gone, dispose
///      VideoPlayerController safely.
///
/// Additional guards:
///   • _initEpoch (generation counter) — cancels stale async inits on rapid scroll.
///   • _controllerValid flag — all .play()/.pause() calls gated behind it.
///   • Every setState / controller call checks mounted && !_isDisposed.
class LazyVideoTile extends StatefulWidget {
  final VideoItem videoItem;
  final int index;

  const LazyVideoTile({
    super.key,
    required this.videoItem,
    required this.index,
  });

  @override
  State<LazyVideoTile> createState() => LazyVideoTileState();
}

class LazyVideoTileState extends State<LazyVideoTile>
    with SingleTickerProviderStateMixin {
  // ── Controller references ──────────────────────────────────────────────────
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // ── State flags ────────────────────────────────────────────────────────────
  bool _initialized = false;
  bool _isDisposed = false; // widget.dispose() called
  bool _initInProgress = false;
  bool _teardownInProgress = false;

  /// Incremented each time we start a new init. Any async callback that sees
  /// a stale epoch knows it must discard its result.
  int _initEpoch = 0;

  /// True only when _videoController is initialised AND has not yet entered
  /// the teardown sequence. All play/pause calls are gated behind this.
  bool _controllerValid = false;

  /// True while the FullscreenVideoPage is on top of us. The fullscreen page
  /// shares our VideoPlayerController, so we MUST NOT tear it down — even if
  /// the grid tile behind it reports visibleFraction == 0.
  bool _inFullscreen = false;

  // ── Visibility (hysteresis) ────────────────────────────────────────────────
  double _visibilityFraction = 0.0;
  static const double _kPlayThreshold = 0.60;
  static const double _kPauseThreshold = 0.30;

  // ── Hover animation ────────────────────────────────────────────────────────
  late final AnimationController _hoverAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _overlayAnim;
  bool _isHovered = false;

  // ── Keys ───────────────────────────────────────────────────────────────────
  late final String _visibilityKey =
      'vt_${widget.index}_${widget.videoItem.assetPath.hashCode}';
  late final String _heroTag =
      'hero_${widget.index}_${widget.videoItem.assetPath.hashCode}';

  final VideoPlayerManager _manager = VideoPlayerManager.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _hoverAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _hoverAnim, curve: Curves.easeOut));
    _overlayAnim = Tween<double>(
      begin: 0.0,
      end: 0.38,
    ).animate(CurvedAnimation(parent: _hoverAnim, curve: Curves.easeOut));
    _manager.addListener(_onManagerChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _manager.removeListener(_onManagerChanged);
    _manager.clearActive(widget.index);
    _hoverAnim.dispose();
    // Synchronous teardown on final widget dispose — safe because Flutter
    // guarantees no further build/tap callbacks after dispose() returns.
    _controllerValid = false;
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════════════

  void pause() {
    if (_controllerValid) _videoController?.pause();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Manager listener
  // ═══════════════════════════════════════════════════════════════════════════

  void _onManagerChanged() {
    // No-op: multiple tiles in the grid may play simultaneously.
    // The manager is kept only for fullscreen/background coordination.
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Init — generation-counter guarded
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initVideo() async {
    if (_initialized || _isDisposed || _initInProgress || _teardownInProgress)
      return;
    _initInProgress = true;
    final epoch = ++_initEpoch; // capture THIS init's epoch

    if (mounted) setState(() {}); // show spinner

    final controller = VideoPlayerController.asset(widget.videoItem.assetPath);

    try {
      await controller.initialize();
    } catch (e) {
      debugPrint('[LazyVideoTile] init error: $e');
      controller.dispose();
      if (mounted && !_isDisposed && epoch == _initEpoch) {
        setState(() => _initInProgress = false);
      }
      return;
    }

    // Stale check: widget disposed OR a newer init has superseded this one
    if (_isDisposed || epoch != _initEpoch) {
      controller.dispose();
      return;
    }

    final chewie = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
      allowFullScreen: false, // fullscreen handled by our custom page
      allowMuting: true,
      showControls: false, // no controls in grid tile — tap opens fullscreen
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFF4C5E),
        handleColor: const Color(0xFFFF4C5E),
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
    );

    if (!mounted || _isDisposed || epoch != _initEpoch) {
      chewie.dispose();
      controller.dispose();
      return;
    }

    setState(() {
      _videoController = controller;
      _chewieController = chewie;
      _initialized = true;
      _initInProgress = false;
      _controllerValid = true;
    });

    _applyVisibility(); // play immediately if already in viewport
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THREE-PHASE teardown — the core fix for the crash
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Phase 1 (sync):  mark _controllerValid = false + null _chewieController
  //                  in state → Chewie widget leaves the tree on next build.
  //                  No more gesture callbacks can reach the controller.
  //
  // Phase 2 (post-frame 1): dispose ChewieController now that its widget
  //                  has been unmounted for one full frame.
  //
  // Phase 3 (post-frame 2): dispose VideoPlayerController now that
  //                  ChewieController (which held a reference) is gone.

  void _beginTeardown() {
    if (!_initialized || _teardownInProgress || _isDisposed) return;
    // Fullscreen page shares our VideoPlayerController — never dispose it
    // while the user is still interacting with the fullscreen Chewie.
    if (_inFullscreen) return;
    _teardownInProgress = true;

    // Increment epoch so any in-flight init knows to discard its result
    _initEpoch++;

    // Pause before we start removing things
    if (_controllerValid) _videoController?.pause();

    // Phase 1: stop all controller-touching widget code
    _controllerValid = false;
    final chewieToDispose = _chewieController;
    final videoToDispose = _videoController;

    setState(() {
      _chewieController = null; // Chewie widget removed from tree on next frame
      _videoController = null;
      _initialized = false;
      _initInProgress = false;
    });

    // Phase 2: after Chewie widget is unmounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chewieToDispose?.dispose();

      // Phase 3: after ChewieController is fully disposed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        videoToDispose?.dispose();
        if (mounted && !_isDisposed) {
          setState(() => _teardownInProgress = false);
        } else {
          _teardownInProgress = false;
        }
      });
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Visibility logic
  // ═══════════════════════════════════════════════════════════════════════════

  void _onVisibilityChanged(VisibilityInfo info) {
    _visibilityFraction = info.visibleFraction;
    _applyVisibility();
  }

  void _applyVisibility() {
    if (_isDisposed) return;
    final f = _visibilityFraction;

    if (f >= _kPlayThreshold) {
      if (!_initialized && !_initInProgress && !_teardownInProgress) {
        _initVideo();
      } else if (_initialized && _controllerValid) {
        _videoController?.play();
      }
    } else if (f < _kPauseThreshold) {
      if (_controllerValid) {
        _videoController?.pause();
      }
      // Full teardown only when completely off-screen
      if (f == 0.0 && _initialized && !_teardownInProgress) {
        _beginTeardown();
      }
    }
    // Hysteresis [0.30, 0.60): keep current state unchanged
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Hover / press
  // ═══════════════════════════════════════════════════════════════════════════

  void _onHoverEnter() {
    if (_isHovered) return;
    _isHovered = true;
    _hoverAnim.forward();
  }

  void _onHoverExit() {
    if (!_isHovered) return;
    _isHovered = false;
    _hoverAnim.reverse();
  }

  void _onLongPressStart(LongPressStartDetails _) => _onHoverEnter();
  void _onLongPressEnd(LongPressEndDetails _) {
    _onHoverExit();
    _openFullscreen();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Fullscreen
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _openFullscreen() async {
    // Guard: must be fully initialised and controller alive
    if (!_initialized || !_controllerValid || _videoController == null) return;

    // Pause grid tile for the duration of fullscreen
    _videoController!.pause();

    // Capture local ref — safe to pass to the page because _controllerValid
    // is still true and _inFullscreen prevents teardown until we pop.
    final vc = _videoController!;

    _inFullscreen = true;
    try {
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: FullscreenVideoPage(
              videoController: vc,
              heroTag: _heroTag,
              title: widget.videoItem.title,
              author: widget.videoItem.author,
            ),
          ),
        ),
      );
    } finally {
      _inFullscreen = false;
    }

    // Returned from fullscreen
    if (mounted &&
        !_isDisposed &&
        _controllerValid &&
        _visibilityFraction >= _kPlayThreshold) {
      _manager.setActive(widget.index);
      _videoController?.play();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: VisibilityDetector(
        key: Key(_visibilityKey),
        onVisibilityChanged: _onVisibilityChanged,
        child: MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _openFullscreen,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
            child: AnimatedBuilder(
              animation: _hoverAnim,
              // Passing child through AnimatedBuilder means the Chewie
              // subtree is built once and reused — NOT rebuilt each tick.
              builder: (context, child) => Transform.scale(
                scale: _scaleAnim.value,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child!,
                    if (_overlayAnim.value > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(_overlayAnim.value),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.open_in_full_rounded,
                              color: Colors.white70,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildVideoArea()),
          _buildTitleBar(),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    // Double-guard: both _initialized AND _controllerValid must be true.
    // _initialized can be true briefly during teardown phase 1 before
    // setState clears it — _controllerValid is cleared synchronously first.
    if (_initialized && _controllerValid && _chewieController != null) {
      return Hero(
        tag: _heroTag,
        flightShuttleBuilder: (_, animation, __, ___, ____) => FadeTransition(
          opacity: animation,
          // Safe: _controllerValid is still true during fullscreen transition
          child: VideoPlayer(_videoController!),
        ),
        child: Chewie(controller: _chewieController!),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      color: const Color(0xFF111111),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: Colors.white38, size: 13),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              widget.videoItem.author,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Icon(
            Icons.open_in_full_rounded,
            color: Colors.white24,
            size: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C2E), Color(0xFF0D0D0D)],
        ),
      ),
      child: Center(
        child: (_initInProgress || _teardownInProgress)
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF4C5E),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white.withOpacity(0.15),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scroll into view',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class VideoItem {
  final String assetPath;
  final String title;
  final String author;

  const VideoItem({
    required this.assetPath,
    required this.title,
    required this.author,
  });
}
