import "dart:convert";
import "../services/platform_bridge.dart";

class CastMember {
  final String name;
  final String role;
  final String avatarUrl;

  const CastMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}

class MovieComment {
  final String id;
  final String authorName;
  final String authorHandle;
  final String avatarUrl;
  final String comment;
  final String timeAgo;
  final int likes;

  const MovieComment({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.avatarUrl,
    required this.comment,
    required this.timeAgo,
    this.likes = 0,
  });
}

class MovieItem {
  final String id;
  final String title;
  final String seriesName;
  final String episodeLabel;
  final int episodeNumber;
  final String tagline;
  final String synopsis;
  final String posterUrl;
  final String backdropUrl;
  final String embedUrl;
  final String videoStreamUrl;
  final double rating;
  final int releaseYear;
  final String duration;
  final String maturityRating;
  final String qualityBadge;
  final List<String> genres;
  final String director;
  final List<CastMember> cast;
  final bool isFeatured;
  final bool isTrending;
  final bool isNewRelease;
  final double watchProgress;
  final int likesCount;
  final int sharesCount;
  final String viewsLabel;
  final List<MovieComment> comments;

  const MovieItem({
    required this.id,
    required this.title,
    this.seriesName = "",
    this.episodeLabel = "",
    this.episodeNumber = 0,
    required this.tagline,
    required this.synopsis,
    required this.posterUrl,
    required this.backdropUrl,
    this.embedUrl = "",
    required this.videoStreamUrl,
    required this.rating,
    required this.releaseYear,
    required this.duration,
    required this.maturityRating,
    required this.qualityBadge,
    required this.genres,
    required this.director,
    required this.cast,
    this.isFeatured = false,
    this.isTrending = false,
    this.isNewRelease = false,
    this.watchProgress = 0.0,
    this.likesCount = 1240,
    this.sharesCount = 310,
    this.viewsLabel = "1.8M views",
    this.comments = const [],
  });

  factory MovieItem.fromStreamtapeJson(Map<String, dynamic> json) {
    final String id = (json["id"] ?? "").toString();
    final String title = (json["title"] ?? "Untitled Movie").toString();
    final String seriesName = (json["seriesName"] ?? title).toString();
    final String episodeLabel = (json["episodeLabel"] ?? "").toString();
    final int episodeNumber =
        int.tryParse((json["episodeNumber"] ?? "0").toString()) ?? 0;
    final String posterUrl = (json["posterUrl"] ?? "").toString();
    final String backdropUrl =
        (json["backdropUrl"] ?? posterUrl).toString();
    final String embedUrl =
        (json["embedUrl"] ?? "https://streamtape.com/e/$id").toString();
    final String videoStreamUrl =
        (json["videoStreamUrl"] ?? "/api/streamtape/direct?file=$id")
            .toString();

    final List<String> genresList = [];
    if (json["genres"] is List) {
      for (final g in (json["genres"] as List)) {
        genresList.add(g.toString());
      }
    }
    if (genresList.isEmpty) {
      genresList.add("Action");
    }

    return MovieItem(
      id: id,
      title: title,
      seriesName: seriesName,
      episodeLabel: episodeLabel,
      episodeNumber: episodeNumber,
      tagline: (json["tagline"] ??
              "Streamed live from your Streamtape Cloud Account.")
          .toString(),
      synopsis: (json["synopsis"] ??
              "Watch $title in HD directly from your Streamtape cloud library.")
          .toString(),
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      embedUrl: embedUrl,
      videoStreamUrl: videoStreamUrl,
      rating: double.tryParse((json["rating"] ?? "9.1").toString()) ?? 9.1,
      releaseYear:
          int.tryParse((json["releaseYear"] ?? "2026").toString()) ?? 2026,
      duration: (json["duration"] ?? "HD Stream").toString(),
      maturityRating: (json["maturityRating"] ?? "HD").toString(),
      qualityBadge: (json["qualityBadge"] ?? "720p HD").toString(),
      genres: genresList,
      director: (json["director"] ?? "Niooo Streamtape Cloud").toString(),
      cast: const [
        CastMember(
          name: "Streamtape Cloud",
          role: "Verified Source",
          avatarUrl:
              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
        ),
      ],
      isFeatured: json["isFeatured"] == true,
      isTrending: json["isTrending"] == true,
      isNewRelease: json["isNewRelease"] == true,
      likesCount:
          int.tryParse((json["likesCount"] ?? "2450").toString()) ?? 2450,
      sharesCount:
          int.tryParse((json["sharesCount"] ?? "520").toString()) ?? 520,
      viewsLabel: (json["viewsLabel"] ?? "1.6M views").toString(),
      comments: [
        MovieComment(
          id: "c_${id}_1",
          authorName: "Arif Rahman",
          authorHandle: "@arif_cinema",
          avatarUrl:
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
          comment:
              "Streaming $title directly from Streamtape on Niooo M — crystal clear HD quality!",
          timeAgo: "2h ago",
          likes: 184,
        ),
      ],
    );
  }

