import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "models/movie_models.dart";
import "pages/welcome_page.dart";
import "pages/home_movies_page.dart";
import "pages/explore_page.dart";
import "pages/watchlist_page.dart";
import "pages/profile_settings_page.dart";
import "pages/movie_player_page.dart";
import "widgets/fluid_glass_bottom_bar.dart";

import "dart:ui";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    // Prevent uncaught rendering/network image errors from crashing the runtime
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };
  runApp(const NioooMovieApp());
}

class NioooMovieApp extends StatelessWidget {
  const NioooMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "niooo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030706),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E676),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFF0A1412).withValues(alpha: 0.72),
        ),
        fontFamily: "Roboto",
        useMaterial3: true,
      ),
      home: const NioooCinemaMainScreen(),
    );
  }
}

/// Snapshot of a single screen/page state in the navigation history stack
/// so pressing Back steps through every visited movie, page, and tab smoothly.
class _NavHistorySnapshot {
  final int navIndex;
  final String? playingMovieId;
  final bool isFullScreenAdminOpen;
  final bool hasDismissedWelcome;

  const _NavHistorySnapshot({
    required this.navIndex,
    required this.playingMovieId,
    required this.isFullScreenAdminOpen,
    required this.hasDismissedWelcome,
  });

  bool matches(_NavHistorySnapshot other) {
    return navIndex == other.navIndex &&
        playingMovieId == other.playingMovieId &&
        isFullScreenAdminOpen == other.isFullScreenAdminOpen &&
        hasDismissedWelcome == other.hasDismissedWelcome;
  }
}

class NioooCinemaMainScreen extends StatefulWidget {
  const NioooCinemaMainScreen({super.key});

  @override
  State<NioooCinemaMainScreen> createState() => _NioooCinemaMainScreenState();
}

