import "package:flutter/material.dart";

import "models/movie_models.dart";
import "pages/welcome_page.dart";
import "pages/home_movies_page.dart";
import "pages/explore_page.dart";
import "pages/watchlist_page.dart";
import "pages/profile_settings_page.dart";
import "pages/movie_player_page.dart";
import "widgets/fluid_glass_bottom_bar.dart";

void main() {
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

class NioooCinemaMainScreen extends StatefulWidget {
  const NioooCinemaMainScreen({super.key});

  @override
  State<NioooCinemaMainScreen> createState() => _NioooCinemaMainScreenState();
}

class _NioooCinemaMainScreenState extends State<NioooCinemaMainScreen> {
  late List<MovieItem> _movies;
  final Set<String> _likedMovieIds = {"Zk2Rbvkpl9tqzjD", "MPDylDpxp9h0Jr"};
  final Set<String> _watchlistIds = {
    "Zk2Rbvkpl9tqzjD",
    "MPDylDpxp9h0Jr",
    "kwa24xVPj7FOVWm",
  };

  bool _hasDismissedWelcome = true; // Direct movie platform access without mandatory login
  bool _isSyncingStreamtape = false;
  bool _isFullScreenAdminOpen = false;
  int _activeNavIndex = 0; // 0: Home, 1: Explore, 2: Watchlist, 3: Profile
  String? _activePlayingMovieId;

  String _streamQuality = "4K IMAX HDR";
  bool _dolbyAtmosEnabled = true;
  bool _autoplayTrailers = true;

  @override
  void initState() {
    super.initState();
    AuthBridgeService.instance.init();
    _movies = List<MovieItem>.from(MovieCatalogData.initialMovies);
    _syncFromStreamtapeAccount(forceRefresh: false);
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
    setState(() {
      _isFullScreenAdminOpen = false;
      _activePlayingMovieId = movie.id;
    });
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

  @override
  Widget build(BuildContext context) {
    final activeMovie = _activePlayingMovie;
    final bool hideBottomNav =
        !_hasDismissedWelcome || activeMovie != null || _isFullScreenAdminOpen;

    return Scaffold(
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

          // Full-Screen Edge-to-Edge Body Content
          SafeArea(
            child: !_hasDismissedWelcome
                ? WelcomePage(
                    onGetStarted: () =>
                        setState(() => _hasDismissedWelcome = true),
                  )
                : _isFullScreenAdminOpen
                    ? FullScreenAdminPanelPage(
                        movies: _movies,
                        adminEmail: AuthBridgeService.instance.user?.email ??
                            "mdsaiqulislamraihan72@gmail.com",
                        onClose: () =>
                            setState(() => _isFullScreenAdminOpen = false),
                        onRefreshCatalog: () =>
                            _syncFromStreamtapeAccount(forceRefresh: true),
                        onPlayMovie: _openMoviePlayer,
                        onUpdateMovieLocally: _upsertMovieLocally,
                        onDeleteMovieLocally: _deleteMovieLocally,
                      )
                    : (activeMovie != null
                        ? MoviePlayerPage(
                            movie: activeMovie,
                            allMovies: _movies,
                            isLiked: _likedMovieIds.contains(activeMovie.id),
                            isBookmarked:
                                _watchlistIds.contains(activeMovie.id),
                            onBack: () =>
                                setState(() => _activePlayingMovieId = null),
                            onToggleLike: () =>
                                _toggleLikeMovie(activeMovie.id),
                            onToggleBookmark: () =>
                                _toggleWatchlist(activeMovie.id),
                            onShareMovie: () =>
                                _incrementShareCount(activeMovie.id),
                            onAddComment: (comment) =>
                                _addCommentToMovie(activeMovie.id, comment),
                            onSelectOtherMovie: (nextMovie) =>
                                _openMoviePlayer(nextMovie),
                            onUpdateProgress: (ratio) =>
                                _updateMovieProgress(activeMovie.id, ratio),
                          )
                        : _buildTabContent()),
          ),

          // Floating Liquid Glass Bottom Bar when browsing catalog tabs
          if (!hideBottomNav)
            FluidGlassBottomBar(
              selectedIndex: _activeNavIndex,
              unreadChatsCount: _watchlistIds.length,
              onTabSelected: (index) {
                setState(() {
                  _activeNavIndex = index;
                });
              },
            ),
        ],
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
        onExploreMovies: () => setState(() => _activeNavIndex = 1),
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
        onReturnToWelcome: () => setState(() => _hasDismissedWelcome = false),
        onOpenFullScreenAdminPanel: () =>
            setState(() => _isFullScreenAdminOpen = true),
      );
    }

    return HomeMoviesPage(
      movies: _movies,
      watchlistIds: _watchlistIds,
      isSyncingStreamtape: _isSyncingStreamtape,
      onPlayMovie: _openMoviePlayer,
      onToggleWatchlist: _toggleWatchlist,
      onOpenSearch: () => setState(() => _activeNavIndex = 1),
      onRefreshStreamtape: () =>
          _syncFromStreamtapeAccount(forceRefresh: true),
    );
  }
}
