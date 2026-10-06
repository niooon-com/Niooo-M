// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;
import "dart:async";
import "dart:ui" as ui;
// ignore: undefined_prefixed_name
import "dart:ui_web" as ui_web;
import "package:flutter/material.dart";
import "../models/movie_models.dart";
import "../widgets/glass_container.dart";

class MoviePlayerPage extends StatefulWidget {
  final MovieItem movie;
  final List<MovieItem> allMovies;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShareMovie;
  final ValueChanged<String> onAddComment;
  final ValueChanged<MovieItem> onSelectOtherMovie;
  final ValueChanged<double> onUpdateProgress;

  const MoviePlayerPage({
    super.key,
    required this.movie,
    required this.allMovies,
    required this.isLiked,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onShareMovie,
    required this.onAddComment,
    required this.onSelectOtherMovie,
    required this.onUpdateProgress,
  });

  @override
  State<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends State<MoviePlayerPage> {
  html.VideoElement? _videoElement;
  late String _embedViewType;
  String? _directVideoViewType;

  bool _useDirectStream = false;
  bool _isResolvingDirect = false;
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _showControls = true;
  double _currentSeconds = 0.0;
  double _totalSeconds = 100.0;
  Timer? _hideControlsTimer;
  Timer? _progressPollTimer;

  bool _showCommentsDrawer = false;
  bool _showShareBanner = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initStreamtapePlayer(widget.movie);
  }

