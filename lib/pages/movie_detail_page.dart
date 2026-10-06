import "dart:ui";
import "package:flutter/material.dart";
import "../models/movie_models.dart";
import "../widgets/glass_container.dart";

class MovieDetailPage extends StatefulWidget {
  final MovieItem movie;
  final List<MovieItem> allMovies;
  final bool isBookmarked;
  final VoidCallback onBack;
  final ValueChanged<MovieItem> onPlayMovie;
  final ValueChanged<String> onToggleWatchlist;
  final ValueChanged<MovieItem> onSelectRelatedMovie;
  final Function(String movieId, double rating, String comment) onAddReview;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.allMovies,
    required this.isBookmarked,
    required this.onBack,
    required this.onPlayMovie,
    required this.onToggleWatchlist,
    required this.onSelectRelatedMovie,
    required this.onAddReview,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final TextEditingController _reviewCtrl = TextEditingController();
  double _selectedRating = 9.5;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _openWriteReviewModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderRadius: 26,
                  blur: 30,
                  backgroundColor:
                      const Color(0xFF07120F).withValues(alpha: 0.94),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.rate_review_rounded,
                            color: Color(0xFF00E676),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Review ${widget.movie.title}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFF0FDF4),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF8696A0),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Your Rating",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "★ ${_selectedRating.toStringAsFixed(1)} / 10",
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _selectedRating,
                        min: 5.0,
                        max: 10.0,
                        divisions: 10,
                        activeColor: const Color(0xFF00E676),
                        inactiveColor: Colors.white24,
                        onChanged: (v) =>
                            setModalState(() => _selectedRating = v),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1815),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E676)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: TextField(
                          controller: _reviewCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Color(0xFFF0FDF4),
                            fontSize: 13.5,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "Share your thoughts on cinematography, sound, and story...",
                            hintStyle: TextStyle(
                              color: Color(0xFF8696A0),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          onTap: () {
                            final text = _reviewCtrl.text.trim();
                            if (text.isEmpty) return;
                            widget.onAddReview(
                              widget.movie.id,
                              _selectedRating,
                              text,
                            );
                            _reviewCtrl.clear();
                            Navigator.of(ctx).pop();
                          },
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              "Publish Review",
                              style: TextStyle(
                                color: Color(0xFF03120D),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final relatedMovies = widget.allMovies
        .where((m) =>
            m.id != movie.id &&
            m.genres.any((g) => movie.genres.contains(g)))
        .toList();

    return GlassContainer(
      margin: EdgeInsets.zero,
      borderRadius: 0,
      blur: 28,
      border: const Border(),
      boxShadow: const [],
      backgroundColor: const Color(0xFF040A08).withValues(alpha: 0.45),
      child: Column(
        children: [
          // Top Navigation Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF07120F).withValues(alpha: 0.82),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: "Back",
                  size: 38,
                  onTap: widget.onBack,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF0FDF4),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        movie.qualityBadge,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassIconButton(
                  icon: widget.isBookmarked
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_add_outlined,
                  tooltip: "Watchlist",
                  size: 38,
                  isAccent: widget.isBookmarked,
                  color: widget.isBookmarked
                      ? const Color(0xFF00E676)
                      : Colors.white,
                  onTap: () => widget.onToggleWatchlist(movie.id),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                // Full-width Backdrop Preview Banner
                SizedBox(
                  height: 260,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF091814),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              const Color(0xFF030706).withValues(alpha: 0.96),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => widget.onPlayMovie(movie),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E676),
                                  Color(0xFF10B981),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.55),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF03120D),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genres + Metadata Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...movie.genres.map(
                            (g) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                g,
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              "${movie.releaseYear} · ${movie.duration} · ${movie.maturityRating}",
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${movie.tagline}"',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Primary Stream CTA
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          onTap: () => widget.onPlayMovie(movie),
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: Color(0xFF03120D),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Stream Full Movie in 4K HDR",
                                style: TextStyle(
                                  color: Color(0xFF03120D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Storyline Synopsis
                      const Text(
                        "STORYLINE",
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.synopsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Directed by ${movie.director}",
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Cast & Crew Section
                      const Text(
                        "TOP CAST",
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 76,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movie.cast.length,
                          itemBuilder: (context, index) {
                            final member = movie.cast[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF091714)
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage:
                                        NetworkImage(member.avatarUrl),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          color: Color(0xFFF0FDF4),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        member.role,
                                        style: const TextStyle(
                                          color: Color(0xFF8696A0),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audience Reviews Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "AUDIENCE REVIEWS",
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openWriteReviewModal(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              child: const Text(
                                "+ Write Review",
                                style: TextStyle(
                                  color: Color(0xFF00E676),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (movie.reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "No audience reviews yet. Be the first to review this movie!",
                            style: TextStyle(
                              color: Color(0xFF8696A0),
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ...movie.reviews.map(
                          (rev) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF091714)
                                  .withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      rev.authorName,
                                      style: const TextStyle(
                                        color: Color(0xFFF0FDF4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      rev.authorHandle,
                                      style: const TextStyle(
                                        color: Color(0xFF8696A0),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFBBF24),
                                      size: 15,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${rev.rating}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  rev.comment,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (relatedMovies.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const Text(
                          "MORE LIKE THIS",
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 195,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: relatedMovies.length,
                            itemBuilder: (context, index) {
                              final rel = relatedMovies[index];
                              return GestureDetector(
                                onTap: () => widget.onSelectRelatedMovie(rel),
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            rel.posterUrl,
                                            width: 130,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        rel.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFF0FDF4),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
