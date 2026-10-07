import "dart:async";
import "dart:convert";
import "package:flutter/foundation.dart";
import "../models/movie_models.dart";
import "platform_bridge.dart";

/// ============================================================================
/// NIOOO M — REAL-TIME FIREBASE FIRESTORE + STREAMTAPE CLOUD ENGINE
/// ============================================================================
/// Connects the Flutter project (both Web and Android Release APK) directly to
/// our Firebase Firestore database (`niooocc` / `ai-studio-niooonflutterstu-...`)
/// AND the Streamtape API configured inside Firebase (`/streamtape_config/primary`).
///
/// Key capabilities:
/// 1. Stores & reads Streamtape API credentials (`apiLogin` & `apiKey`) directly
///    in Firebase Firestore (`/streamtape_config/primary`).
/// 2. Real-time movie catalog sync (`/streamtape_movies/{movieId}`):
///    - Whenever an Admin adds or edits a movie poster, title, featured status,
///      or adds a new movie on either the Website or Android APK, it is written
///      directly to Firebase Firestore and reflected across BOTH platforms in real time!
/// 3. Automatic discovery of every newly uploaded movie in the Streamtape account
///    and automatic synchronization into Firebase Firestore.
class FirebaseStreamtapeService extends ChangeNotifier {
  static final FirebaseStreamtapeService instance =
      FirebaseStreamtapeService._internal();

  FirebaseStreamtapeService._internal();

  // Official Firebase Project & Enterprise Firestore Database Configuration
  static const String firebaseProjectId = "niooocc";
  static const String firestoreDatabaseId =
      "ai-studio-niooonflutterstu-b22df146-889f-46d3-91f5-90e89065211e";
  static const String firebaseApiKey =
      "AIzaSyBf3LZf0OirxFOwZ5IuxRIyyPltBDZ_NjM";
  static const String firebaseAppId =
      "1:42250824339:web:5410a9b8ea4fa8b0507b66";
  static const String firebaseAuthDomain = "niooocc.firebaseapp.com";
  static const String firebaseStorageBucket = "niooocc.firebasestorage.app";

  static const String defaultStreamtapeLogin = "fa66d0d4d79c646de270";
  static const String defaultStreamtapeKey = "2LBZ94jDzWFxyD";

  static String get firestoreDocumentsBaseUrl =>
      "https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/$firestoreDatabaseId/documents";

  String _streamtapeLogin = defaultStreamtapeLogin;
  String _streamtapeKey = defaultStreamtapeKey;
  bool _isConnectedToFirebase = true;
  DateTime? _lastSyncedAt;

  String get streamtapeLogin => _streamtapeLogin;
  String get streamtapeKey => _streamtapeKey;
  bool get isConnectedToFirebase => _isConnectedToFirebase;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Cleans any proxy wrapper from poster/backdrop URLs before saving to Firestore
  /// so both Web and Android APK receive clean, canonical image URLs.
  static String cleanCanonicalImageUrl(String rawUrl) {
    String url = rawUrl.trim();
    while (url.contains("/api/streamtape/thumb?url=")) {
      final idx = url.indexOf("/api/streamtape/thumb?url=");
      final encoded = url.substring(idx + "/api/streamtape/thumb?url=".length);
      try {
        url = Uri.decodeComponent(encoded);
      } catch (_) {
        break;
      }
    }
    return url;
  }

  /// Converts a Dart value into Firestore REST API Value format
  static Map<String, dynamic> _toFirestoreValue(dynamic value) {
    if (value is bool) {
      return {"booleanValue": value};
    }
    if (value is int) {
      return {"integerValue": value.toString()};
    }
    if (value is double) {
      return {"doubleValue": value};
    }
    return {"stringValue": (value ?? "").toString()};
  }

  /// Parses Firestore REST API `fields` map into a standard Dart Map
  static Map<String, dynamic> parseFirestoreFields(Map<String, dynamic>? fields) {
    final Map<String, dynamic> out = {};
    if (fields == null) return out;
    fields.forEach((key, rawVal) {
      if (rawVal is Map) {
        if (rawVal.containsKey("stringValue")) {
          out[key] = (rawVal["stringValue"] ?? "").toString();
        } else if (rawVal.containsKey("booleanValue")) {
          out[key] = rawVal["booleanValue"] == true;
        } else if (rawVal.containsKey("integerValue")) {
          out[key] =
              int.tryParse((rawVal["integerValue"] ?? "0").toString()) ?? 0;
        } else if (rawVal.containsKey("doubleValue")) {
          out[key] =
              double.tryParse((rawVal["doubleValue"] ?? "0").toString()) ?? 0.0;
        }
      }
    });
    return out;
  }