  MovieItem copyWith({
    String? title,
    String? seriesName,
    String? episodeLabel,
    int? episodeNumber,
    String? tagline,
    String? synopsis,
    String? posterUrl,
    String? backdropUrl,
    String? embedUrl,
    String? videoStreamUrl,
    double? rating,
    int? releaseYear,
    String? duration,
    String? qualityBadge,
    List<String>? genres,
    String? director,
    bool? isFeatured,
    bool? isTrending,
    bool? isNewRelease,
    double? watchProgress,
    int? likesCount,
    int? sharesCount,
    List<MovieComment>? comments,
  }) {
    return MovieItem(
      id: id,
      title: title ?? this.title,
      seriesName: seriesName ?? this.seriesName,
      episodeLabel: episodeLabel ?? this.episodeLabel,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      tagline: tagline ?? this.tagline,
      synopsis: synopsis ?? this.synopsis,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      embedUrl: embedUrl ?? this.embedUrl,
      videoStreamUrl: videoStreamUrl ?? this.videoStreamUrl,
      rating: rating ?? this.rating,
      releaseYear: releaseYear ?? this.releaseYear,
      duration: duration ?? this.duration,
      maturityRating: maturityRating,
      qualityBadge: qualityBadge ?? this.qualityBadge,
      genres: genres ?? this.genres,
      director: director ?? this.director,
      cast: cast,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isNewRelease: isNewRelease ?? this.isNewRelease,
      watchProgress: watchProgress ?? this.watchProgress,
      likesCount: likesCount ?? this.likesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsLabel: viewsLabel,
      comments: comments ?? this.comments,
    );
  }
}

class MovieCatalogData {
  /// Fetches live movies directly from the server's `/api/streamtape/catalog` endpoint
  static Future<List<MovieItem>> fetchLiveStreamtapeCatalog({
    bool forceRefresh = false,
  }) async {
    try {
      final url = forceRefresh
          ? "/api/streamtape/catalog?refresh=1"
          : "/api/streamtape/catalog";
      final responseText = await PlatformBridge.httpGetString(url);
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic> && decoded["movies"] is List) {
        final List<dynamic> rawList = decoded["movies"] as List<dynamic>;
        final parsed = rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => MovieItem.fromStreamtapeJson(item))
            .toList();
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {
      // Fallback to pre-synced Streamtape account catalog if offline
    }
    return initialMovies;
  }

