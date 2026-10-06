import "package:flutter/material.dart";
import "../models/movie_models.dart";
import "../widgets/glass_container.dart";

class HomeMoviesPage extends StatefulWidget {
  final List<MovieItem> movies;
  final Set<String> watchlistIds;
  final bool isSyncingStreamtape;
  final ValueChanged<MovieItem> onPlayMovie;
  final ValueChanged<String> onToggleWatchlist;
  final VoidCallback onOpenSearch;
  final VoidCallback onRefreshStreamtape;

  const HomeMoviesPage({
    super.key,
    required this.movies,
    required this.watchlistIds,
    this.isSyncingStreamtape = false,
    required this.onPlayMovie,
    required this.onToggleWatchlist,
    required this.onOpenSearch,
    required this.onRefreshStreamtape,
  });

  @override
  State<HomeMoviesPage> createState() => _HomeMoviesPageState();
}

class _HomeMoviesPageState extends State<HomeMoviesPage> {
  String _selectedGenre = "All";
  int _featuredIndex = 0;

  static const List<String> _genres = [
    "All",
    "Action",
    "Sci-Fi",
    "Thriller",
    "Romance",
    "Drama",
    "Crime",
    "Comedy",
  ];

  @override
  Widget build(BuildContext context) {
    final featuredList = widget.movies.where((m) => m.isFeatured).toList();
    final heroMovie = featuredList.isNotEmpty
        ? featuredList[_featuredIndex % featuredList.length]
        : widget.movies.first;

    final filteredMovies = _selectedGenre == "All"
        ? widget.movies
        : widget.movies
            .where((m) => m.genres.contains(_selectedGenre))
            .toList();

    final standaloneMovies =
        filteredMovies.where((m) => m.episodeNumber == 0).toList();
    final safedSagarEpisodes = filteredMovies
        .where(
            (m) => m.seriesName.toLowerCase().contains("operation safed sagar"))
        .toList()
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    final stickyLoveEpisodes = filteredMovies
        .where((m) => m.seriesName.toLowerCase().contains("our sticky love"))
        .toList()
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

    final continueWatching =
        widget.movies.where((m) => m.watchProgress > 0.0).toList();

    return GlassContainer(
      margin: EdgeInsets.zero,
      borderRadius: 0,
      blur: 28,
      border: const Border(),
      boxShadow: const [],
      backgroundColor: const Color(0xFF050C0A).withValues(alpha: 0.35),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    color: Color(0xFF03120D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "niooo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    widget.isSyncingStreamtape
                        ? "SYNCING..."
                        : "STREAMTAPE (${widget.movies.length})",
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                GlassIconButton(
                  icon: Icons.cloud_sync_rounded,
                  tooltip: "Sync Streamtape Library",
                  size: 38,
                  color: const Color(0xFF00E676),
                  onTap: widget.onRefreshStreamtape,
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: Icons.search_rounded,
                  tooltip: "Search Movies",
                  size: 38,
                  onTap: widget.onOpenSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 96),
              children: [
                _buildHeroBanner(heroMovie, featuredList),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _genres.map((genre) {
                      final active = _selectedGenre == genre;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGenre = genre),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00E676),
                                      Color(0xFF10B981),
                                      Color(0xFF047857),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.08),
                                      const Color(0xFF091714)
                                          .withValues(alpha: 0.75),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.55)
                                  : const Color(0xFF00E676)
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              color: active
                                  ? const Color(0xFF03120D)
                                  : const Color(0xFF94A3B8),
                              fontWeight:
                                  active ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (continueWatching.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    "Continue Watching",
                    "Tap any Streamtape movie to resume instant playback",
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 148,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: continueWatching.length,
                      itemBuilder: (context, index) {
                        return _buildContinueWatchingCard(
                            continueWatching[index]);
                      },
                    ),
                  ),
                ],
                if (standaloneMovies.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    "Blockbuster Movies on Streamtape",
                    "Full-length feature films from your cloud library",
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 258,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: standaloneMovies.length,
                      itemBuilder: (context, index) {
                        return _buildPosterCard(standaloneMovies[index]);
                      },
                    ),
                  ),
                ],
                if (safedSagarEpisodes.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    "Operation Safed Sagar (Season 1)",
                    "All ${safedSagarEpisodes.length} episodes automatically sorted (EP 01 – EP 06)",
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 258,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: safedSagarEpisodes.length,
                      itemBuilder: (context, index) {
                        return _buildPosterCard(safedSagarEpisodes[index]);
                      },
                    ),
                  ),
                ],
                if (stickyLoveEpisodes.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    "Our Sticky Love (Season 1)",
                    "All ${stickyLoveEpisodes.length} episodes automatically sorted (EP 01 – EP 09)",
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 258,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stickyLoveEpisodes.length,
                      itemBuilder: (context, index) {
                        return _buildPosterCard(stickyLoveEpisodes[index]);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _buildSectionHeader(
                  "All Streamtape Account Movies (${filteredMovies.length})",
                  "Automatically synced and organized from your Streamtape account",
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: filteredMovies
                        .map((movie) => _buildWideCatalogRow(movie))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(MovieItem hero, List<MovieItem> featuredList) {
    final inWatchlist = widget.watchlistIds.contains(hero.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => widget.onPlayMovie(hero),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.75),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  hero.backdropUrl,
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
                        Colors.black.withValues(alpha: 0.15),
                        const Color(0xFF040B09).withValues(alpha: 0.65),
                        const Color(0xFF030706).withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            child: Text(
                              hero.qualityBadge,
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${hero.rating}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          if (featuredList.length > 1)
                            Row(
                              children:
                                  List.generate(featuredList.length, (idx) {
                                final active = idx ==
                                    (_featuredIndex % featuredList.length);
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _featuredIndex = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(left: 5),
                                    width: active ? 18 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFF00E676)
                                          : Colors.white38,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hero.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${hero.releaseYear} · ${hero.viewsLabel} · ${hero.genres.join(' • ')}",
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              onTap: () => widget.onPlayMovie(hero),
                              borderRadius: 20,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFF03120D),
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Play Movie Now",
                                    style: TextStyle(
                                      color: Color(0xFF03120D),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GlassIconButton(
                            icon: inWatchlist
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_add_outlined,
                            tooltip: "Watchlist",
                            size: 44,
                            isAccent: inWatchlist,
                            color: inWatchlist
                                ? const Color(0xFF00E676)
                                : Colors.white,
                            onTap: () => widget.onToggleWatchlist(hero.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF0FDF4),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8696A0),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF00E676),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(MovieItem movie) {
    return GestureDetector(
      onTap: () => widget.onPlayMovie(movie),
      child: Container(
        width: 255,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.25),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                movie.backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0A1815),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00E676),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF03120D),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                "${(movie.watchProgress * 100).round()}% watched · ${movie.duration}",
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: movie.watchProgress,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E676),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterCard(MovieItem movie) {
    final saved = widget.watchlistIds.contains(movie.id);
    return GestureDetector(
      onTap: () => widget.onPlayMovie(movie),
      child: Container(
        width: 156,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              const Color(0xFF091613).withValues(alpha: 0.78),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.22),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0A1815),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFBBF24),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "${movie.rating}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => widget.onToggleWatchlist(movie.id),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: saved
                                ? const Color(0xFF00E676)
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF0FDF4),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${movie.releaseYear} · ${movie.genres.first}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8696A0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideCatalogRow(MovieItem movie) {
    final saved = widget.watchlistIds.contains(movie.id);

    return GestureDetector(
      onTap: () => widget.onPlayMovie(movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              const Color(0xFF091613).withValues(alpha: 0.72),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                movie.posterUrl,
                width: 68,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 68,
                  height: 92,
                  color: const Color(0xFF0A1815),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${movie.rating}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${movie.releaseYear} · ${movie.viewsLabel}",
                        style: const TextStyle(
                          color: Color(0xFF8696A0),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF0FDF4),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    movie.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GlassIconButton(
                  icon: Icons.play_arrow_rounded,
                  tooltip: "Stream Movie",
                  size: 38,
                  isAccent: true,
                  color: const Color(0xFF00E676),
                  onTap: () => widget.onPlayMovie(movie),
                ),
                const SizedBox(height: 6),
                GlassIconButton(
                  icon: saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip: "Toggle Watchlist",
                  size: 34,
                  color: saved ? const Color(0xFF00E676) : Colors.white70,
                  onTap: () => widget.onToggleWatchlist(movie.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