  /// Fetches the live Streamtape API credentials stored inside Firebase Firestore
  /// (`/streamtape_config/primary`). If not yet initialized, seeds it automatically.
  Future<Map<String, String>> fetchFirebaseStreamtapeCredentials() async {
    try {
      final docUrl =
          "$firestoreDocumentsBaseUrl/streamtape_config/primary?key=$firebaseApiKey";
      final resText = await PlatformBridge.httpGetDirectUrl(docUrl);
      if (resText != null && resText.trim().startsWith("{")) {
        final decoded = jsonDecode(resText);
        if (decoded is Map<String, dynamic> && decoded["fields"] is Map) {
          final parsed = parseFirestoreFields(
            Map<String, dynamic>.from(decoded["fields"] as Map),
          );
          final login = (parsed["apiLogin"] ?? "").toString().trim();
          final key = (parsed["apiKey"] ?? "").toString().trim();
          if (login.length >= 4 && key.length >= 4) {
            _streamtapeLogin = login;
            _streamtapeKey = key;
            _isConnectedToFirebase = true;
            notifyListeners();
            return {"login": login, "key": key};
          }
        }
      }
    } catch (_) {}

    // Seed Firebase `/streamtape_config/primary` if missing
    await saveFirebaseStreamtapeCredentials(
      _streamtapeLogin,
      _streamtapeKey,
    );
    return {"login": _streamtapeLogin, "key": _streamtapeKey};
  }