  /// Resolves the direct MP4 video stream URL from `/api/streamtape/direct?file=<id>`
  static Future<String?> resolveDirectStreamUrl(String fileId) async {
    try {
      final responseText = await PlatformBridge.httpGetString(
        "/api/streamtape/direct?file=${Uri.encodeComponent(fileId)}",
      );
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic>) {
        final url = (decoded["url"] ?? "").toString();
        if (url.startsWith("http")) {
          return url;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Saves custom movie poster, title, featured status, or new Streamtape movie via Admin Panel
  static Future<bool> saveAdminMovieOverride(
    Map<String, dynamic> payload,
  ) async {
    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/movie",
        payload,
      );
      return status == 200;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a movie from the catalog via Admin Panel
  static Future<bool> deleteAdminMovie(String id) async {
    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/delete",
        {"id": id},
      );
      return status == 200;
    } catch (_) {
      return false;
    }
  }

  /// Restores any deleted Streamtape movies via Admin Panel
  static Future<bool> restoreDeletedMovies() async {
    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/restore",
        {},
      );
      return status == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetches current Streamtape API login & key
  static Future<Map<String, String>> fetchStreamtapeCredentials() async {
    try {
      final resText =
          await PlatformBridge.httpGetString("/api/streamtape/credentials");
      final decoded = jsonDecode(resText);
      if (decoded is Map<String, dynamic>) {
        return {
          "login": (decoded["login"] ?? "fa66d0d4d79c646de270").toString(),
          "key": (decoded["key"] ?? "2LBZ94jDzWFxyD").toString(),
        };
      }
    } catch (_) {}
    return {
      "login": "fa66d0d4d79c646de270",
      "key": "2LBZ94jDzWFxyD",
    };
  }

  /// Updates Streamtape API login & key from Admin Panel
  static Future<bool> updateStreamtapeCredentials(
    String login,
    String key,
  ) async {
    try {
      final resText = await PlatformBridge.httpPostJsonResponse(
        "/api/streamtape/credentials",
        {"login": login, "key": key},
      );
      if (resText != null) {
        final decoded = jsonDecode(resText);
        return decoded is Map && decoded["valid"] == true;
      }
    } catch (_) {}
    return false;
  }

  /// All 21 real movies and series episodes from the user's Streamtape account (`fa66d0d4d79c646de270`)
  /// pre-organized with real Streamtape IDs, splash thumbnails, and curated posters.
  static final List<MovieItem> initialMovies = [
    // =========================================================================
    // 1. STANDALONE BLOCKBUSTER MOVIES FROM STREAMTAPE ACCOUNT
    // =========================================================================
    MovieItem(
      id: "Zk2Rbvkpl9tqzjD",
      title: "Spider-Man: Brand New Day",
      seriesName: "Spider-Man: Brand New Day",
      tagline: "A brand new era of web-slinging heroism begins.",
      synopsis:
          "Peter Parker faces his most formidable street-level and cosmic threats yet in Spider-Man: Brand New Day (2026), streaming in multi-language 720p HEVC directly from your Streamtape account.",
      posterUrl:
          "https://images.unsplash.com/photo-1635805737707-575885ab0820?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/Zk2Rbvkpl9tqzjD/ZyM6xZjDm6FqzVw.jpg",
      embedUrl: "https://streamtape.com/e/Zk2Rbvkpl9tqzjD",
      videoStreamUrl: "/api/streamtape/direct?file=Zk2Rbvkpl9tqzjD",
      rating: 9.5,
      releaseYear: 2026,
      duration: "1.04 GB",
      maturityRating: "PG-13",
      qualityBadge: "720p HEVC · Hindi/Eng",
      genres: const ["Action", "Sci-Fi", "Adventure"],
      director: "Destin Daniel Cretton",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.45,
      likesCount: 34200,
      sharesCount: 6810,
      viewsLabel: "3.8M views",
      cast: const [
        CastMember(
          name: "Tom Holland",
          role: "Peter Parker / Spider-Man",
          avatarUrl:
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
        ),
      ],
      comments: const [
        MovieComment(
          id: "c_sp_1",
          authorName: "Raihan Cinema",
          authorHandle: "@niooo_m",
          avatarUrl:
              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
          comment:
              "Directly synced from Streamtape account! Plays smoothly inside Niooo M player.",
          timeAgo: "1h ago",
          likes: 412,
        ),
      ],
    ),
    MovieItem(
      id: "MPDylDpxp9h0Jr",
      title: "Avengers: Endgame",
      seriesName: "Avengers: Endgame",
      tagline: "Part of the journey is the end.",
      synopsis:
          "After the devastating events of Infinity War, the Avengers assemble once more in order to reverse Thanos' actions and restore balance to the universe.",
      posterUrl:
          "https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_QL75_UX380_CR0,0,380,562_.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/MPDylDpxp9h0Jr/PyWZx7OMo6F0p3L.jpg",
      embedUrl: "https://streamtape.com/e/MPDylDpxp9h0Jr",
      videoStreamUrl: "/api/streamtape/direct?file=MPDylDpxp9h0Jr",
      rating: 9.6,
      releaseYear: 2019,
      duration: "1.25 GB",
      maturityRating: "PG-13",
      qualityBadge: "BluRay 720p · x265",
      genres: const ["Action", "Sci-Fi", "Fantasy"],
      director: "Anthony & Joe Russo",
      isFeatured: true,
      isTrending: true,
      isNewRelease: false,
      watchProgress: 0.72,
      likesCount: 48900,
      sharesCount: 9420,
      viewsLabel: "5.2M views",
      cast: const [],
      comments: const [
        MovieComment(
          id: "c_av_1",
          authorName: "Tanvir Hasan",
          authorHandle: "@tanvir_mcu",
          avatarUrl:
              "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80",
          comment:
              "BluRay x265 stream from Streamtape loads super fast with zero buffering!",
          timeAgo: "3h ago",
          likes: 530,
        ),
      ],
    ),
    MovieItem(
      id: "kwa24xVPj7FOVWm",
      title: "KGF Chapter 2",
      seriesName: "KGF Chapter 2",
      tagline: "In the blood-soaked Kolar Gold Fields, Rocky's name strikes fear.",
      synopsis:
          "Rocky successfully rises as the leader and savior of the people of the Kolar Gold Fields, while facing vengeful adversaries Adheera and Ramika Sen in Hindi Dubbed DD5.1.",
      posterUrl:
          "https://myimg.click/images/2022/05/16/KGF-CHAPTER-2-2022-Hindi-ORG-WEBRip-Full-Movie.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/kwa24xVPj7FOVWm/jv37yyRdRjizrz1.jpg",
      embedUrl: "https://streamtape.com/e/kwa24xVPj7FOVWm",
      videoStreamUrl: "/api/streamtape/direct?file=kwa24xVPj7FOVWm",
      rating: 9.4,
      releaseYear: 2022,
      duration: "648 MB",
      maturityRating: "R",
      qualityBadge: "Hindi Dubbed · DD 5.1",
      genres: const ["Action", "Crime", "Drama"],
      director: "Prashanth Neel",
      isFeatured: true,
      isTrending: true,
      isNewRelease: false,
      watchProgress: 0.30,
      likesCount: 39100,
      sharesCount: 7210,
      viewsLabel: "4.4M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "d7g3lXRp9Dsk4eM",
      title: "DC (2026)",
      seriesName: "DC",
      tagline: "A new chapter of heroes and legends unfolds in 2026.",
      synopsis:
          "Experience the 2026 DC cinematic action spectacle in Hindi Line audio, streamed live from your Streamtape cloud storage.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/nmQ799Pa5EKczJvQPzlvhtW0CBW.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/d7g3lXRp9Dsk4eM/8wel0GVLwWUoKLr.jpg",
      embedUrl: "https://streamtape.com/e/d7g3lXRp9Dsk4eM",
      videoStreamUrl: "/api/streamtape/direct?file=d7g3lXRp9Dsk4eM",
      rating: 9.1,
      releaseYear: 2026,
      duration: "585 MB",
      maturityRating: "PG-13",
      qualityBadge: "HDTC · Hindi Line",
      genres: const ["Action", "Thriller", "Sci-Fi"],
      director: "James Gunn",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.0,
      likesCount: 21400,
      sharesCount: 4120,
      viewsLabel: "2.3M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "ZP8jv1wdAwFB0k",
      title: "Shivaji Surathkal",
      seriesName: "Shivaji Surathkal",
      tagline: "The case of Ranagiri Rahasya awaits Detective Shivaji.",
      synopsis:
          "Brilliant detective Shivaji Surathkal investigates a perplexing murder mystery at a remote resort in Ranagiri while battling his own inner demons.",
      posterUrl:
          "https://myimg.click/images/2021/05/31/1920x770_912858496.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/ZP8jv1wdAwFB0k/7b3vZeMvlwFALXP.jpg",
      embedUrl: "https://streamtape.com/e/ZP8jv1wdAwFB0k",
      videoStreamUrl: "/api/streamtape/direct?file=ZP8jv1wdAwFB0k",
      rating: 8.9,
      releaseYear: 2020,
      duration: "464 MB",
      maturityRating: "PG-13",
      qualityBadge: "HDRip · x264",
      genres: const ["Thriller", "Mystery", "Crime"],
      director: "Akash Srivatsa",
      isFeatured: false,
      isTrending: true,
      isNewRelease: false,
      watchProgress: 0.0,
      likesCount: 15800,
      sharesCount: 2490,
      viewsLabel: "1.5M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "16gp4VLVOyHevza",
      title: "Sex Education: Feature Special",
      seriesName: "Sex Education",
      tagline: "Unfiltered stories of youth, connection, and drama.",
      synopsis:
          "Full-length feature cut streamed directly from your Streamtape cloud storage in high-definition MP4.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/310/775536.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/16gp4VLVOyHevza/a7M7O3kj8XIxv2O.jpg",
      embedUrl: "https://streamtape.com/e/16gp4VLVOyHevza",
      videoStreamUrl: "/api/streamtape/direct?file=16gp4VLVOyHevza",
      rating: 8.8,
      releaseYear: 2025,
      duration: "1.58 GB",
      maturityRating: "R",
      qualityBadge: "1080p Full HD",
      genres: const ["Drama", "Romance"],
      director: "Ben Taylor",
      isFeatured: false,
      isTrending: false,
      isNewRelease: true,
      watchProgress: 0.0,
      likesCount: 12900,
      sharesCount: 1840,
      viewsLabel: "1.4M views",
      cast: const [],
      comments: const [],
    ),

    // =========================================================================
    // 2. OPERATION SAFED SAGAR (S01 E01 - E06) — SORTED BY EPISODE
    // =========================================================================
    MovieItem(
      id: "zbZJ6d4wrPtXLq",
      title: "Operation Safed Sagar — S01 · EP 01",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 01",
      episodeNumber: 1,
      tagline: "High-altitude courage above the Kargil peaks.",
      synopsis:
          "Episode 1: Follow the gripping aerial missions of the Indian Air Force during the 1999 Kargil conflict in DS4K WEB-DL 5.1 Hindi audio.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/zbZJ6d4wrPtXLq/XbLQ6R9YPAigOj.jpg",
      embedUrl: "https://streamtape.com/e/zbZJ6d4wrPtXLq",
      videoStreamUrl: "/api/streamtape/direct?file=zbZJ6d4wrPtXLq",
      rating: 9.2,
      releaseYear: 2026,
      duration: "269 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p DS4K · WEB-DL 5.1",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      likesCount: 19400,
      sharesCount: 3420,
      viewsLabel: "2.1M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "P66Yrgb2OjCD3W",
      title: "Operation Safed Sagar — S01 · EP 02",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 02",
      episodeNumber: 2,
      tagline: "High-altitude courage above the Kargil peaks.",
      synopsis:
          "Episode 2: The squadron prepares for night reconnaissance across fortified mountain ridges in DS4K WEB-DL 5.1 Hindi.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/P66Yrgb2OjCD3W/1q6qplZWdAupLW.jpg",
      embedUrl: "https://streamtape.com/e/P66Yrgb2OjCD3W",
      videoStreamUrl: "/api/streamtape/direct?file=P66Yrgb2OjCD3W",
      rating: 9.1,
      releaseYear: 2026,
      duration: "263 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p DS4K · WEB-DL 5.1",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isTrending: true,
      isNewRelease: true,
      likesCount: 16200,
      sharesCount: 2810,
      viewsLabel: "1.8M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "017pbq9kBvHmgg",
      title: "Operation Safed Sagar — S01 · EP 03",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 03",
      episodeNumber: 3,
      tagline: "High-altitude courage above the Kargil peaks.",
      synopsis:
          "Episode 3: Precision laser-guided strikes are authorized under extreme anti-aircraft fire.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/017pbq9kBvHmgg/XxWwjyra16f0oL.jpg",
      embedUrl: "https://streamtape.com/e/017pbq9kBvHmgg",
      videoStreamUrl: "/api/streamtape/direct?file=017pbq9kBvHmgg",
      rating: 9.2,
      releaseYear: 2026,
      duration: "216 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p DS4K · WEB-DL 5.1",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isNewRelease: true,
      likesCount: 15100,
      sharesCount: 2390,
      viewsLabel: "1.6M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "P9GMz1mwKqT0aXL",
      title: "Operation Safed Sagar — S01 · EP 04",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 04",
      episodeNumber: 4,
      tagline: "High-altitude courage above the Kargil peaks.",
      synopsis:
          "Episode 4: Behind enemy lines rescue operations test the limits of every pilot in the unit.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/P9GMz1mwKqT0aXL/pk3zqD76gdtr3X3.jpg",
      embedUrl: "https://streamtape.com/e/P9GMz1mwKqT0aXL",
      videoStreamUrl: "/api/streamtape/direct?file=P9GMz1mwKqT0aXL",
      rating: 9.1,
      releaseYear: 2026,
      duration: "212 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p DS4K · WEB-DL 5.1",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isNewRelease: true,
      likesCount: 14800,
      sharesCount: 2150,
      viewsLabel: "1.5M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "b337jP2Rb8IPVQr",
      title: "Operation Safed Sagar — S01 · EP 05",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 05",
      episodeNumber: 5,
      tagline: "High-altitude courage above the Kargil peaks.",
      synopsis:
          "Episode 5: Strategic air dominance shifts the tide of the mountain campaign.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/b337jP2Rb8IPVQr/dQo439Gd91ukRwM.jpg",
      embedUrl: "https://streamtape.com/e/b337jP2Rb8IPVQr",
      videoStreamUrl: "/api/streamtape/direct?file=b337jP2Rb8IPVQr",
      rating: 9.0,
      releaseYear: 2026,
      duration: "239 MB",
      maturityRating: "PG-13",
      qualityBadge: "480p DS4K · WEB-DL",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isNewRelease: true,
      likesCount: 14200,
      sharesCount: 1980,
      viewsLabel: "1.4M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "JKprl14GvGSj4dW",
      title: "Operation Safed Sagar — S01 · EP 06",
      seriesName: "Operation Safed Sagar",
      episodeLabel: "S01 · EP 06",
      episodeNumber: 6,
      tagline: "Season Finale — Victory in the skies.",
      synopsis:
          "Episode 6 (Finale): The decisive final sortie over Tiger Hill brings the historic mission to its climax.",
      posterUrl:
          "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/JKprl14GvGSj4dW/eG72xdGpjWukJK.jpg",
      embedUrl: "https://streamtape.com/e/JKprl14GvGSj4dW",
      videoStreamUrl: "/api/streamtape/direct?file=JKprl14GvGSj4dW",
      rating: 9.4,
      releaseYear: 2026,
      duration: "243 MB",
      maturityRating: "PG-13",
      qualityBadge: "480p DS4K · WEB-DL",
      genres: const ["Action", "Thriller", "Drama"],
      director: "Oni Sen",
      isNewRelease: true,
      likesCount: 18900,
      sharesCount: 3110,
      viewsLabel: "2.0M views",
      cast: const [],
      comments: const [],
    ),

    // =========================================================================
    // 3. OUR STICKY LOVE (S01 E01 - E09) — SORTED BY EPISODE
    // =========================================================================
    MovieItem(
      id: "zp1BLaZaGWcYrZq",
      title: "Our Sticky Love — S01 · EP 01",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 01",
      episodeNumber: 1,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 1: An unexpected encounter sparks a hilarious and heartfelt romance. Dual Audio (Hindi & English) with MSubs.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/zp1BLaZaGWcYrZq/VdVJGrA2ObtyDk.jpg",
      embedUrl: "https://streamtape.com/e/zp1BLaZaGWcYrZq",
      videoStreamUrl: "/api/streamtape/direct?file=zp1BLaZaGWcYrZq",
      rating: 9.0,
      releaseYear: 2026,
      duration: "276 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      likesCount: 22300,
      sharesCount: 4150,
      viewsLabel: "2.5M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "1amxMV60VZfxe1",
      title: "Our Sticky Love — S01 · EP 02",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 02",
      episodeNumber: 2,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 2: Forced to work side by side, old misunderstandings resurface in Dual Audio 720p HD.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/1amxMV60VZfxe1/Do1YLRar0RfAGJ.jpg",
      embedUrl: "https://streamtape.com/e/1amxMV60VZfxe1",
      videoStreamUrl: "/api/streamtape/direct?file=1amxMV60VZfxe1",
      rating: 8.9,
      releaseYear: 2026,
      duration: "359 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isTrending: true,
      isNewRelease: true,
      likesCount: 17400,
      sharesCount: 2890,
      viewsLabel: "1.9M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "qDRvXlZzYYILaq",
      title: "Our Sticky Love — S01 · EP 03",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 03",
      episodeNumber: 3,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 3: A rainy evening confession changes everything between the two leads.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/qDRvXlZzYYILaq/Wplg6AmgDOTb4Pk.jpg",
      embedUrl: "https://streamtape.com/e/qDRvXlZzYYILaq",
      videoStreamUrl: "/api/streamtape/direct?file=qDRvXlZzYYILaq",
      rating: 9.0,
      releaseYear: 2026,
      duration: "346 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 16800,
      sharesCount: 2640,
      viewsLabel: "1.8M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "XjmLMo2L2BID630",
      title: "Our Sticky Love — S01 · EP 04",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 04",
      episodeNumber: 4,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 4: Jealousy and sweet surprises unfold during the weekend retreat.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/XjmLMo2L2BID630/YBQR9wb3qvtvvJa.jpg",
      embedUrl: "https://streamtape.com/e/XjmLMo2L2BID630",
      videoStreamUrl: "/api/streamtape/direct?file=XjmLMo2L2BID630",
      rating: 8.9,
      releaseYear: 2026,
      duration: "295 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 15900,
      sharesCount: 2410,
      viewsLabel: "1.7M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "yAXrr94DqmT1b7g",
      title: "Our Sticky Love — S01 · EP 05",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 05",
      episodeNumber: 5,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 5: Secrets from the past test their growing bond in 720p Dual Audio.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/yAXrr94DqmT1b7g/wJxYrMXlXqcj8A.jpg",
      embedUrl: "https://streamtape.com/e/yAXrr94DqmT1b7g",
      videoStreamUrl: "/api/streamtape/direct?file=yAXrr94DqmT1b7g",
      rating: 9.1,
      releaseYear: 2026,
      duration: "365 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 16200,
      sharesCount: 2520,
      viewsLabel: "1.7M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "l0kWG8gLvMT7J8W",
      title: "Our Sticky Love — S01 · EP 06",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 06",
      episodeNumber: 6,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 6: A heartfelt reconciliation under the city lights brings them closer than ever.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/l0kWG8gLvMT7J8W/APDw8xlajxsXPR3.jpg",
      embedUrl: "https://streamtape.com/e/l0kWG8gLvMT7J8W",
      videoStreamUrl: "/api/streamtape/direct?file=l0kWG8gLvMT7J8W",
      rating: 9.0,
      releaseYear: 2026,
      duration: "287 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 15400,
      sharesCount: 2310,
      viewsLabel: "1.6M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "LagGyp0Z90sRooR",
      title: "Our Sticky Love — S01 · EP 07",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 07",
      episodeNumber: 7,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 7: Family expectations create a dramatic crossroads for the couple.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/LagGyp0Z90sRooR/jl2RjmRboehzWrg.jpg",
      embedUrl: "https://streamtape.com/e/LagGyp0Z90sRooR",
      videoStreamUrl: "/api/streamtape/direct?file=LagGyp0Z90sRooR",
      rating: 9.1,
      releaseYear: 2026,
      duration: "355 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 16900,
      sharesCount: 2680,
      viewsLabel: "1.8M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "JwA6mOGePqcjx9j",
      title: "Our Sticky Love — S01 · EP 08",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 08",
      episodeNumber: 8,
      tagline: "When two worlds collide, love finds the sweetest path.",
      synopsis:
          "Episode 8: Everything is on the line as the penultimate chapter unfolds.",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/JwA6mOGePqcjx9j/3kBmyJDjQatdZy4.jpg",
      embedUrl: "https://streamtape.com/e/JwA6mOGePqcjx9j",
      videoStreamUrl: "/api/streamtape/direct?file=JwA6mOGePqcjx9j",
      rating: 9.2,
      releaseYear: 2026,
      duration: "340 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 17800,
      sharesCount: 2950,
      viewsLabel: "1.9M views",
      cast: const [],
      comments: const [],
    ),
    MovieItem(
      id: "DPpooL2WYgtk9bD",
      title: "Our Sticky Love — S01 · EP 09",
      seriesName: "Our Sticky Love",
      episodeLabel: "S01 · EP 09",
      episodeNumber: 9,
      tagline: "Season Finale — Love conquers all.",
      synopsis:
          "Episode 9 (Finale): The unforgettable romantic conclusion in 720p Dual Audio (Hindi & English).",
      posterUrl:
          "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
      backdropUrl:
          "https://thumb.tapecontent.net/thumb/DPpooL2WYgtk9bD/LdRyB0Z8dYiRrYd.jpg",
      embedUrl: "https://streamtape.com/e/DPpooL2WYgtk9bD",
      videoStreamUrl: "/api/streamtape/direct?file=DPpooL2WYgtk9bD",
      rating: 9.4,
      releaseYear: 2026,
      duration: "344 MB",
      maturityRating: "PG-13",
      qualityBadge: "720p HD · Hindi/Eng",
      genres: const ["Romance", "Drama", "Comedy"],
      director: "Park Hyun-jin",
      isNewRelease: true,
      likesCount: 24100,
      sharesCount: 4620,
      viewsLabel: "2.7M views",
      cast: const [],
      comments: const [],
    ),
  ];
}
