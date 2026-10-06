import "package:flutter/material.dart";

import "models/movie_models.dart";
import "pages/welcome_page.dart";
import "pages/home_movies_page.dart";
import "pages/explore_page.dart";
import "pages/watchlist_page.dart";
import "pages/movie_detail_page.dart";
import "pages/video_player_modal.dart";
import "pages/profile_settings_page.dart";
import "widgets/fluid_glass_bottom_bar.dart";

void main() {
  runApp(const NioooMovieApp());
}

class NioooMovieApp extends StatelessWidget {
  const NioooMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Niooo M",
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
  final Set<String> _watchlistIds = {
    "mov_solaris_protocol",
    "mov_emerald_syndicate",
  };

  bool _hasDismissedWelcome = false;
  int _activeNavIndex = 0; // 0: Home, 1: Explore, 2: Watchlist, 3: Profile
  MovieItem? _selectedMovieDetail;
  MovieItem? _playingMovie;

  String _streamQuality = "4K IMAX HDR";
  bool _dolbyAtmosEnabled = true;
  bool _autoplayTrailers = true;

  @override
  void initState() {
    super.initState();
    _movies = List<MovieItem>.from(MovieCatalogData.initialMovies);
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

  void _updateMovieProgress(String movieId, double progress) {
    setState(() {
      _movies = _movies.map((m) {
        if (m.id == movieId) {
          return m.copyWith(watchProgress: progress);
        }
        return m;
      }).toList();
      if (_selectedMovieDetail?.id == movieId) {
        _selectedMovieDetail =
            _selectedMovieDetail!.copyWith(watchProgress: progress);
      }
    });
  }

  void _addMovieReview(String movieId, double rating, String comment) {
    final newReview = MovieReview(
      id: "rev_${DateTime.now().millisecondsSinceEpoch}",
      authorName: "Niooo Cinema Member",
      authorHandle: "@niooo_vip",
      rating: rating,
      comment: comment,
      timeAgo: "Just now",
    );

    setState(() {
      _movies = _movies.map((m) {
        if (m.id == movieId) {
          final updatedReviews = [newReview, ...m.reviews];
          return m.copyWith(reviews: updatedReviews);
        }
        return m;
      }).toList();

      if (_selectedMovieDetail?.id == movieId) {
        _selectedMovieDetail = _selectedMovieDetail!.copyWith(
          reviews: [newReview, ..._selectedMovieDetail!.reviews],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hideBottomNav = !_hasDismissedWelcome ||
        _selectedMovieDetail != null ||
        _playingMovie != null;

    return Scaffold(
      backgroundColor: const Color(0xFF030706),
      body: Stack(
        children: [
          // Pitch-black cinema backdrop with deep emerald liquid ambient glows
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
          Positioned(
            top: -130,
            left: -110,
            child: IgnorePointer(
              child: Container(
                width: 480,
                height: 480,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E676).withValues(alpha: 0.20),
                      const Color(0xFF10B981).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -140,
            child: IgnorePointer(
              child: Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.16),
                      const Color(0xFF047857).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: !_hasDismissedWelcome
                ? WelcomePage(
                    onGetStarted: () =>
                        setState(() => _hasDismissedWelcome = true),
                  )
                : (_selectedMovieDetail != null
                    ? MovieDetailPage(
                        movie: _selectedMovieDetail!,
                        allMovies: _movies,
                        isBookmarked:
                            _watchlistIds.contains(_selectedMovieDetail!.id),
                        onBack: () =>
                            setState(() => _selectedMovieDetail = null),
                        onPlayMovie: (movie) =>
                            setState(() => _playingMovie = movie),
                        onToggleWatchlist: _toggleWatchlist,
                        onSelectRelatedMovie: (movie) =>
                            setState(() => _selectedMovieDetail = movie),
                        onAddReview: _addMovieReview,
                      )
                    : _buildActiveTabContent()),
          ),

          // Fluid Glass Bottom Navigation Bar
          if (!hideBottomNav)
            FluidGlassBottomBar(
              selectedIndex: _activeNavIndex,
              watchlistCount: _watchlistIds.length,
              onTabSelected: (idx) {
                setState(() {
                  _activeNavIndex = idx;
                  _selectedMovieDetail = null;
                });
              },
            ),

          // Full-Screen 4K Theater Player Modal
          if (_playingMovie != null)
            VideoPlayerModal(
              movie: _playingMovie!,
              onClose: () => setState(() => _playingMovie = null),
              onUpdateProgress: (p) =>
                  _updateMovieProgress(_playingMovie!.id, p),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    if (_activeNavIndex == 1) {
      return ExplorePage(
        movies: _movies,
        watchlistIds: _watchlistIds,
        onSelectMovie: (movie) => setState(() => _selectedMovieDetail = movie),
        onPlayMovie: (movie) => setState(() => _playingMovie = movie),
        onToggleWatchlist: _toggleWatchlist,
      );
    } else if (_activeNavIndex == 2) {
      return WatchlistPage(
        movies: _movies,
        watchlistIds: _watchlistIds,
        onSelectMovie: (movie) => setState(() => _selectedMovieDetail = movie),
        onPlayMovie: (movie) => setState(() => _playingMovie = movie),
        onToggleWatchlist: _toggleWatchlist,
        onExploreMovies: () => setState(() => _activeNavIndex = 1),
      );
    } else if (_activeNavIndex == 3) {
      final watchedCount = _movies.where((m) => m.watchProgress > 0.0).length;
      return ProfileSettingsPage(
        displayName: "Niooo Cinema VIP",
        handle: "@niooo_cinema",
        membershipTier: "IMAX 4K Unlimited",
        streamQuality: _streamQuality,
        dolbyAtmosEnabled: _dolbyAtmosEnabled,
        autoplayTrailers: _autoplayTrailers,
        watchlistCount: _watchlistIds.length,
        watchedCount: watchedCount,
        onQualityChanged: (q) => setState(() => _streamQuality = q),
        onToggleDolbyAtmos: (v) => setState(() => _dolbyAtmosEnabled = v),
        onToggleAutoplay: (v) => setState(() => _autoplayTrailers = v),
        onReturnToWelcome: () => setState(() => _hasDismissedWelcome = false),
      );
    }

    return HomeMoviesPage(
      movies: _movies,
      watchlistIds: _watchlistIds,
      onSelectMovie: (movie) => setState(() => _selectedMovieDetail = movie),
      onPlayMovie: (movie) => setState(() => _playingMovie = movie),
      onToggleWatchlist: _toggleWatchlist,
      onOpenSearch: () => setState(() => _activeNavIndex = 1),
    );
  }
}