  /// Saves Streamtape API credentials directly to Firebase Firestore (`/streamtape_config/primary`)
  /// so both Web and Android APK immediately use the updated Streamtape API!
  Future<bool> saveFirebaseStreamtapeCredentials(
    String login,
    String key, {
    String updatedBy = "mdsaiqulislamraihan72@gmail.com",
  }) async {
    final cleanLogin = login.trim();
    final cleanKey = key.trim();
    if (cleanLogin.length < 4 || cleanKey.length < 4) return false;

    _streamtapeLogin = cleanLogin;
    _streamtapeKey = cleanKey;

    final docUrl =
        "$firestoreDocumentsBaseUrl/streamtape_config/primary?key=$firebaseApiKey";
    final payload = {
      "fields": {
        "apiLogin": _toFirestoreValue(
          cleanLogin.length > 120 ? cleanLogin.substring(0, 120) : cleanLogin,
        ),
        "apiKey": _toFirestoreValue(
          cleanKey.length > 120 ? cleanKey.substring(0, 120) : cleanKey,
        ),
        "updatedBy": _toFirestoreValue(
          updatedBy.length > 160 ? updatedBy.substring(0, 160) : updatedBy,
        ),
        "updatedAtMs": _toFirestoreValue(DateTime.now().millisecondsSinceEpoch),
      },
    };

    try {
      final ok = await PlatformBridge.httpPatchDirectJson(docUrl, payload);
      if (ok) {
        _isConnectedToFirebase = true;
        _lastSyncedAt = DateTime.now();
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Reads all movie documents & custom poster overrides stored in Firebase Firestore
  /// (`/streamtape_movies`).
  Future<Map<String, Map<String, dynamic>>> fetchAllFirestoreMoviesMap() async {
    final Map<String, Map<String, dynamic>> result = {};
    try {
      final listUrl =
          "$firestoreDocumentsBaseUrl/streamtape_movies?pageSize=200&key=$firebaseApiKey";
      final resText = await PlatformBridge.httpGetDirectUrl(listUrl);
      if (resText != null && resText.trim().startsWith("{")) {
        final decoded = jsonDecode(resText);
        if (decoded is Map<String, dynamic> && decoded["documents"] is List) {
          final docs = decoded["documents"] as List<dynamic>;
          for (final docObj in docs) {
            if (docObj is Map && docObj["fields"] is Map) {
              final fields = parseFirestoreFields(
                Map<String, dynamic>.from(docObj["fields"] as Map),
              );
              final id = (fields["id"] ?? "").toString().trim();
              if (id.isNotEmpty) {
                result[id] = fields;
              }
            }
          }
          _isConnectedToFirebase = true;
          _lastSyncedAt = DateTime.now();
        }
      }
    } catch (_) {}
    return result;
  }

  /// Writes or updates a movie document (including custom poster, title, seriesName,
  /// featured status, or deletion state) directly inside Firebase Firestore
  /// (`/streamtape_movies/{movieId}`) so Web and Android APK stay 100% in sync!
  Future<bool> upsertMovieToFirestore(
    MovieItem movie, {
    bool isCustomOverride = true,
    bool isDeleted = false,
  }) async {
    final safeId = movie.id.trim().replaceAll(RegExp(r"[^a-zA-Z0-9_-]"), "");
    if (safeId.isEmpty) return false;

    String cleanPoster = cleanCanonicalImageUrl(movie.posterUrl);
    if (cleanPoster.isEmpty) {
      cleanPoster = "https://thumb.tapecontent.net/thumb/$safeId/thumb.jpg";
    }
    String cleanBackdrop = cleanCanonicalImageUrl(movie.backdropUrl);
    if (cleanBackdrop.isEmpty) {
      cleanBackdrop = cleanPoster;
    }

    String clip(String s, int maxLen, String fallback) {
      final t = s.trim().isEmpty ? fallback : s.trim();
      return t.length > maxLen ? t.substring(0, maxLen) : t;
    }

    final docUrl =
        "$firestoreDocumentsBaseUrl/streamtape_movies/${Uri.encodeComponent(safeId)}?key=$firebaseApiKey";

    final payload = {
      "fields": {
        "id": _toFirestoreValue(clip(safeId, 128, "movie_1")),
        "title": _toFirestoreValue(clip(movie.title, 200, "Untitled Movie")),
        "seriesName": _toFirestoreValue(
          clip(
            movie.seriesName.isNotEmpty ? movie.seriesName : movie.title,
            200,
            "Untitled Movie",
          ),
        ),
        "episodeLabel": _toFirestoreValue(
          movie.episodeLabel.length > 60
              ? movie.episodeLabel.substring(0, 60)
              : movie.episodeLabel,
        ),
        "episodeNumber": _toFirestoreValue(movie.episodeNumber.clamp(0, 9999)),
        "posterUrl": _toFirestoreValue(clip(cleanPoster, 1000, cleanPoster)),
        "backdropUrl":
            _toFirestoreValue(clip(cleanBackdrop, 1000, cleanPoster)),
        "embedUrl": _toFirestoreValue(
          clip(
            movie.embedUrl.isNotEmpty
                ? movie.embedUrl
                : "https://streamtape.com/e/$safeId",
            500,
            "https://streamtape.com/e/$safeId",
          ),
        ),
        "videoStreamUrl": _toFirestoreValue(
          clip(
            movie.videoStreamUrl.isNotEmpty
                ? movie.videoStreamUrl
                : "/api/streamtape/direct?file=$safeId",
            1000,
            "/api/streamtape/direct?file=$safeId",
          ),
        ),
        "tagline": _toFirestoreValue(
          clip(
            movie.tagline,
            300,
            "Streamed live from your Streamtape Cloud Account.",
          ),
        ),
        "synopsis": _toFirestoreValue(
          clip(
            movie.synopsis,
            1500,
            "Watch ${movie.title} in HD directly from your Streamtape cloud library.",
          ),
        ),
        "qualityBadge":
            _toFirestoreValue(clip(movie.qualityBadge, 60, "1080p Full HD")),
        "duration": _toFirestoreValue(clip(movie.duration, 60, "HD Stream")),
        "releaseYear": _toFirestoreValue(movie.releaseYear.clamp(1900, 2100)),
        "rating": _toFirestoreValue(movie.rating),
        "isFeatured": _toFirestoreValue(movie.isFeatured),
        "isTrending": _toFirestoreValue(movie.isTrending),
        "isNewRelease": _toFirestoreValue(movie.isNewRelease),
        "isDeleted": _toFirestoreValue(isDeleted),
        "isCustomOverride": _toFirestoreValue(isCustomOverride),
        "updatedAtMs": _toFirestoreValue(DateTime.now().millisecondsSinceEpoch),
      },
    };

    try {
      final ok = await PlatformBridge.httpPatchDirectJson(docUrl, payload);
      if (ok) {
        _isConnectedToFirebase = true;
        _lastSyncedAt = DateTime.now();
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}
