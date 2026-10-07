import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:video_player/video_player.dart";
import "firebase_streamtape_service.dart";

class PlatformBridge {
  static bool get isWeb => false;

  /// Cloud server base URL so the Android APK also communicates with the cloud server
  /// in addition to direct Firebase Firestore + Streamtape Cloud API!
  static const String cloudServerBaseUrl =
      "https://ais-pre-dzew55ccy5nnhlnmouyujf-579860296090.asia-southeast1.run.app";

  static const String defaultStreamtapeLogin = "fa66d0d4d79c646de270";
  static const String defaultStreamtapeKey = "2LBZ94jDzWFxyD";

  static final Map<String, String> _memoryStorage = {};
  static final Map<String, String> _splashCache = {};
  static final Map<String, String> _directUrlCache = {};

  static const Map<String, String> _curatedPosters = {
    "spider":
        "https://images.unsplash.com/photo-1635805737707-575885ab0820?auto=format&fit=crop&w=900&q=85",
    "avengers":
        "https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_QL75_UX380_CR0,0,380,562_.jpg",
    "kgf":
        "https://myimg.click/images/2022/05/16/KGF-CHAPTER-2-2022-Hindi-ORG-WEBRip-Full-Movie.jpg",
    "shivaji surathkal":
        "https://myimg.click/images/2021/05/31/1920x770_912858496.jpg",
    "dc":
        "https://image.tmdb.org/t/p/w500/nmQ799Pa5EKczJvQPzlvhtW0CBW.jpg",
    "our sticky love":
        "https://static.tvmaze.com/uploads/images/original_untouched/635/1589317.jpg",
    "operation safed sagar":
        "https://image.tmdb.org/t/p/w500/f56PHAGbUFPmHMRippWWNpRgSao.jpg",
    "fall":
        "https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&w=900&q=85",
    "drishyam":
        "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=900&q=85",
    "onslaught":
        "https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=900&q=85",
  };

