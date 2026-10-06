import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class PlatformBridge {
  static bool get isWeb => false;
  static final Map<String, String> _memoryStorage = {};

  static Future<String> httpGetString(String url) async {
    if (!url.startsWith("http")) {
      throw Exception("Relative URL on native Android uses Streamtape API directly");
    }
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close();
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }

  static Future<int> httpPostJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    return 200;
  }

  static Future<String?> httpPostJsonResponse(
    String url,
    Map<String, dynamic> payload,
  ) async {
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
        Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF10B981)],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF03120D),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  embedSrc,
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
