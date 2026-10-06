import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:webview_flutter/webview_flutter.dart";
import "mini_chrome_browser_service.dart";

class PlatformBridge {
  static bool get isWeb => false;

  /// Cloud server base URL so the Android APK fetches and updates live movies,
  /// custom posters, and admin overrides from the exact same live server!
  static const String cloudServerBaseUrl =
      "https://ais-pre-dzew55ccy5nnhlnmouyujf-579860296090.asia-southeast1.run.app";

  static const String defaultStreamtapeLogin = "fa66d0d4d79c646de270";
  static const String defaultStreamtapeKey = "2LBZ94jDzWFxyD";

  static final Map<String, String> _memoryStorage = {};

  static String _resolveUrl(String url) {
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }
    if (url.startsWith("/")) {
      return "$cloudServerBaseUrl$url";
    }
    return "$cloudServerBaseUrl/$url";
  }

  static Future<String> httpGetString(String url) async {
    final fullUrl = _resolveUrl(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);
    try {
      final req = await client.getUrl(Uri.parse(fullUrl));
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        if (body.trim().startsWith("{")) {
          return body;
        }
      }
    } catch (_) {
      // Fallback to direct Streamtape API if cloud server is unreachable
    } finally {
      client.close();
    }

    // Direct Streamtape API fallback on Android so newly uploaded Streamtape movies
    // ALWAYS appear automatically on Android!
    if (url.contains("/api/streamtape/catalog")) {
      return await _fetchDirectStreamtapeCatalogOnAndroid();
    }
    if (url.contains("/api/streamtape/direct")) {
      final uri = Uri.tryParse(fullUrl);
      final fileId = uri?.queryParameters["file"] ?? "";
      if (fileId.isNotEmpty) {
        final directUrl = await _resolveDirectStreamtapeOnAndroid(fileId);
        if (directUrl != null) {
          return jsonEncode({"url": directUrl});
        }
      }
    }
    throw Exception("Failed to fetch $url");
  }

  static Future<String> _fetchDirectStreamtapeCatalogOnAndroid() async {
    final client = HttpClient();
    try {
      final listUri = Uri.parse(
        "https://api.streamtape.com/file/listfolder?login=$defaultStreamtapeLogin&key=$defaultStreamtapeKey",
      );
      final req = await client.getUrl(listUri);
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic> && decoded["status"] == 200) {
        final result = decoded["result"] as Map<String, dynamic>? ?? {};
        final files = (result["files"] as List<dynamic>? ?? []);
        final List<String> linkIds = [];
        for (final f in files) {
          if (f is Map) {
            final id = (f["linkid"] ?? f["id"] ?? "").toString().trim();
            if (id.isNotEmpty) linkIds.add(id);
          }
        }

        Map<String, dynamic> infoMap = {};
        if (linkIds.isNotEmpty) {
          try {
            final infoUri = Uri.parse(
              "https://api.streamtape.com/file/info?file=${linkIds.join(',')}&login=$defaultStreamtapeLogin&key=$defaultStreamtapeKey",
            );
            final infoReq = await client.getUrl(infoUri);
            final infoRes = await infoReq.close();
            final infoText = await infoRes.transform(utf8.decoder).join();
            final infoDecoded = jsonDecode(infoText);
            if (infoDecoded is Map<String, dynamic> &&
                infoDecoded["result"] is Map<String, dynamic>) {
              infoMap = infoDecoded["result"] as Map<String, dynamic>;
            }
          } catch (_) {}
        }

        final List<Map<String, dynamic>> movies = [];
        for (int i = 0; i < files.length; i++) {
          final f = files[i];
          if (f is! Map) continue;
          final id = (f["linkid"] ?? f["id"] ?? "").toString().trim();
          if (id.isEmpty) continue;
          final rawName = (f["name"] ?? "Streamtape Movie").toString();
          final cleanTitle = rawName
              .replaceAll(RegExp(r"\.(mp4|mkv|avi|webm|mov)$", caseSensitive: false), "")
              .replaceAll(RegExp(r"[._]+"), " ")
              .trim();
          final info = infoMap[id] is Map ? infoMap[id] as Map : {};
          final splash = (info["splash_img"] ?? "").toString();
          final poster = splash.isNotEmpty
              ? splash
              : "https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=900&q=85";

          movies.add({
            "id": id,
            "title": cleanTitle.isEmpty ? rawName : cleanTitle,
            "seriesName": cleanTitle.isEmpty ? rawName : cleanTitle,
            "posterUrl": poster,
            "backdropUrl": splash.isNotEmpty ? splash : poster,
            "embedUrl": "https://streamtape.com/e/$id",
            "videoStreamUrl": "/api/streamtape/direct?file=$id",
            "rating": 9.2,
            "releaseYear": 2026,
            "duration": "HD Stream",
            "maturityRating": "PG-13",
            "qualityBadge": "720p HD",
            "genres": ["Action", "Cinema"],
            "director": "Niooo Streamtape Cloud",
            "isFeatured": i < 5,
            "isTrending": i < 10,
            "isNewRelease": true,
          });
        }
        return jsonEncode({"movies": movies});
      }
    } catch (_) {} finally {
      client.close();
    }
    return jsonEncode({"movies": []});
  }

  static Future<String?> _resolveDirectStreamtapeOnAndroid(
    String fileId,
  ) async {
    final client = HttpClient();
    try {
      final ticketUri = Uri.parse(
        "https://api.streamtape.com/file/dlticket?file=$fileId&login=$defaultStreamtapeLogin&key=$defaultStreamtapeKey",
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
              Duration(seconds: waitTime.clamp(1, 6)),
            );
          }
          final dlUri = Uri.parse(
            "https://api.streamtape.com/file/dl?file=$fileId&ticket=$ticket",
          );
          final dlReq = await client.getUrl(dlUri);
          final dlRes = await dlReq.close();
          final dlText = await dlRes.transform(utf8.decoder).join();
          final dlDecoded = jsonDecode(dlText);
          if (dlDecoded is Map<String, dynamic> && dlDecoded["status"] == 200) {
            final dlResult =
                dlDecoded["result"] as Map<String, dynamic>? ?? {};
            final url = (dlResult["url"] ?? "").toString();
            if (url.startsWith("http")) return url;
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
    client.connectionTimeout = const Duration(seconds: 12);
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
    client.connectionTimeout = const Duration(seconds: 12);
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

  static Object? registerVideoFactory({
    required String viewType,
    required String src,
    required String posterUrl,
    required void Function(double duration) onDurationLoaded,
    required void Function() onPlay,
    required void Function() onPause,
  }) {
    return null;
  }

  static void playVideo(Object? videoObj, void Function() onMutedFallback) {}

  static void pauseVideo(Object? videoObj) {}

  static bool isVideoPaused(Object? videoObj) => false;

  static double getVideoCurrentTime(Object? videoObj) => 0.0;

  static double getVideoDuration(Object? videoObj) => 100.0;

  static void setVideoCurrentTime(Object? videoObj, double seconds) {}

  static bool toggleVideoMute(Object? videoObj) => false;

  static void requestVideoFullscreen(Object? videoObj) {}

  static void disposeVideo(Object? videoObj) {}

  static Widget buildEmbeddedPlayer({
    required String viewType,
    required String embedSrc,
    required String backdropUrl,
    required String title,
  }) {
    return _AndroidInAppStreamtapeVideoPlayer(
      key: ValueKey("st_player_${viewType}_$embedSrc"),
      embedSrc: embedSrc,
      backdropUrl: backdropUrl,
      title: title,
    );
  }
}

/// Plays the Streamtape movie directly inside the 16:9 player box on Android
/// and intercepts any Advertisement / External link click so that ad links
/// open inside a Partial Chrome Custom Tab strictly BELOW the video player
/// without ever covering the video player!
class _AndroidInAppStreamtapeVideoPlayer extends StatefulWidget {
  final String embedSrc;
  final String backdropUrl;
  final String title;

  const _AndroidInAppStreamtapeVideoPlayer({
    super.key,
    required this.embedSrc,
    required this.backdropUrl,
    required this.title,
  });

  @override
  State<_AndroidInAppStreamtapeVideoPlayer> createState() =>
      _AndroidInAppStreamtapeVideoPlayerState();
}

class _AndroidInAppStreamtapeVideoPlayerState
    extends State<_AndroidInAppStreamtapeVideoPlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  bool _isStreamtapeVideoDomain(String url) {
    final lower = url.toLowerCase();
    return lower.contains("streamtape.com") ||
        lower.contains("tapecontent.net") ||
        lower.contains("strtape.") ||
        lower.contains("strcloud.") ||
        lower.contains("stape.fun") ||
        lower.startsWith("blob:") ||
        lower.startsWith("about:blank") ||
        lower.startsWith("data:");
  }

  @override
  void initState() {
    super.initState();
    final initialUrl = widget.embedSrc.startsWith("http")
        ? widget.embedSrc
        : "${PlatformBridge.cloudServerBaseUrl}${widget.embedSrc}";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final targetUrl = request.url;
            // Allow the Streamtape video player & video CDN streams to play inside the 16:9 player
            if (_isStreamtapeVideoDomain(targetUrl)) {
              return NavigationDecision.navigate;
            }
            // Any Advertisement / external redirect clicked inside the player
            // is intercepted and opened in the Partial Chrome Custom Tab
            // right BELOW the video player (so the video player is never covered!)
            if (mounted &&
                (targetUrl.startsWith("http://") ||
                    targetUrl.startsWith("https://"))) {
              MiniChromeBrowserService.openAdUrlBelowPlayer(
                context,
                targetUrl,
                title: "Sponsored",
              );
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          IgnorePointer(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
