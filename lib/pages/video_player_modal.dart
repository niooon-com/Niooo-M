import "dart:async";
import "dart:ui";
import "package:flutter/material.dart";
import "../models/movie_models.dart";
import "../widgets/glass_container.dart";

class VideoPlayerModal extends StatefulWidget {
  final MovieItem movie;
  final VoidCallback onClose;
  final ValueChanged<double> onUpdateProgress;

  const VideoPlayerModal({
    super.key,
    required this.movie,
    required this.onClose,
    required this.onUpdateProgress,
  });

  @override
  State<VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<VideoPlayerModal> {
  bool _isPlaying = true;
  bool _isMuted = false;
  double _progress = 0.24;
  String _selectedQuality = "4K IMAX HDR";
  String _selectedAudioTrack = "English (Dolby Atmos)";
  Timer? _playbackTimer;

  static const List<String> _qualities = [
    "4K IMAX HDR",
    "1080p Full HD",
    "720p Data Saver",
  ];

  @override
  void initState() {
    super.initState();
    _progress = widget.movie.watchProgress > 0.05
        ? widget.movie.watchProgress
        : 0.18;
    _startTimer();
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _progress = (_progress + 0.004).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  String _formatPosition(double p) {
    final totalSeconds = (142 * 60 * p).round();
    final hrs = totalSeconds ~/ 3600;
    final mins = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final secs = (totalSeconds % 60).toString().padLeft(2, "0");
    return "$hrs:$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF020504),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dynamic Cinema Canvas
            Image.network(
              widget.movie.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF050E0C),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Top Cinema Player Bar
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: "Exit Theater",
                        size: 40,
                        onTap: () {
                          widget.onUpdateProgress(_progress);
                          widget.onClose();
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "$_selectedQuality · $_selectedAudioTrack",
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: "Stream Quality",
                        color: const Color(0xFF0A1815),
                        onSelected: (val) =>
                            setState(() => _selectedQuality = val),
                        itemBuilder: (_) => _qualities
                            .map(
                              (q) => PopupMenuItem(
                                value: q,
                                child: Text(
                                  q,
                                  style: TextStyle(
                                    color: _selectedQuality == q
                                        ? const Color(0xFF00E676)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF00E676).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF00E676)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            _selectedQuality,
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center Play/Pause + Skip Controls
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassIconButton(
                    icon: Icons.replay_10_rounded,
                    tooltip: "Rewind 10s",
                    size: 52,
                    onTap: () => setState(
                      () => _progress = (_progress - 0.04).clamp(0.0, 1.0),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF10B981)],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E676).withValues(alpha: 0.55),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: const Color(0xFF03120D),
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GlassIconButton(
                    icon: Icons.forward_10_rounded,
                    tooltip: "Forward 10s",
                    size: 52,
                    onTap: () => setState(
                      () => _progress = (_progress + 0.04).clamp(0.0, 1.0),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Scrubber & Audio Controls
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF071310).withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF00E676)
                                .withValues(alpha: 0.28),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _formatPosition(_progress),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _progress,
                                    activeColor: const Color(0xFF00E676),
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) =>
                                        setState(() => _progress = v),
                                  ),
                                ),
                                Text(
                                  widget.movie.duration,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GlassIconButton(
                                  icon: _isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  tooltip: "Mute / Unmute",
                                  size: 36,
                                  onTap: () =>
                                      setState(() => _isMuted = !_isMuted),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Subtitles: English CC · Audio: Dolby Atmos 7.1",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                                GlassButton(
                                  onTap: () {
                                    widget.onUpdateProgress(_progress);
                                    widget.onClose();
                                  },
                                  borderRadius: 14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  child: const Text(
                                    "Done",
                                    style: TextStyle(
                                      color: Color(0xFF03120D),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