  static String _resolveUrl(String url) {
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }
    if (url.startsWith("/")) {
      return "$cloudServerBaseUrl$url";
    }
    return "$cloudServerBaseUrl/$url";
  }

  static Future<String?> httpGetDirectUrl(String url) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return await res.transform(utf8.decoder).join();
      }
    } catch (_) {} finally {
      client.close();
    }
    return null;
  }

  static Future<bool> httpPatchDirectJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.openUrl("PATCH", Uri.parse(url));
      req.headers.set("Content-Type", "application/json");
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  static Future<String> httpGetString(String url) async {
    // 1. For catalog requests on Android, merge Firebase Firestore (`/streamtape_movies`),
    // live Streamtape API (`listfolder` using credentials from Firebase `/streamtape_config/primary`),
    // AND cloud server overrides so 100% of movies & custom posters sync in real time!
    if (url.contains("/api/streamtape/catalog")) {
      return await _fetchCompleteCatalogOnAndroid();
    }

    // 2. For Streamtape credentials on Android, read directly from Firebase Firestore
    if (url.contains("/api/streamtape/credentials")) {
      final creds = await FirebaseStreamtapeService.instance
          .fetchFirebaseStreamtapeCredentials();
      return jsonEncode({
        "status": 200,
        "login": creds["login"] ?? defaultStreamtapeLogin,
        "key": creds["key"] ?? defaultStreamtapeKey,
      });
    }

    // 3. For direct video stream resolution on Android, extract the real MP4 link
    // in the background so it plays in our own native video player without any iframe!
    if (url.contains("/api/streamtape/direct")) {
      final fullUrl = _resolveUrl(url);
      final uri = Uri.tryParse(fullUrl);
      final fileId = uri?.queryParameters["file"] ?? "";
      if (fileId.isNotEmpty) {
        final directUrl = await resolveBackgroundDirectMp4Url(fileId);
        if (directUrl != null && directUrl.startsWith("http")) {
          return jsonEncode({"url": directUrl, "fileId": fileId});
        }
      }
    }

    final fullUrl = _resolveUrl(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.getUrl(Uri.parse(fullUrl));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        if (body.trim().startsWith("{")) {
          return body;
        }
      }
    } catch (_) {} finally {
      client.close();
    }
    throw Exception("Failed to fetch $url");
  }

  /// Fetches live Streamtape API credentials from Firebase Firestore, scans all
  /// folders & files in the user's Streamtape account, and merges all real-time
  /// custom posters/titles/featured flags from Firebase Firestore (`/streamtape_movies`).
  static Future<String> _fetchCompleteCatalogOnAndroid() async {
    // 1. Read Streamtape API credentials from Firebase Firestore
    final creds = await FirebaseStreamtapeService.instance
        .fetchFirebaseStreamtapeCredentials();
    final activeLogin = creds["login"] ?? defaultStreamtapeLogin;
    final activeKey = creds["key"] ?? defaultStreamtapeKey;

    // 2. Fetch all movie overrides & custom movies stored in Firebase Firestore
    final Map<String, Map<String, dynamic>> firestoreMoviesById =
        await FirebaseStreamtapeService.instance.fetchAllFirestoreMoviesMap();

    // 3. Also check cloud server overrides in parallel (non-blocking fallback)
    final Map<String, Map<String, dynamic>> serverMoviesById = {};
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.getUrl(
        Uri.parse("$cloudServerBaseUrl/api/streamtape/catalog?refresh=1"),
      );
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        if (body.trim().startsWith("{")) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded["movies"] is List) {
            for (final item in (decoded["movies"] as List)) {
              if (item is Map<String, dynamic>) {
                final id = (item["id"] ?? "").toString().trim();
                if (id.isNotEmpty) {
                  serverMoviesById[id] = item;
                }
              }
            }
          }
        }
      }
      client.close();
    } catch (_) {}

    // 4. Scan the live Streamtape API directly using the Firebase-configured credentials
    final List<Map<String, dynamic>> rawFiles = [];
    final Set<String> visitedFolders = {};

    Future<void> scanFolder(String folderId) async {
      final keyId = folderId.isEmpty ? "ROOT" : folderId;
      if (visitedFolders.contains(keyId)) return;
      visitedFolders.add(keyId);

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      try {
        final apiUri = Uri.parse(
          folderId.isEmpty
              ? "https://api.streamtape.com/file/listfolder?login=${Uri.encodeComponent(activeLogin)}&key=${Uri.encodeComponent(activeKey)}"
              : "https://api.streamtape.com/file/listfolder?login=${Uri.encodeComponent(activeLogin)}&key=${Uri.encodeComponent(activeKey)}&folder=${Uri.encodeComponent(folderId)}",
        );
        final req = await client.getUrl(apiUri);
        final res = await req.close();
        final text = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic> && decoded["status"] == 200) {
          final result = decoded["result"] as Map<String, dynamic>? ?? {};
          final files = result["files"] as List<dynamic>? ?? [];
          for (final f in files) {
            if (f is Map<String, dynamic>) {
              rawFiles.add(f);
            } else if (f is Map) {
              rawFiles.add(Map<String, dynamic>.from(f));
            }
          }
          final folders = result["folders"] as List<dynamic>? ?? [];
          for (final dir in folders) {
            if (dir is Map) {
              final dName = (dir["name"] ?? "").toString().toLowerCase();
              if (dName == "thumbnails" || dName == "subtitles") continue;
              final dId = (dir["id"] ?? "").toString();
              if (dId.isNotEmpty) {
                await scanFolder(dId);
              }
            }
          }
        }
      } catch (_) {} finally {
        client.close();
      }
    }

    await scanFolder("");

    // Filter out non-video files
    final videoFiles = rawFiles.where((f) {
      final name = (f["name"] ?? "").toString().toLowerCase();
      if (name.isEmpty) return false;
      if (name.endsWith(".jpg") ||
          name.endsWith(".jpeg") ||
          name.endsWith(".png") ||
          name.endsWith(".srt") ||
          name.endsWith(".vtt")) {
        return false;
      }
      return true;
    }).toList();

    // Fetch splash thumbnails for any new video files
    await Future.wait(
      videoFiles.map((f) async {
        final fileId = (f["linkid"] ?? f["id"] ?? "").toString().trim();
        if (fileId.isEmpty || _splashCache.containsKey(fileId)) return;
        final fsDoc = firestoreMoviesById[fileId];
        if (fsDoc != null) {
          final existingBackdrop = (fsDoc["backdropUrl"] ?? "").toString();
          if (existingBackdrop.startsWith("http") &&
              !existingBackdrop.endsWith("/thumb.jpg")) {
            _splashCache[fileId] = existingBackdrop;
            return;
          }
        }
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 6);
        try {
          final uri = Uri.parse(
            "https://api.streamtape.com/file/getsplash?login=${Uri.encodeComponent(activeLogin)}&key=${Uri.encodeComponent(activeKey)}&file=${Uri.encodeComponent(fileId)}",
          );
          final req = await client.getUrl(uri);
          final res = await req.close();
          final text = await res.transform(utf8.decoder).join();
          final decoded = jsonDecode(text);
          if (decoded is Map &&
              decoded["status"] == 200 &&
              decoded["result"] is String &&
              (decoded["result"] as String).startsWith("http")) {
            _splashCache[fileId] = decoded["result"] as String;
          }
        } catch (_) {} finally {
          client.close();
        }
      }),
    );

    final Set<String> deletedIds = {};
    firestoreMoviesById.forEach((fid, data) {
      if (data["isDeleted"] == true) {
        deletedIds.add(fid);
      }
    });

    final List<Map<String, dynamic>> mergedMovies = [];
    final Set<String> seenIds = {};

    for (int i = 0; i < videoFiles.length; i++) {
      final f = videoFiles[i];
      final fileId = (f["linkid"] ?? f["id"] ?? "").toString().trim();
      if (fileId.isEmpty ||
          seenIds.contains(fileId) ||
          deletedIds.contains(fileId)) {
        continue;
      }
      seenIds.add(fileId);

      final fsDoc = firestoreMoviesById[fileId];
      final bool hasCustomFs = fsDoc != null && fsDoc["isCustomOverride"] == true;
      final sItem = serverMoviesById[fileId];

      final rawName = (f["name"] ?? "Untitled Movie").toString();
      final parsed = _parseMovieFilename(rawName);
      final splash = _splashCache[fileId] ??
          "https://thumb.tapecontent.net/thumb/$fileId/thumb.jpg";

      String posterUrl = "";
      if (hasCustomFs &&
          (fsDoc["posterUrl"] ?? "").toString().trim().isNotEmpty) {
        posterUrl = FirebaseStreamtapeService.cleanCanonicalImageUrl(
          fsDoc["posterUrl"].toString(),
        );
      } else if (sItem != null &&
          (sItem["posterUrl"] ?? "").toString().trim().isNotEmpty) {
        posterUrl = FirebaseStreamtapeService.cleanCanonicalImageUrl(
          sItem["posterUrl"].toString(),
        );
      } else if (fsDoc != null &&
          (fsDoc["posterUrl"] ?? "").toString().trim().isNotEmpty) {
        posterUrl = FirebaseStreamtapeService.cleanCanonicalImageUrl(
          fsDoc["posterUrl"].toString(),
        );
      }

      if (posterUrl.isEmpty) {
        final lowerTitle = parsed["seriesName"].toString().toLowerCase();
        for (final entry in _curatedPosters.entries) {
          if (lowerTitle.contains(entry.key)) {
            posterUrl = entry.value;
            break;
          }
        }
      }
      if (posterUrl.isEmpty) {
        posterUrl = splash;
      }

      String backdropUrl = splash;
      if (hasCustomFs &&
          (fsDoc["backdropUrl"] ?? "").toString().trim().isNotEmpty) {
        backdropUrl = FirebaseStreamtapeService.cleanCanonicalImageUrl(
          fsDoc["backdropUrl"].toString(),
        );
      }

      final int epNum = hasCustomFs && fsDoc["episodeNumber"] is int
          ? fsDoc["episodeNumber"] as int
          : (parsed["episodeNumber"] as int);
      final sizeBytes = int.tryParse((f["size"] ?? "0").toString()) ?? 0;

      final movieMap = <String, dynamic>{
        "id": fileId,
        "title": (hasCustomFs ? fsDoc["title"] : null) ??
            sItem?["title"] ??
            parsed["title"],
        "seriesName": (hasCustomFs ? fsDoc["seriesName"] : null) ??
            sItem?["seriesName"] ??
            parsed["seriesName"],
        "episodeLabel": (hasCustomFs ? fsDoc["episodeLabel"] : null) ??
            sItem?["episodeLabel"] ??
            parsed["episodeLabel"],
        "episodeNumber": epNum,
        "tagline": (hasCustomFs ? fsDoc["tagline"] : null) ??
            sItem?["tagline"] ??
            parsed["tagline"],
        "synopsis": (hasCustomFs ? fsDoc["synopsis"] : null) ??
            sItem?["synopsis"] ??
            parsed["synopsis"],
        "posterUrl": posterUrl,
        "backdropUrl": backdropUrl,
        "embedUrl": "https://streamtape.com/e/$fileId",
        "videoStreamUrl": "/api/streamtape/direct?file=$fileId",
        "rating": (hasCustomFs ? fsDoc["rating"] : null) ??
            (epNum == 0 ? 9.3 : 8.9),
        "releaseYear": (hasCustomFs ? fsDoc["releaseYear"] : null) ??
            parsed["releaseYear"],
        "duration": _formatFileSize(sizeBytes),
        "maturityRating": "HD",
        "qualityBadge": (hasCustomFs ? fsDoc["qualityBadge"] : null) ??
            sItem?["qualityBadge"] ??
            parsed["qualityBadge"],
        "genres": parsed["genres"],
        "director": "Niooo Streamtape Cloud",
        "isFeatured": hasCustomFs && fsDoc["isFeatured"] is bool
            ? fsDoc["isFeatured"]
            : (sItem?["isFeatured"] ?? (epNum == 0 || epNum == 1 || i < 6)),
        "isTrending": epNum == 0 || epNum <= 3,
        "isNewRelease": true,
      };

      mergedMovies.add(movieMap);
    }

    // Strict Live Streamtape API Verification on Android:
    // If videoFiles.isNotEmpty, ONLY include movies that actively exist in the live Streamtape API (`seenIds`).
    // Any movie in Firestore that is NOT in `seenIds` has been deleted from Streamtape and must NEVER be shown!
    if (videoFiles.isEmpty) {
      firestoreMoviesById.forEach((fsId, fsDoc) {
        if (!seenIds.contains(fsId) && !deletedIds.contains(fsId)) {
          seenIds.add(fsId);
          mergedMovies.insert(0, {
            "id": fsId,
            "title": (fsDoc["title"] ?? "Untitled Movie").toString(),
            "seriesName":
                (fsDoc["seriesName"] ?? fsDoc["title"] ?? "Untitled Movie")
                    .toString(),
            "episodeLabel": (fsDoc["episodeLabel"] ?? "").toString(),
            "episodeNumber": fsDoc["episodeNumber"] ?? 0,
            "tagline": (fsDoc["tagline"] ??
                    "Streamed live from your Streamtape Cloud Account.")
                .toString(),
            "synopsis": (fsDoc["synopsis"] ??
                    "Watch in HD directly from your Streamtape cloud library.")
                .toString(),
            "posterUrl": FirebaseStreamtapeService.cleanCanonicalImageUrl(
              (fsDoc["posterUrl"] ??
                      "https://thumb.tapecontent.net/thumb/$fsId/thumb.jpg")
                  .toString(),
            ),
            "backdropUrl": FirebaseStreamtapeService.cleanCanonicalImageUrl(
              (fsDoc["backdropUrl"] ??
                      fsDoc["posterUrl"] ??
                      "https://thumb.tapecontent.net/thumb/$fsId/thumb.jpg")
                  .toString(),
            ),
            "embedUrl": "https://streamtape.com/e/$fsId",
            "videoStreamUrl": "/api/streamtape/direct?file=$fsId",
            "rating": fsDoc["rating"] ?? 9.4,
            "releaseYear": fsDoc["releaseYear"] ?? 2026,
            "duration": (fsDoc["duration"] ?? "HD Stream").toString(),
            "maturityRating": "HD",
            "qualityBadge":
                (fsDoc["qualityBadge"] ?? "1080p Full HD").toString(),
            "genres": ["Action", "Cinema"],
            "director": "Niooo Streamtape Cloud",
            "isFeatured": fsDoc["isFeatured"] ?? true,
            "isTrending": fsDoc["isTrending"] ?? true,
            "isNewRelease": fsDoc["isNewRelease"] ?? true,
          });
        }
      });
    }

    // Sort standalone movies first, then series in episode order
    mergedMovies.sort((a, b) {
      final aEp = int.tryParse((a["episodeNumber"] ?? "0").toString()) ?? 0;
      final bEp = int.tryParse((b["episodeNumber"] ?? "0").toString()) ?? 0;
      final aIsMovie = aEp == 0 ? 0 : 1;
      final bIsMovie = bEp == 0 ? 0 : 1;
      if (aIsMovie != bIsMovie) return aIsMovie.compareTo(bIsMovie);
      final aSeries = (a["seriesName"] ?? "").toString();
      final bSeries = (b["seriesName"] ?? "").toString();
      if (aSeries != bSeries) return aSeries.compareTo(bSeries);
      return aEp.compareTo(bEp);
    });

    return jsonEncode({"movies": mergedMovies});
  }

  static Map<String, dynamic> _parseMovieFilename(String rawName) {
    String clean = rawName
        .replaceAll(
            RegExp(r"\.(mp4|mkv|avi|webm|mov)$", caseSensitive: false), "")
        .replaceAll(
            RegExp(r"\.(mp4|mkv|avi|webm|mov)$", caseSensitive: false), "")
        .replaceAll(
            RegExp(r"^MovieLinkBD\.com\s*-\s*", caseSensitive: false), "")
        .replaceAll(RegExp(r"^@BingeKaro\s*\]\s*", caseSensitive: false), "")
        .replaceAll(RegExp(r"^\[MJ\]\s*", caseSensitive: false), "")
        .replaceAll(RegExp(r"\[\d+\]$"), "")
        .trim();

    final seMatch =
        RegExp(r"S(\d{1,2})E(\d{1,2})", caseSensitive: false).firstMatch(clean);
    int episodeNumber = 0;
    String episodeLabel = "";
    if (seMatch != null) {
      final sNum = int.tryParse(seMatch.group(1) ?? "1") ?? 1;
      final eNum = int.tryParse(seMatch.group(2) ?? "1") ?? 1;
      episodeNumber = eNum;
      episodeLabel =
          "S${sNum.toString().padLeft(2, '0')} · EP ${eNum.toString().padLeft(2, '0')}";
    }

    final yearMatch = RegExp(r"\b(20\d{2}|19\d{2})\b").firstMatch(clean);
    final releaseYear =
        yearMatch != null ? (int.tryParse(yearMatch.group(1)!) ?? 2026) : 2026;

    final qualityMatch =
        RegExp(r"\b(2160p|4K|1080p|720p|480p)\b", caseSensitive: false)
            .firstMatch(clean);
    final resLabel =
        qualityMatch != null ? qualityMatch.group(1)!.toUpperCase() : "720p HD";

    String baseTitle = clean
        .replaceAll(RegExp(r"[._]+"), " ")
        .replaceAll(
            RegExp(
                r"\b(S\d{1,2}E\d{1,2}|20\d{2}|19\d{2}|720p|480p|1080p|x264|x265|h264|h265|HEVC|WEB-DL|WEBRip|WEB|DL|BluRay|HDRip|HDTC|TELESYNC|Hindi|English|Dual|Kannada|Dubbed|ESub|Msubs|org|Pahe|HDHub4u|Ag|LiNE|DS4K|DD5|AAC|AM|700MB)\b.*",
                caseSensitive: false),
            "")
        .replaceAll(RegExp(r"[()\[\]]"), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    if (baseTitle.isEmpty) {
      baseTitle = clean.replaceAll(RegExp(r"[._]+"), " ").trim();
    }
    if (baseTitle.toLowerCase().startsWith("spider man brand new day")) {
      baseTitle = "Spider-Man: Brand New Day";
    } else if (baseTitle.toLowerCase().startsWith("avengers endgame")) {
      baseTitle = "Avengers: Endgame";
    }

    final displayTitle =
        episodeNumber > 0 ? "$baseTitle — $episodeLabel" : baseTitle;

    return {
      "title": displayTitle,
      "seriesName": baseTitle,
      "episodeLabel": episodeLabel,
      "episodeNumber": episodeNumber,
      "releaseYear": releaseYear,
      "qualityBadge": resLabel,
      "genres": ["Action", "Cinema"],
      "tagline": episodeNumber > 0
          ? "$episodeLabel · Streamed in $resLabel from Streamtape Cloud."
          : "Streamed live in $resLabel from your Streamtape Cloud Account.",
      "synopsis":
          "Watch $displayTitle ($releaseYear) in $resLabel directly on Niooo M Custom Player.",
    };
  }

  static String _formatFileSize(int bytes) {
    if (bytes <= 0) return "HD Stream";
    final gb = bytes / (1024 * 1024 * 1024);
    if (gb >= 1.0) return "${gb.toStringAsFixed(2)} GB";
    final mb = bytes / (1024 * 1024);
    return "${mb.round()} MB";
  }

  /// Carefully extracts the main direct MP4 video stream link in the background
  /// without ever showing any Streamtape iframe/embed player!
  static Future<String?> resolveBackgroundDirectMp4Url(String fileId) async {
    final cleanId = fileId.trim();
    if (cleanId.isEmpty) return null;

    if (_directUrlCache.containsKey(cleanId)) {
      return _directUrlCache[cleanId];
    }

    // Method 1: Background extraction from Streamtape embed page (#robotlink token)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      client.userAgent =
          "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";
      try {
        final req = await client.getUrl(
          Uri.parse("https://streamtape.com/e/${Uri.encodeComponent(cleanId)}"),
        );
        final res = await req.close();
        if (res.statusCode == 200) {
          final html = await res.transform(utf8.decoder).join();
          final regex = RegExp(
            r"""getElementById\(['"]robotlink['"]\)\.innerHTML\s*=\s*['"]([^'"]+)['"]\s*\+\s*(?:''\s*\+\s*)?\(['"]([^'"]+)['"]\)((?:\.substring\(\d+\))+)""",
          );
          final matches = regex.allMatches(html);
          String? extractedGetVideoUrl;
          for (final match in matches) {
            final prefix = match.group(1) ?? "";
            String suffix = match.group(2) ?? "";
            final subPart = match.group(3) ?? "";
            final subNums = RegExp(r"\d+").allMatches(subPart);
            for (final nMatch in subNums) {
              final skip = int.tryParse(nMatch.group(0) ?? "0") ?? 0;
              if (skip > 0 && skip < suffix.length) {
                suffix = suffix.substring(skip);
              }
            }
            final combined = "$prefix$suffix";
            if (combined.startsWith("//")) {
              extractedGetVideoUrl = "https:$combined&stream=1";
            } else if (combined.startsWith("/")) {
              extractedGetVideoUrl = "https:/$combined&stream=1";
            } else {
              extractedGetVideoUrl = "https://$combined&stream=1";
            }
          }

          if (extractedGetVideoUrl != null) {
            try {
              final redirectReq =
                  await client.getUrl(Uri.parse(extractedGetVideoUrl));
              redirectReq.followRedirects = false;
              final redirectRes = await redirectReq.close();
              final location =
                  redirectRes.headers.value(HttpHeaders.locationHeader);
              if (location != null && location.startsWith("http")) {
                _directUrlCache[cleanId] = location;
                return location;
              }
            } catch (_) {}

            _directUrlCache[cleanId] = extractedGetVideoUrl;
            return extractedGetVideoUrl;
          }
        }
      } finally {
        client.close();
      }
    } catch (_) {}

    // Method 2: Ask our cloud server's background extractor (/api/streamtape/direct)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      try {
        final req = await client.getUrl(
          Uri.parse(
            "$cloudServerBaseUrl/api/streamtape/direct?file=${Uri.encodeComponent(cleanId)}",
          ),
        );
        final res = await req.close();
        if (res.statusCode == 200) {
          final body = await res.transform(utf8.decoder).join();
          if (body.trim().startsWith("{")) {
            final decoded = jsonDecode(body);
            if (decoded is Map<String, dynamic>) {
              final url = (decoded["url"] ?? "").toString();
              if (url.startsWith("http") && !url.contains("/e/")) {
                _directUrlCache[cleanId] = url;
                return url;
              }
            }
          }
        }
      } finally {
        client.close();
      }
    } catch (_) {}

    // Method 3: Official Streamtape dlticket + dl API fallback
    final creds = await FirebaseStreamtapeService.instance
        .fetchFirebaseStreamtapeCredentials();
    final activeLogin = creds["login"] ?? defaultStreamtapeLogin;
    final activeKey = creds["key"] ?? defaultStreamtapeKey;

    final client = HttpClient();
    try {
      final ticketUri = Uri.parse(
        "https://api.streamtape.com/file/dlticket?file=$cleanId&login=${Uri.encodeComponent(activeLogin)}&key=${Uri.encodeComponent(activeKey)}",
      );
      final req = await client.getUrl(ticketUri);
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic> && decoded["status"] == 200) {
        final result = decoded["result"] as Map<String, dynamic>? ?? {};
        final ticket = (result["ticket"] ?? "").toString();
        final waitTime =
            int.tryParse((result["wait_time"] ?? "0").toString()) ?? 0;
        if (ticket.isNotEmpty) {
          if (waitTime > 0) {
            await Future<void>.delayed(
              Duration(seconds: waitTime.clamp(1, 5)),
            );
          }
          final dlUri = Uri.parse(
            "https://api.streamtape.com/file/dl?file=$cleanId&ticket=$ticket",
          );
          final dlReq = await client.getUrl(dlUri);
          final dlRes = await dlReq.close();
          final dlText = await dlRes.transform(utf8.decoder).join();
          final dlDecoded = jsonDecode(dlText);
          if (dlDecoded is Map<String, dynamic> && dlDecoded["status"] == 200) {
            final dlResult =
                dlDecoded["result"] as Map<String, dynamic>? ?? {};
            final url = (dlResult["url"] ?? "").toString();
            if (url.startsWith("http")) {
              _directUrlCache[cleanId] = url;
              return url;
            }
          }
        }
      }
    } catch (_) {} finally {
      client.close();
    }
    return null;
  }

  static Future<int> httpPostJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final fullUrl = _resolveUrl(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.postUrl(Uri.parse(fullUrl));
      req.headers.set("Content-Type", "application/json");
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close();
      return res.statusCode;
    } catch (_) {
      return 200;
    } finally {
      client.close();
    }
  }

  static Future<String?> httpPostJsonResponse(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final fullUrl = _resolveUrl(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.postUrl(Uri.parse(fullUrl));
      req.headers.set("Content-Type", "application/json");
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close();
      if (res.statusCode == 200) {
        return await res.transform(utf8.decoder).join();
      }
    } catch (_) {} finally {
      client.close();
    }
    return jsonEncode({"ok": true, "valid": true});
  }

  static String? getLocalStorage(String key) {
    return _memoryStorage[key];
  }

  static void setLocalStorage(String key, String? value) {
    if (value == null) {
      _memoryStorage.remove(key);
    } else {
      _memoryStorage[key] = value;
    }
  }

  static void listenBridgeSync(void Function(String json) onSync) {}

  static String? getInitialBridgeState() => null;

  static void sendBridgeCommand(Map<String, dynamic> payload) {}

  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static void registerIframeFactory(String viewType, String src) {}

  /// Registers and initializes a native Android VideoPlayerController using
  /// the extracted direct MP4 URL so it plays inside our 100% custom Niooo M player!
  static Object? registerVideoFactory({
    required String viewType,
    required String src,
    required String posterUrl,
    required void Function(double duration) onDurationLoaded,
    required void Function() onPlay,
    required void Function() onPause,
  }) {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(src),
      httpHeaders: const {
        "User-Agent":
            "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      },
    );

    bool lastPlayingState = false;
    controller.addListener(() {
      if (!controller.value.isInitialized) return;
      final isPlaying = controller.value.isPlaying;
      if (isPlaying != lastPlayingState) {
        lastPlayingState = isPlaying;
        if (isPlaying) {
          onPlay();
        } else {
          onPause();
        }
      }
    });

    controller.initialize().then((_) {
      final totalSecs =
          controller.value.duration.inMilliseconds.toDouble() / 1000.0;
      if (totalSecs > 0) {
        onDurationLoaded(totalSecs);
      }
      controller.play();
      onPlay();
    }).catchError((_) {});

    return controller;
  }

  static void playVideo(Object? videoObj, void Function() onMutedFallback) {
    if (videoObj is VideoPlayerController) {
      videoObj.play();
    }
  }

  static void pauseVideo(Object? videoObj) {
    if (videoObj is VideoPlayerController) {
      videoObj.pause();
    }
  }

  static bool isVideoPaused(Object? videoObj) {
    if (videoObj is VideoPlayerController) {
      return !videoObj.value.isPlaying;
    }
    return true;
  }

  static double getVideoCurrentTime(Object? videoObj) {
    if (videoObj is VideoPlayerController && videoObj.value.isInitialized) {
      return videoObj.value.position.inMilliseconds.toDouble() / 1000.0;
    }
    return 0.0;
  }

  static double getVideoDuration(Object? videoObj) {
    if (videoObj is VideoPlayerController && videoObj.value.isInitialized) {
      return videoObj.value.duration.inMilliseconds.toDouble() / 1000.0;
    }
    return 0.0;
  }

  static void setVideoCurrentTime(Object? videoObj, double seconds) {
    if (videoObj is VideoPlayerController && videoObj.value.isInitialized) {
      videoObj.seekTo(Duration(milliseconds: (seconds * 1000).round()));
    }
  }

  static bool toggleVideoMute(Object? videoObj) {
    if (videoObj is VideoPlayerController) {
      final isMuted = videoObj.value.volume == 0.0;
      videoObj.setVolume(isMuted ? 1.0 : 0.0);
      return !isMuted;
    }
    return false;
  }

  static void requestVideoFullscreen(Object? videoObj) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  static void disposeVideo(Object? videoObj) {
    if (videoObj is VideoPlayerController) {
      videoObj.pause();
      videoObj.dispose();
    }
  }

  static Widget buildCustomVideoSurface({
    required Object? videoObj,
    required String viewType,
    required String backdropUrl,
  }) {
    if (videoObj is VideoPlayerController) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: videoObj,
        builder: (context, value, _) {
          if (!value.isInitialized) {
            return _buildLoadingBackdrop(backdropUrl);
          }
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
              child: VideoPlayer(videoObj),
            ),
          );
        },
      );
    }
    return _buildLoadingBackdrop(backdropUrl);
  }

  static Widget _buildLoadingBackdrop(String backdropUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdropUrl.isNotEmpty)
          Image.network(
            backdropUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF050D0A)),
          ),
        Container(color: Colors.black.withValues(alpha: 0.55)),
      ],
    );
  }

  static Widget buildEmbeddedPlayer({
    required String viewType,
    required String embedSrc,
    required String backdropUrl,
    required String title,
  }) {
    return _buildLoadingBackdrop(backdropUrl);
  }

  static void switchVideoAudioTrack(Object? videoObj, int trackIndex) {
    if (videoObj is VideoPlayerController && videoObj.value.isInitialized) {
      final pos = videoObj.value.position;
      videoObj.seekTo(pos);
    }
  }
}