class _NioooCinemaMainScreenState extends State<NioooCinemaMainScreen>
    with WidgetsBindingObserver {
  late List<MovieItem> _movies;
  final Set<String> _likedMovieIds = {"Zk2Rbvkpl9tqzjD", "MPDylDpxp9h0Jr"};
  final Set<String> _watchlistIds = {
    "Zk2Rbvkpl9tqzjD",
    "MPDylDpxp9h0Jr",
    "kwa24xVPj7FOVWm",
  };

  bool _hasDismissedWelcome =
      true; // Direct movie platform access without mandatory login
  bool _isSyncingStreamtape = false;
  bool _isFullScreenAdminOpen = false;
  int _activeNavIndex = 0; // 0: Home, 1: Explore, 2: Watchlist, 3: Profile
  String? _activePlayingMovieId;
  Timer? _catalogAutoSyncTimer;

  // Navigation history stack for sequential, smooth back-navigation
  final List<_NavHistorySnapshot> _backHistoryStack = [];
  DateTime? _lastRootBackPressTime;

  String _streamQuality = "4K IMAX HDR";
  bool _dolbyAtmosEnabled = true;
  bool _autoplayTrailers = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthBridgeService.instance.init();
    _movies = MovieCatalogData.initialMovies
        .map(
          (m) => m.copyWith(
            posterUrl: MovieItem.sanitizeWebImageUrl(m.posterUrl),
            backdropUrl: MovieItem.sanitizeWebImageUrl(m.backdropUrl),
          ),
        )
        .toList();
    _syncFromStreamtapeAccount(forceRefresh: true);

    // Automatically poll for new movies added to the server or Streamtape account
    _catalogAutoSyncTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _syncFromStreamtapeAccount(forceRefresh: true),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _catalogAutoSyncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncFromStreamtapeAccount(forceRefresh: true);
    }
  }

  _NavHistorySnapshot get _currentSnapshot => _NavHistorySnapshot(
        navIndex: _activeNavIndex,
        playingMovieId: _activePlayingMovieId,
        isFullScreenAdminOpen: _isFullScreenAdminOpen,
        hasDismissedWelcome: _hasDismissedWelcome,
      );

  void _pushCurrentStateToHistory() {
    final snap = _currentSnapshot;
    if (_backHistoryStack.isEmpty || !_backHistoryStack.last.matches(snap)) {
      _backHistoryStack.add(snap);
      if (_backHistoryStack.length > 40) {
        _backHistoryStack.removeAt(0);
      }
    }
  }

  /// Navigates to a new state while recording the current state onto the history stack
  void _navigateTo({
    int? navIndex,
    String? playingMovieId,
    bool clearPlayingMovie = false,
    bool? isFullScreenAdminOpen,
    bool? hasDismissedWelcome,
  }) {
    final targetNavIndex = navIndex ?? _activeNavIndex;
    final targetMovieId =
        clearPlayingMovie ? null : (playingMovieId ?? _activePlayingMovieId);
    final targetAdmin = isFullScreenAdminOpen ?? _isFullScreenAdminOpen;
    final targetWelcome = hasDismissedWelcome ?? _hasDismissedWelcome;

    final nextSnap = _NavHistorySnapshot(
      navIndex: targetNavIndex,
      playingMovieId: targetMovieId,
      isFullScreenAdminOpen: targetAdmin,
      hasDismissedWelcome: targetWelcome,
    );

    if (_currentSnapshot.matches(nextSnap)) return;

    setState(() {
      _pushCurrentStateToHistory();
      _activeNavIndex = targetNavIndex;
      _activePlayingMovieId = targetMovieId;
      _isFullScreenAdminOpen = targetAdmin;
      _hasDismissedWelcome = targetWelcome;
    });
  }

  /// Handles hardware/gesture Back button and in-app Back actions sequentially & smoothly
  bool _handleSequentialBack() {
    // 1. If there are previous states in our navigation history stack, pop one by one
    while (_backHistoryStack.isNotEmpty) {
      final previous = _backHistoryStack.removeLast();
      if (!previous.matches(_currentSnapshot)) {
        setState(() {
          _activeNavIndex = previous.navIndex;
          _activePlayingMovieId = previous.playingMovieId;
          _isFullScreenAdminOpen = previous.isFullScreenAdminOpen;
          _hasDismissedWelcome = previous.hasDismissedWelcome;
        });
        return true;
      }
    }

    // 2. Fallback safety checks if history stack is empty but user is not on Home tab
    if (_isFullScreenAdminOpen) {
      setState(() => _isFullScreenAdminOpen = false);
      return true;
    }
    if (_activePlayingMovieId != null) {
      setState(() => _activePlayingMovieId = null);
      return true;
    }
    if (!_hasDismissedWelcome) {
      setState(() => _hasDismissedWelcome = true);
      return true;
    }
    if (_activeNavIndex != 0) {
      setState(() => _activeNavIndex = 0);
      return true;
    }

    //Already at root Home screen
    return false;
  }

  void _onSystemPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return;

    // Step back smoothly to the previous screen/movie/tab if available
    final steppedBack = _handleSequentialBack();
    if (steppedBack) {
      return;
    }

    // On Root Home screen: require double-back within 2 seconds before exiting app
    final now = DateTime.now();
    if (_lastRootBackPressTime == null ||
        now.difference(_lastRootBackPressTime!) > const Duration(seconds: 2)) {
      _lastRootBackPressTime = now;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF071A14),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 90),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: const Color(0xFF00E676).withValues(alpha: 0.45),
            ),
          ),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFF00E676),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Press back again to exit Niooo M",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    SystemNavigator.pop();
  }

  Future<void> _syncFromStreamtapeAccount({bool forceRefresh = true}) async {
    if (_isSyncingStreamtape) return;
    setState(() => _isSyncingStreamtape = true);
    final liveCatalog = await MovieCatalogData.fetchLiveStreamtapeCatalog(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    setState(() {
      _movies = liveCatalog;
      _isSyncingStreamtape = false;
    });
  }

  MovieItem? get _activePlayingMovie {
    if (_activePlayingMovieId == null) return null;
    for (final m in _movies) {
      if (m.id == _activePlayingMovieId) return m;
    }
    return null;
  }

  void _openMoviePlayer(MovieItem movie) {
    _navigateTo(
      playingMovieId: movie.id,
      isFullScreenAdminOpen: false,
    );
  }

  void _upsertMovieLocally(MovieItem updatedMovie) {
    setState(() {
      final idx = _movies.indexWhere((m) => m.id == updatedMovie.id);
      if (idx >= 0) {
        _movies[idx] = updatedMovie;
      } else {
        _movies = [updatedMovie, ..._movies];
      }
    });
  }

  void _deleteMovieLocally(String movieId) {
    setState(() {
      _movies = _movies.where((m) => m.id != movieId).toList();
    });
  }

  void _toggleLikeMovie(String movieId) {
    setState(() {
      final isCurrentlyLiked = _likedMovieIds.contains(movieId);
      if (isCurrentlyLiked) {
        _likedMovieIds.remove(movieId);
      } else {
        _likedMovieIds.add(movieId);
      }

      _movies = _movies.map((m) {
        if (m.id != movieId) return m;
        final updatedLikes =
            isCurrentlyLiked ? (m.likesCount - 1) : (m.likesCount + 1);
        return m.copyWith(likesCount: updatedLikes < 0 ? 0 : updatedLikes);
      }).toList();
    });
  }

  void _toggleWatchlist(String movieId) {
    setState(() {
      if (_watchlistIds.contains(movieId)) {
        _watchlistIds.remove(movieId);
      } else {
        _watchlistIds.add(movieId);
      }
    });
  }

  void _incrementShareCount(String movieId) {
    setState(() {
      _movies = _movies.map((m) {
        if (m.id != movieId) return m;
        return m.copyWith(sharesCount: m.sharesCount + 1);
      }).toList();
    });
  }

  void _addCommentToMovie(String movieId, String commentText) {
    final trimmed = commentText.trim();
    if (trimmed.isEmpty) return;

    final user = AuthBridgeService.instance.user;
    final newComment = MovieComment(
      id: "c_${DateTime.now().millisecondsSinceEpoch}",
      authorName: user?.displayName ?? "Cinema Viewer",
      authorHandle: user?.handle ?? "@niooo_viewer",
      avatarUrl: user?.avatarUrl.isNotEmpty == true
          ? user!.avatarUrl
          : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
      comment: trimmed,
      timeAgo: "Just now",
      likes: 1,
    );

    setState(() {
      _movies = _movies.map((m) {
        if (m.id != movieId) return m;
        return m.copyWith(
          comments: [newComment, ...m.comments],
        );
      }).toList();
    });
  }

  void _updateMovieProgress(String movieId, double ratio) {
    if (ratio <= 0.02) return;
    setState(() {
      _movies = _movies.map((m) {
        if (m.id != movieId) return m;
        return m.copyWith(watchProgress: ratio.clamp(0.05, 0.98));
      }).toList();
    });
  }

  String get _currentViewAnimationKey {
    if (!_hasDismissedWelcome) return "welcome";
    if (_isFullScreenAdminOpen) return "admin_panel";
    if (_activePlayingMovieId != null) return "player_$_activePlayingMovieId";
    return "tab_$_activeNavIndex";
  }

  @override
  Widget build(BuildContext context) {
    final activeMovie = _activePlayingMovie;
    final bool hideBottomNav =
        !_hasDismissedWelcome || activeMovie != null || _isFullScreenAdminOpen;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onSystemPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: const Color(0xFF030706),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Deep pitch-black and emerald cinema backdrop
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF020504),
                      Color(0xFF05100D),
                      Color(0xFF020403),
                    ],
                  ),
                ),
              ),
            ),
            // Top-left luminous emerald aurora orb
            Positioned(
              top: -130,
              left: -110,
              child: IgnorePointer(
                child: Container(
                  width: 460,
                  height: 460,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00E676).withValues(alpha: 0.18),
                        const Color(0xFF10B981).withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Center-right soft liquid teal-emerald glow
            Positioned(
              top: 200,
              right: -140,
              child: IgnorePointer(
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.15),
                        const Color(0xFF047857).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Full-Screen Edge-to-Edge Body Content with Smooth Animated Transitions
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.03, 0.0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(
                      position: slide,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>(_currentViewAnimationKey),
                  child: !_hasDismissedWelcome
                      ? WelcomePage(
                          onGetStarted: () => _navigateTo(
                            hasDismissedWelcome: true,
                          ),
                        )
                      : _isFullScreenAdminOpen
                          ? FullScreenAdminPanelPage(
                              movies: _movies,
                              adminEmail:
                                  AuthBridgeService.instance.user?.email ??
                                      "mdsaiqulislamraihan72@gmail.com",
                              onClose: () => _handleSequentialBack(),
                              onRefreshCatalog: () =>
                                  _syncFromStreamtapeAccount(
                                      forceRefresh: true),
                              onPlayMovie: _openMoviePlayer,
                              onUpdateMovieLocally: _upsertMovieLocally,
                              onDeleteMovieLocally: _deleteMovieLocally,
                            )
                          : (activeMovie != null
                              ? MoviePlayerPage(
                                  movie: activeMovie,
                                  allMovies: _movies,
                                  isLiked:
                                      _likedMovieIds.contains(activeMovie.id),
                                  isBookmarked:
                                      _watchlistIds.contains(activeMovie.id),
                                  onBack: () => _handleSequentialBack(),
                                  onToggleLike: () =>
                                      _toggleLikeMovie(activeMovie.id),
                                  onToggleBookmark: () =>
                                      _toggleWatchlist(activeMovie.id),
                                  onShareMovie: () =>
                                      _incrementShareCount(activeMovie.id),
                                  onAddComment: (comment) =>
                                      _addCommentToMovie(
                                          activeMovie.id, comment),
                                  onSelectOtherMovie: (nextMovie) =>
                                      _openMoviePlayer(nextMovie),
                                  onUpdateProgress: (ratio) =>
                                      _updateMovieProgress(
                                          activeMovie.id, ratio),
                                )
                              : _buildTabContent()),
                ),
              ),
            ),

            // Floating Liquid Glass Bottom Bar when browsing catalog tabs
            if (!hideBottomNav)
              FluidGlassBottomBar(
                selectedIndex: _activeNavIndex,
                unreadChatsCount: _watchlistIds.length,
                onTabSelected: (index) {
                  _navigateTo(
                    navIndex: index,
                    clearPlayingMovie: true,
                    isFullScreenAdminOpen: false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_activeNavIndex == 1) {
      return ExplorePage(
        movies: _movies,
        watchlistIds: _watchlistIds,
        onPlayMovie: _openMoviePlayer,
        onToggleWatchlist: _toggleWatchlist,
      );
    } else if (_activeNavIndex == 2) {
      return WatchlistPage(
        movies: _movies,
        watchlistIds: _watchlistIds,
        onPlayMovie: _openMoviePlayer,
        onToggleWatchlist: _toggleWatchlist,
        onExploreMovies: () => _navigateTo(navIndex: 1),
      );
    } else if (_activeNavIndex == 3) {
      final watchedCount =
          _movies.where((m) => m.watchProgress > 0.05).length;
      return ProfileSettingsPage(
        movies: _movies,
        displayName: "Raihan Cinema",
        handle: "@niooo_m",
        membershipTier: "IMAX 4K VIP",
        streamQuality: _streamQuality,
        dolbyAtmosEnabled: _dolbyAtmosEnabled,
        autoplayTrailers: _autoplayTrailers,
        watchlistCount: _watchlistIds.length,
        watchedCount: watchedCount,
        onQualityChanged: (q) => setState(() => _streamQuality = q),
        onToggleDolbyAtmos: (v) => setState(() => _dolbyAtmosEnabled = v),
        onToggleAutoplay: (v) => setState(() => _autoplayTrailers = v),
        onReturnToWelcome: () => _navigateTo(hasDismissedWelcome: false),
        onOpenFullScreenAdminPanel: () =>
            _navigateTo(isFullScreenAdminOpen: true),
      );
    }

    return HomeMoviesPage(
      movies: _movies,
      watchlistIds: _watchlistIds,
      isSyncingStreamtape: _isSyncingStreamtape,
      onPlayMovie: _openMoviePlayer,
      onToggleWatchlist: _toggleWatchlist,
      onOpenSearch: () => _navigateTo(navIndex: 1),
      onRefreshStreamtape: () =>
          _syncFromStreamtapeAccount(forceRefresh: true),
    );
  }
}
