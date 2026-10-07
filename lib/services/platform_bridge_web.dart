// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;
import "dart:convert";
// ignore: avoid_web_libraries_in_flutter
import "dart:js_util" as js_util;
// ignore: undefined_prefixed_name
import "dart:ui_web" as ui_web;
import "package:flutter/material.dart";

class PlatformBridge {
  static bool get isWeb => true;

  static Future<String> httpGetString(String url) async {
    return await html.HttpRequest.getString(url);
  }

  static Future<int> httpPostJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final req = await html.HttpRequest.request(
      url,
      method: "POST",
      requestHeaders: {"Content-Type": "application/json"},
      sendData: jsonEncode(payload),
    );
    return req.status ?? 0;
  }

  static Future<String?> httpPostJsonResponse(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final req = await html.HttpRequest.request(
      url,
      method: "POST",
      requestHeaders: {"Content-Type": "application/json"},
      sendData: jsonEncode(payload),
    );
    if (req.status == 200) {
      return req.responseText;
    }
    return null;
  }

  static Future<String?> httpGetDirectUrl(String url) async {
    try {
      return await html.HttpRequest.getString(url);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> httpPatchDirectJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    try {
      final req = await html.HttpRequest.request(
        url,
        method: "PATCH",
        requestHeaders: {"Content-Type": "application/json"},
        sendData: jsonEncode(payload),
      );
      return (req.status ?? 0) >= 200 && (req.status ?? 0) < 300;
    } catch (_) {
      return false;
    }
  }

  static String? getLocalStorage(String key) {
    try {
      return html.window.localStorage[key];
    } catch (_) {
      return null;
    }
  }

  static void setLocalStorage(String key, String? value) {
    try {
      if (value == null) {
        html.window.localStorage.remove(key);
      } else {
        html.window.localStorage[key] = value;
      }
    } catch (_) {}
  }

  static void listenBridgeSync(void Function(String json) onSync) {
    try {
      html.window.addEventListener("niooo-sync", (html.Event event) {
        try {
          final detail = js_util.getProperty<Object?>(event, "detail");
          if (detail is String && detail.isNotEmpty) {
            onSync(detail);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  static String? getInitialBridgeState() {
    try {
      final raw = js_util.getProperty<Object?>(html.window, "__NIOOO_STATE__");
      if (raw is String && raw.isNotEmpty) {
        return raw;
      }
    } catch (_) {}
    return null;
  }

  static void sendBridgeCommand(Map<String, dynamic> payload) {
    try {
      final detail = jsonEncode(payload);
      final event = html.CustomEvent("niooo-cmd", detail: detail);
      html.window.dispatchEvent(event);
    } catch (_) {}
  }

  static void copyToClipboard(String text) {
    try {
      html.window.navigator.clipboard?.writeText(text);
    } catch (_) {}
  }

  static void registerIframeFactory(String viewType, String src) {
    final iframe = html.IFrameElement()
      ..src = src
      ..style.border = "none"
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.backgroundColor = "#000000"
      ..setAttribute("loading", "eager")
      ..allowFullscreen = true
      ..allow =
          "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen";

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );
  }

  static Object? registerVideoFactory({
    required String viewType,
    required String src,
    required String posterUrl,
    required void Function(double duration) onDurationLoaded,
    required void Function() onPlay,
    required void Function() onPause,
  }) {
    final video = html.VideoElement()
      ..src = src
      ..poster = posterUrl
      ..preload = "auto"
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
      final dur = video.duration;
      if (!dur.isNaN && !dur.isInfinite && dur > 0) {
        onDurationLoaded(dur.toDouble());
      }
    });

    video.onPlay.listen((_) => onPlay());
    video.onPause.listen((_) => onPause());

    return video;
  }

  static void playVideo(Object? videoObj, void Function() onMutedFallback) {
    if (videoObj is html.VideoElement) {
      videoObj.play().catchError((_) async {
        videoObj.muted = true;
        onMutedFallback();
        try {
          await videoObj.play();
        } catch (_) {}
      });
    }
  }

  static void pauseVideo(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      videoObj.pause();
    }
  }

  static bool isVideoPaused(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      return videoObj.paused;
    }
    return true;
  }

  static double getVideoCurrentTime(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      return videoObj.currentTime.toDouble();
    }
    return 0.0;
  }

  static double getVideoDuration(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      return videoObj.duration.toDouble();
    }
    return 0.0;
  }

  static void setVideoCurrentTime(Object? videoObj, double seconds) {
    if (videoObj is html.VideoElement) {
      videoObj.currentTime = seconds;
    }
  }

  static bool toggleVideoMute(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      videoObj.muted = !videoObj.muted;
      return videoObj.muted;
    }
    return false;
  }

  static Object? _wakeLockSentinel;

  static void setScreenWakelock(bool enable) {
    try {
      final nav = html.window.navigator;
      final wakeLock = js_util.getProperty<Object?>(nav, "wakeLock");
      if (wakeLock != null) {
        if (enable) {
          js_util
              .promiseToFuture<Object?>(
                js_util.callMethod<Object>(wakeLock, "request", ["screen"]),
              )
              .then((sentinel) => _wakeLockSentinel = sentinel)
              .catchError((_) => null);
        } else if (_wakeLockSentinel != null) {
          js_util.callMethod<Object?>(_wakeLockSentinel!, "release", []);
          _wakeLockSentinel = null;
        }
      }
    } catch (_) {}
  }

  static void enterNativeFullscreen() {
    setScreenWakelock(true);
    try {
      html.document.documentElement?.requestFullscreen();
    } catch (_) {}
  }

  static void exitNativeFullscreen() {
    try {
      if (html.document.fullscreenElement != null) {
        html.document.exitFullscreen();
      }
    } catch (_) {}
  }

  static void requestVideoFullscreen(Object? videoObj) {
    if (videoObj is html.VideoElement) {
      try {
        videoObj.requestFullscreen();
      } catch (_) {}
    } else {
      enterNativeFullscreen();
    }
  }

  static void disposeVideo(Object? videoObj) {
    setScreenWakelock(false);
    if (videoObj is html.VideoElement) {
      videoObj.pause();
      videoObj.src = "";
    }
  }

  static Widget buildCustomVideoSurface({
    required Object? videoObj,
    required String viewType,
    required String backdropUrl,
  }) {
    return HtmlElementView(viewType: viewType);
  }

  static Widget buildEmbeddedPlayer({
    required String viewType,
    required String embedSrc,
    required String backdropUrl,
    required String title,
  }) {
    return HtmlElementView(viewType: viewType);
  }

  static void switchVideoAudioTrack(Object? videoObj, int trackIndex) {
    if (videoObj == null) return;
    try {
      final audioTracks = js_util.getProperty<Object?>(videoObj, "audioTracks");
      if (audioTracks != null) {
        final len =
            js_util.getProperty<int?>(audioTracks, "length") ?? 0;
        for (int i = 0; i < len; i++) {
          final track = js_util.callMethod<Object?>(audioTracks, "item", [i]);
          if (track != null) {
            js_util.setProperty(track, "enabled", i == trackIndex);
          }
        }
      }
    } catch (_) {}
  }
}

