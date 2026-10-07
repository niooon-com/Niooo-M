import "dart:convert";
import "../services/firebase_streamtape_service.dart";
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

  static String sanitizeWebImageUrl(String rawUrl) {
    final clean = FirebaseStreamtapeService.cleanCanonicalImageUrl(rawUrl);
    if (PlatformBridge.isWeb && clean.contains("tapecontent.net")) {
      return "/api/streamtape/thumb?url=${Uri.encodeComponent(clean)}";
    }
    return clean;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "seriesName": seriesName,
      "episodeLabel": episodeLabel,
      "episodeNumber": episodeNumber,
      "tagline": tagline,
      "synopsis": synopsis,
      "posterUrl": FirebaseStreamtapeService.cleanCanonicalImageUrl(posterUrl),
      "backdropUrl":
          FirebaseStreamtapeService.cleanCanonicalImageUrl(backdropUrl),
      "embedUrl": embedUrl,
      "videoStreamUrl": videoStreamUrl,
      "rating": rating,
      "releaseYear": releaseYear,
      "duration": duration,
      "maturityRating": maturityRating,
      "qualityBadge": qualityBadge,
      "genres": genres,
      "director": director,
      "isFeatured": isFeatured,
      "isTrending": isTrending,
      "isNewRelease": isNewRelease,
      "watchProgress": watchProgress,
      "likesCount": likesCount,
      "sharesCount": sharesCount,
      "viewsLabel": viewsLabel,
    };
  }

  factory MovieItem.fromStreamtapeJson(Map<String, dynamic> json) {
    final String id = (json["id"] ?? "").toString();
    final String title = (json["title"] ?? "Untitled Movie").toString();
    final String seriesName = (json["seriesName"] ?? title).toString();
    final String episodeLabel = (json["episodeLabel"] ?? "").toString();
    final int episodeNumber =
        int.tryParse((json["episodeNumber"] ?? "0").toString()) ?? 0;
    final String posterUrl =
        sanitizeWebImageUrl((json["posterUrl"] ?? "").toString());
    final String backdropUrl = sanitizeWebImageUrl(
      (json["backdropUrl"] ?? posterUrl).toString(),
    );
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
      watchProgress:
          double.tryParse((json["watchProgress"] ?? "0.0").toString()) ?? 0.0,
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
  static const String _verifiedCacheKey =
      "niooo_m_verified_live_catalog_v3";

  /// Zero hardcoded movies! All movies come 100% from the live Streamtape API + Firebase Firestore,
  /// and once fetched online, the verified catalog is cached locally so offline/slow connections
  /// work smoothly, while automatically overwriting the cache whenever internet is available.
  static const List<MovieItem> initialMovies = [];

  static bool isOfflineMode = false;

  /// Loads the last verified live catalog saved on the user's device (for instant startup or offline viewing).
  static List<MovieItem> loadCachedVerifiedCatalog() {
    try {
      final raw = PlatformBridge.getLocalStorage(_verifiedCacheKey);
      if (raw != null && raw.trim().startsWith("[")) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (m) => MovieItem.fromStreamtapeJson(
                  Map<String, dynamic>.from(m),
                ),
              )
              .where((m) => m.id.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Replaces the local cache with the latest verified live Streamtape + Firebase catalog.
  /// Any movie deleted from Streamtape is immediately removed from the local cache as well!
  static void saveVerifiedCatalogToCache(List<MovieItem> verifiedList) {
    try {
      final encoded =
          jsonEncode(verifiedList.map((m) => m.toJson()).toList());
      PlatformBridge.setLocalStorage(_verifiedCacheKey, encoded);
    } catch (_) {}
  }

  /// Fetches live movies directly from the Streamtape API (`/api/streamtape/catalog`)
  /// AND overlays any real-time poster/title updates from Firebase Firestore (`/streamtape_movies`)
  /// ONLY for movies that actively exist in Streamtape!
  /// - If a movie was deleted from Streamtape, even if its document is still in Firebase Firestore,
  ///   it is strictly filtered out and never shown.
  /// - Once verified from the live internet connection, the local cache is completely replaced
  ///   with the fresh list.
  /// - If the user has no internet connection or a very slow connection that times out, it
  ///   gracefully serves the last verified cached catalog until internet returns.
  static Future<List<MovieItem>> fetchLiveStreamtapeCatalog({
    bool forceRefresh = false,
  }) async {
    List<MovieItem> liveStreamtapeList = [];
    bool fetchedFromLiveStreamtape = false;

    try {
      final url = forceRefresh
          ? "/api/streamtape/catalog?refresh=1"
          : "/api/streamtape/catalog";
      final responseText = await PlatformBridge.httpGetString(url);
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic> && decoded["movies"] is List) {
        final List<dynamic> rawList = decoded["movies"] as List<dynamic>;
        liveStreamtapeList = rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => MovieItem.fromStreamtapeJson(item))
            .where((m) => m.id.isNotEmpty)
            .toList();
        if (liveStreamtapeList.isNotEmpty) {
          fetchedFromLiveStreamtape = true;
        }
      }
    } catch (_) {}

    // If online and we received the live verified list from Streamtape API:
    if (fetchedFromLiveStreamtape) {
      isOfflineMode = false;
      try {
        final fsMap = await FirebaseStreamtapeService.instance
            .fetchAllFirestoreMoviesMap();
        if (fsMap.isNotEmpty) {
          final Set<String> deletedIds = {};
          fsMap.forEach((fid, data) {
            if (data["isDeleted"] == true) {
              deletedIds.add(fid);
            }
          });

          final List<MovieItem> verifiedMerged = [];
          for (final movie in liveStreamtapeList) {
            if (deletedIds.contains(movie.id)) continue;

            final fsDoc = fsMap[movie.id];
            if (fsDoc != null && fsDoc["isCustomOverride"] == true) {
              final fsPoster = (fsDoc["posterUrl"] ?? "").toString().trim();
              final fsBackdrop =
                  (fsDoc["backdropUrl"] ?? "").toString().trim();
              final fsTitle = (fsDoc["title"] ?? "").toString().trim();
              final fsSeries = (fsDoc["seriesName"] ?? "").toString().trim();
              final fsQuality =
                  (fsDoc["qualityBadge"] ?? "").toString().trim();
              final fsSynopsis = (fsDoc["synopsis"] ?? "").toString().trim();

              verifiedMerged.add(
                movie.copyWith(
                  title: fsTitle.isNotEmpty ? fsTitle : movie.title,
                  seriesName:
                      fsSeries.isNotEmpty ? fsSeries : movie.seriesName,
                  posterUrl: fsPoster.isNotEmpty
                      ? MovieItem.sanitizeWebImageUrl(fsPoster)
                      : movie.posterUrl,
                  backdropUrl: fsBackdrop.isNotEmpty
                      ? MovieItem.sanitizeWebImageUrl(fsBackdrop)
                      : movie.backdropUrl,
                  qualityBadge:
                      fsQuality.isNotEmpty ? fsQuality : movie.qualityBadge,
                  synopsis:
                      fsSynopsis.isNotEmpty ? fsSynopsis : movie.synopsis,
                  isFeatured: fsDoc["isFeatured"] is bool
                      ? fsDoc["isFeatured"] as bool
                      : movie.isFeatured,
                ),
              );
            } else {
              verifiedMerged.add(movie);
            }
          }

          // Overwrite local cache with the newly verified live catalog!
          saveVerifiedCatalogToCache(verifiedMerged);
          return verifiedMerged;
        }
      } catch (_) {}

      // Save the live Streamtape list directly to local cache and return
      saveVerifiedCatalogToCache(liveStreamtapeList);
      return liveStreamtapeList;
    }

    // Offline or unstable internet fallback: return the last verified cached movies
    // (Will automatically be replaced as soon as internet reconnects!)
    isOfflineMode = true;
    return loadCachedVerifiedCatalog();
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
  /// Directly writes to BOTH Firebase Firestore AND the cloud server for instant real-time sync!
  static Future<bool> saveAdminMovieOverride(
    Map<String, dynamic> payload, {
    MovieItem? fullMovie,
  }) async {
    bool firestoreSaved = false;
    try {
      final id = (payload["id"] ?? fullMovie?.id ?? "").toString().trim();
      if (id.isNotEmpty) {
        final base = fullMovie ??
            MovieItem.fromStreamtapeJson({
              "id": id,
              ...payload,
            });
        final updatedItem = base.copyWith(
          title: payload["title"]?.toString() ?? base.title,
          seriesName: payload["seriesName"]?.toString() ?? base.seriesName,
          posterUrl: payload["posterUrl"]?.toString() ?? base.posterUrl,
          backdropUrl: payload["backdropUrl"]?.toString() ?? base.backdropUrl,
          qualityBadge:
              payload["qualityBadge"]?.toString() ?? base.qualityBadge,
          synopsis: payload["synopsis"]?.toString() ?? base.synopsis,
          isFeatured: payload["isFeatured"] is bool
              ? payload["isFeatured"] as bool
              : base.isFeatured,
        );
        firestoreSaved = await FirebaseStreamtapeService.instance
            .upsertMovieToFirestore(
          updatedItem,
          isCustomOverride: true,
          isDeleted: false,
        );
      }
    } catch (_) {}

    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/movie",
        payload,
      );
      return firestoreSaved || status == 200;
    } catch (_) {
      return firestoreSaved;
    }
  }

  /// Deletes/hides a movie from the catalog via Admin Panel across Firebase Firestore & Server
  static Future<bool> deleteAdminMovie(
    String id, {
    MovieItem? movie,
  }) async {
    bool firestoreDeleted = false;
    try {
      final item = movie ??
          MovieItem.fromStreamtapeJson({
            "id": id,
            "title": "Hidden Movie",
          });
      firestoreDeleted = await FirebaseStreamtapeService.instance
          .upsertMovieToFirestore(
        item,
        isCustomOverride: true,
        isDeleted: true,
      );
    } catch (_) {}

    // Also remove from local cache immediately so it never flashes
    try {
      final cached = loadCachedVerifiedCatalog()
          .where((m) => m.id != id)
          .toList();
      saveVerifiedCatalogToCache(cached);
    } catch (_) {}

    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/delete",
        {"id": id},
      );
      return firestoreDeleted || status == 200;
    } catch (_) {
      return firestoreDeleted;
    }
  }

  /// Restores any deleted Streamtape movies via Admin Panel
  static Future<bool> restoreDeletedMovies() async {
    try {
      final fsMap =
          await FirebaseStreamtapeService.instance.fetchAllFirestoreMoviesMap();
      for (final entry in fsMap.entries) {
        if (entry.value["isDeleted"] == true) {
          final restored = MovieItem.fromStreamtapeJson(entry.value);
          await FirebaseStreamtapeService.instance.upsertMovieToFirestore(
            restored,
            isCustomOverride: entry.value["isCustomOverride"] == true,
            isDeleted: false,
          );
        }
      }
    } catch (_) {}

    try {
      final status = await PlatformBridge.httpPostJson(
        "/api/streamtape/admin/restore",
        {},
      );
      return status == 200;
    } catch (_) {
      return true;
    }
  }

  /// Fetches current Streamtape API login & key from Firebase Firestore (`/streamtape_config/primary`)
  static Future<Map<String, String>> fetchStreamtapeCredentials() async {
    try {
      final fsCreds = await FirebaseStreamtapeService.instance
          .fetchFirebaseStreamtapeCredentials();
      if ((fsCreds["login"] ?? "").isNotEmpty &&
          (fsCreds["key"] ?? "").isNotEmpty) {
        return fsCreds;
      }
    } catch (_) {}

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

  /// Updates Streamtape API login & key in Firebase Firestore (`/streamtape_config/primary`) and Server
  static Future<bool> updateStreamtapeCredentials(
    String login,
    String key,
  ) async {
    final cleanLogin = login.trim();
    final cleanKey = key.trim();
    if (cleanLogin.isEmpty || cleanKey.isEmpty) return false;

    final fsSaved = await FirebaseStreamtapeService.instance
        .saveFirebaseStreamtapeCredentials(cleanLogin, cleanKey);

    try {
      final resText = await PlatformBridge.httpPostJsonResponse(
        "/api/streamtape/credentials",
        {"login": cleanLogin, "key": cleanKey},
      );
      if (resText != null) {
        final decoded = jsonDecode(resText);
        if (decoded is Map && decoded["valid"] == true) {
          return true;
        }
      }
    } catch (_) {}
    return fsSaved;
  }
}
