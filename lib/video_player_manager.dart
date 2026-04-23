import 'package:flutter/foundation.dart';

/// Singleton that tracks which video index is currently "active" (playing).
///
/// Tiles subscribe via [addListener] / [removeListener]. When a tile calls
/// [setActive], every other subscriber is notified so it can pause itself —
/// WITHOUT triggering a full grid rebuild (no setState on the grid).
class VideoPlayerManager extends ChangeNotifier {
  VideoPlayerManager._();
  static final VideoPlayerManager instance = VideoPlayerManager._();

  int? _activeIndex;

  int? get activeIndex => _activeIndex;

  /// Called by a tile when it wants to start playing.
  /// Returns [true] if permission granted (it was already active or no one else
  /// is active). The old active tile receives a notification and pauses itself.
  bool setActive(int index) {
    if (_activeIndex == index) return true;
    _activeIndex = index;
    notifyListeners(); // other tiles listen and self-pause
    return true;
  }

  /// Called when a tile is disposed or goes off-screen.
  void clearActive(int index) {
    if (_activeIndex == index) {
      _activeIndex = null;
      notifyListeners();
    }
  }

  /// Clears active index without notifying (used on background event —
  /// the VideoScreen pauses all directly via keys).
  void silentClear() {
    _activeIndex = null;
  }
}