  @override
  void didUpdateWidget(covariant MoviePlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.id != widget.movie.id) {
      _disposeVideo();
      _initStreamtapePlayer(widget.movie);
    }
  }

  void _initStreamtapePlayer(MovieItem movie) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    _embedViewType = "niooo-st-embed-${movie.id}-$timestamp";
    _useDirectStream = false;
    _isResolvingDirect = true;

    final embedSrc = movie.embedUrl.isNotEmpty
        ? movie.embedUrl
        : "https://streamtape.com/e/${movie.id}";

    final iframe = html.IFrameElement()
      ..src = embedSrc
      ..style.border = "none"
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.backgroundColor = "#000000"
      ..allowFullscreen = true
      ..allow =
          "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen";

    ui_web.platformViewRegistry.registerViewFactory(
      _embedViewType,
      (int viewId) => iframe,
    );

    // Also resolve direct MP4 stream via Streamtape API (/api/streamtape/direct)
    MovieCatalogData.resolveDirectStreamUrl(movie.id).then((directUrl) {
      if (!mounted || widget.movie.id != movie.id) return;
      setState(() => _isResolvingDirect = false);
      if (directUrl != null && directUrl.startsWith("http")) {
        _setupDirectHtml5Video(movie, directUrl);
      }
    });
  }

  void _setupDirectHtml5Video(MovieItem movie, String directMp4Url) {
    final viewType =
        "niooo-st-direct-${movie.id}-${DateTime.now().microsecondsSinceEpoch}";

    final video = html.VideoElement()
      ..src = directMp4Url
      ..poster = movie.backdropUrl
      ..autoplay = false
      ..controls = false
      ..loop = false
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.objectFit = "contain"
      ..style.backgroundColor = "#000000"
      ..setAttribute("playsinline", "true")
      ..setAttribute("webkit-playsinline", "true");

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => video,
    );

    video.onLoadedMetadata.listen((_) {
      if (!mounted) return;
      final dur = video.duration;
      if (!dur.isNaN && !dur.isInfinite && dur > 0) {
        setState(() {
          _totalSeconds = dur.toDouble();
        });
      }
    });

    video.onPlay.listen((_) {
      if (!mounted) return;
      setState(() => _isPlaying = true);
    });

    video.onPause.listen((_) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    });

    setState(() {
      _videoElement = video;
      _directVideoViewType = viewType;
    });
  }

  void _switchToDirectPlayer() {
    if (_directVideoViewType == null || _videoElement == null) return;
    setState(() {
      _useDirectStream = true;
      _showControls = true;
    });
    _videoElement!.play().catchError((_) {
      _videoElement!.muted = true;
      if (mounted) setState(() => _isMuted = true);
      return _videoElement!.play();
    });

    _progressPollTimer?.cancel();
    _progressPollTimer =
        Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted || _videoElement == null) return;
      final cur = _videoElement!.currentTime.toDouble();
      final dur = _videoElement!.duration.toDouble();
      if (!cur.isNaN) {
        setState(() {
          _currentSeconds = cur;
          if (!dur.isNaN && !dur.isInfinite && dur > 0) {
            _totalSeconds = dur;
          }
        });
      }
    });

    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _scheduleHideControls();
    }
  }

  void _togglePlayPause() {
    final v = _videoElement;
    if (v == null) return;
    if (v.paused) {
      v.play();
      setState(() => _isPlaying = true);
      _scheduleHideControls();
    } else {
      v.pause();
      setState(() => _isPlaying = false);
    }
  }

  void _seekRelative(double deltaSeconds) {
    final v = _videoElement;
    if (v == null) return;
    final target = (_currentSeconds + deltaSeconds).clamp(0.0, _totalSeconds);
    v.currentTime = target;
    setState(() => _currentSeconds = target);
    _scheduleHideControls();
  }

  void _toggleMute() {
    final v = _videoElement;
    if (v == null) return;
    v.muted = !v.muted;
    setState(() => _isMuted = v.muted);
  }

  void _requestFullscreen() {
    final v = _videoElement;
    if (v == null) return;
    try {
      v.requestFullscreen();
    } catch (_) {}
  }

  void _disposeVideo() {
    _hideControlsTimer?.cancel();
    _progressPollTimer?.cancel();
    if (_videoElement != null && _totalSeconds > 0) {
      final ratio = (_currentSeconds / _totalSeconds).clamp(0.0, 1.0);
      widget.onUpdateProgress(ratio);
    }
    _videoElement?.pause();
    _videoElement?.src = "";
    _videoElement = null;
    _directVideoViewType = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    _commentController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return "00:00";
    final int total = seconds.round();
    final int mins = total ~/ 60;
    final int secs = total % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  String _formatCompactCount(int n) {
    if (n >= 1000000) {
      return "${(n / 1000000).toStringAsFixed(1)}M";
    }
    if (n >= 1000) {
      return "${(n / 1000).toStringAsFixed(1)}K";
    }
    return "$n";
  }

  void _handleShareTap() {
    widget.onShareMovie();
    try {
      html.window.navigator.clipboard?.writeText(
        "https://streamtape.com/v/${widget.movie.id}",
      );
    } catch (_) {}
    setState(() => _showShareBanner = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showShareBanner = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    // Group same-series episodes if this movie is part of a multi-episode series
    final sameSeriesEpisodes = movie.episodeNumber > 0
        ? (widget.allMovies
            .where((m) =>
                m.seriesName.toLowerCase() ==
                    movie.seriesName.toLowerCase() &&
                m.episodeNumber > 0)
            .toList()
          ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber)))
        : <MovieItem>[];

    final otherMovies =
        widget.allMovies.where((m) => m.id != movie.id).toList();

    final double progressRatio = _totalSeconds > 0
        ? (_currentSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: const Color(0xFF030706),
      child: Column(
        children: [
          // ==============================================================
          // 1. HEADERLESS EDGE-TO-EDGE STREAMTAPE VIDEO PLAYER AT VERY TOP
          // ==============================================================
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!_useDirectStream)
                    // Official Streamtape Cloud Embed Player
                    HtmlElementView(viewType: _embedViewType)
                  else if (_directVideoViewType != null)
                    // Direct Streamtape MP4 Stream with Custom Glass Controls
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        HtmlElementView(viewType: _directVideoViewType!),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleControlsVisibility,
                          child: AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 220),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.black.withValues(alpha: 0.78),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _playerCircleControl(
                                          icon: Icons.replay_10_rounded,
                                          size: 42,
                                          onTap: () => _seekRelative(-10),
                                        ),
                                        const SizedBox(width: 24),
                                        GestureDetector(
                                          onTap: _togglePlayPause,
                                          child: Container(
                                            width: 58,
                                            height: 58,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF00E676),
                                                  Color(0xFF10B981),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.75),
                                                width: 1.4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      const Color(0xFF00E676)
                                                          .withValues(
                                                              alpha: 0.55),
                                                  blurRadius: 20,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: const Color(0xFF03120D),
                                              size: 34,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        _playerCircleControl(
                                          icon: Icons.forward_10_rounded,
                                          size: 42,
                                          onTap: () => _seekRelative(10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 6,
                                    child: Row(
                                      children: [
                                        Text(
                                          _formatTime(_currentSeconds),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              trackHeight: 3.0,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                enabledThumbRadius: 6.0,
                                              ),
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                overlayRadius: 12.0,
                                              ),
                                            ),
                                            child: Slider(
                                              value: progressRatio,
                                              activeColor:
                                                  const Color(0xFF00E676),
                                              inactiveColor: Colors.white30,
                                              onChanged: (v) {
                                                final target =
                                                    v * _totalSeconds;
                                                _videoElement?.currentTime =
                                                    target;
                                                setState(() =>
                                                    _currentSeconds = target);
                                                _scheduleHideControls();
                                              },
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatTime(_totalSeconds),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: _toggleMute,
                                          child: Icon(
                                            _isMuted
                                                ? Icons.volume_off_rounded
                                                : Icons.volume_up_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: _requestFullscreen,
                                          child: const Icon(
                                            Icons.fullscreen_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
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

                  // Subtle floating minimize button on top-left (no header bar!)
                  Positioned(
                    top: 10,
                    left: 12,
                    child: GestureDetector(
                      onTap: widget.onBack,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter:
                              ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.62),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Streamtape Direct / Cloud Mode Toggle Pill on Top-Right
                  Positioned(
                    top: 10,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (!_useDirectStream &&
                            _directVideoViewType != null) {
                          _switchToDirectPlayer();
                        } else if (_useDirectStream) {
                          _videoElement?.pause();
                          setState(() => _useDirectStream = false);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter:
                              ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _useDirectStream
                                      ? Icons.bolt_rounded
                                      : Icons.cloud_done_rounded,
                                  color: const Color(0xFF00E676),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _useDirectStream
                                      ? "Direct MP4"
                                      : (_directVideoViewType != null
                                          ? "Streamtape HD · Switch Direct"
                                          : (_isResolvingDirect
                                              ? "Streamtape Cloud"
                                              : "Streamtape HD")),
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==============================================================
          // 2. BELOW VIDEO PLAYER: TITLE, LIKE / COMMENT / SHARE BAR, EPISODES & OTHER MOVIES
          // ==============================================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
              children: [
                // Movie Title + Views & Streamtape Metadata
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Color(0xFFF0FDF4),
                    fontSize: 20.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "${movie.viewsLabel} · ${movie.releaseYear} · ${movie.duration} · ${movie.genres.join(' • ')}",
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00E676).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              const Color(0xFF00E676).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        "★ ${movie.rating} · ${movie.qualityBadge}",
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==========================================================
                // INTERACTIVE LIKE, COMMENT, SHARE & WATCHLIST ACTION BAR
                // ==========================================================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 1. LIKE BUTTON
                      _buildActionPill(
                        icon: widget.isLiked
                            ? Icons.thumb_up_alt_rounded
                            : Icons.thumb_up_off_alt_rounded,
                        label:
                            "Like · ${_formatCompactCount(movie.likesCount)}",
                        isActive: widget.isLiked,
                        onTap: widget.onToggleLike,
                      ),
                      const SizedBox(width: 10),

                      // 2. COMMENT BUTTON
                      _buildActionPill(
                        icon: Icons.mode_comment_outlined,
                        label: "Comment (${movie.comments.length})",
                        isActive: _showCommentsDrawer,
                        onTap: () => setState(
                          () => _showCommentsDrawer = !_showCommentsDrawer,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 3. SHARE BUTTON
                      _buildActionPill(
                        icon: Icons.reply_rounded,
                        label:
                            "Share · ${_formatCompactCount(movie.sharesCount)}",
                        isActive: _showShareBanner,
                        onTap: _handleShareTap,
                      ),
                      const SizedBox(width: 10),

                      // 4. SAVE TO WATCHLIST BUTTON
                      _buildActionPill(
                        icon: widget.isBookmarked
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_outlined,
                        label: widget.isBookmarked ? "Saved" : "Watchlist",
                        isActive: widget.isBookmarked,
                        onTap: widget.onToggleBookmark,
                      ),
                    ],
                  ),
                ),

                if (_showShareBanner) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00E676),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Streamtape movie link copied to clipboard!",
                            style: TextStyle(
                              color: Color(0xFFF0FDF4),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ==========================================================
                // SERIES EPISODES SELECTOR (IF WATCHING A SERIES LIKE OUR STICKY LOVE / OPERATION SAFED SAGAR)
                // ==========================================================
                if (sameSeriesEpisodes.length > 1) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00E676).withValues(alpha: 0.10),
                          const Color(0xFF071512).withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.video_library_rounded,
                              color: Color(0xFF00E676),
                              size: 17,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "${movie.seriesName} — All Episodes (${sameSeriesEpisodes.length})",
                                style: const TextStyle(
                                  color: Color(0xFFF0FDF4),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sameSeriesEpisodes.map((ep) {
                            final isCurrent = ep.id == movie.id;
                            return GestureDetector(
                              onTap: () {
                                if (!isCurrent) {
                                  widget.onSelectOtherMovie(ep);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isCurrent
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF00E676),
                                            Color(0xFF10B981),
                                          ],
                                        )
                                      : null,
                                  color: isCurrent
                                      ? null
                                      : Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.white70
                                        : const Color(0xFF00E676)
                                            .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  "EP ${ep.episodeNumber.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: isCurrent
                                        ? const Color(0xFF03120D)
                                        : const Color(0xFFF0FDF4),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Expandable / Interactive Comments Box right below the Action Bar
                GestureDetector(
                  onTap: () => setState(
                    () => _showCommentsDrawer = !_showCommentsDrawer,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          const Color(0xFF091613).withValues(alpha: 0.78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Comments",
                              style: TextStyle(
                                color: Color(0xFFF0FDF4),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${movie.comments.length}",
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _showCommentsDrawer
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                        if (!_showCommentsDrawer) ...[
                          const SizedBox(height: 6),
                          Text(
                            movie.comments.isNotEmpty
                                ? '${movie.comments.first.authorName}: "${movie.comments.first.comment}"'
                                : "Tap to write the first comment on this movie...",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12.5,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF050E0C),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF00E676)
                                          .withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _commentController,
                                    onSubmitted: (val) {
                                      final txt = val.trim();
                                      if (txt.isEmpty) return;
                                      widget.onAddComment(txt);
                                      _commentController.clear();
                                    },
                                    style: const TextStyle(
                                      color: Color(0xFFF0FDF4),
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "Add a public comment...",
                                      hintStyle: TextStyle(
                                        color: Color(0xFF8696A0),
                                        fontSize: 12.5,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassIconButton(
                                icon: Icons.send_rounded,
                                tooltip: "Post Comment",
                                size: 38,
                                isAccent: true,
                                color: const Color(0xFF00E676),
                                onTap: () {
                                  final txt = _commentController.text.trim();
                                  if (txt.isEmpty) return;
                                  widget.onAddComment(txt);
                                  _commentController.clear();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (movie.comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "No comments yet. Start the conversation!",
                                style: TextStyle(
                                  color: Color(0xFF8696A0),
                                  fontSize: 12.5,
                                ),
                              ),
                            )
                          else
                            ...movie.comments.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          const Color(0xFF10221D),
                                      backgroundImage: c.avatarUrl.isNotEmpty
                                          ? NetworkImage(c.avatarUrl)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                c.authorName,
                                                style: const TextStyle(
                                                  color: Color(0xFFF0FDF4),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                c.timeAgo,
                                                style: const TextStyle(
                                                  color: Color(0xFF8696A0),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            c.comment,
                                            style: const TextStyle(
                                              color: Color(0xFFCBD5E1),
                                              fontSize: 12.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Movie Synopsis & Streamtape Info Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.synopsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          height: 1.48,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Streamtape ID: ${movie.id} · Size: ${movie.duration} · Director: ${movie.director}",
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================================
                // 3. OTHER STREAM-READY MOVIES FROM STREAMTAPE ACCOUNT
                // ==========================================================
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_motion_rounded,
                      color: Color(0xFF00E676),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "More Movies from Streamtape (${otherMovies.length})",
                        style: const TextStyle(
                          color: Color(0xFFF0FDF4),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...otherMovies.map(
                  (other) => _buildUpNextMovieCard(other),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCircleControl({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.48),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.54),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9.5),
        decoration: BoxDecoration(
          gradient: isActive
          ? const LinearGradient(
              colors: [
                Color(0xFF00E676),
                Color(0xFF10B981),
                Color(0xFF047857),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.08),
                const Color(0xFF091714).withValues(alpha: 0.82),
              ],
            ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.6)
                : const Color(0xFF00E676).withValues(alpha: 0.25),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isActive
                  ? const Color(0xFF03120D)
                  : const Color(0xFF00E676),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF03120D)
                    : const Color(0xFFF0FDF4),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpNextMovieCard(MovieItem item) {
    return GestureDetector(
      onTap: () => widget.onSelectOtherMovie(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              const Color(0xFF091613).withValues(alpha: 0.76),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            // 16:9 Streamtape Thumbnail with Size Badge & Play Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 142,
                height: 84,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        item.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0A1815),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                    Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF00E676).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF03120D),
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF0FDF4),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${item.qualityBadge} · ${item.genres.join(' • ')}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${item.rating}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.viewsLabel,
                        style: const TextStyle(
                          color: Color(0xFF8696A0),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
