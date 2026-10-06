import "package:flutter/material.dart";
import "package:flutter_custom_tabs/flutter_custom_tabs.dart" as custom_tabs;
import "package:url_launcher/url_launcher.dart" as url_launcher;
import "platform_bridge.dart";

/// Google Chrome Custom Tabs (Mini Chrome In-App Browser) Service for Niooo M.
/// Ensures ad links, Streamtape links, and external URLs open inside the
/// integrated Chrome Custom Tabs mini-browser instead of leaving the app.
class MiniChromeBrowserService {
  MiniChromeBrowserService._();

  /// Opens any URL inside Google's Chrome Custom Tabs mini-browser on Android
  /// (with custom Niooo M dark emerald toolbar, slide-up sheet/custom tab,
  /// share button, and instant close button back to the app), or in a sleek
  /// in-app modal mini-browser on Web preview.
  static Future<void> openUrl(
    BuildContext context,
    String rawUrl, {
    String? title,
  }) async {
    final cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return;

    final Uri? uri = Uri.tryParse(
      cleanUrl.startsWith("http://") || cleanUrl.startsWith("https://")
          ? cleanUrl
          : "https://$cleanUrl",
    );
    if (uri == null) return;

    // On Web preview, open an in-app Mini Chrome Custom Tab modal sheet so it
    // never leaves the app iframe either.
    if (PlatformBridge.isWeb) {
      await _openWebMiniChromeSheet(
        context,
        uri.toString(),
        title: title ?? uri.host,
      );
      return;
    }

    // On Android APK: Launch Google Chrome Custom Tabs (Mini Chrome Browser)
    try {
      await custom_tabs.launchUrl(
        uri,
        customTabsOptions: custom_tabs.CustomTabsOptions(
          colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF061510),
            navigationBarColor: const Color(0xFF030706),
            navigationBarDividerColor: const Color(0xFF00E676),
          ),
          shareState: custom_tabs.CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: custom_tabs.CustomTabsCloseButton(
            icon: custom_tabs.CustomTabsCloseButtonIcons.back,
          ),
          partial: custom_tabs.PartialCustomTabsConfiguration.adaptiveSheet(
            initialHeight: MediaQuery.of(context).size.height * 0.88,
            initialWidth: MediaQuery.of(context).size.width * 0.96,
            activityHeightResizeBehavior:
                custom_tabs.CustomTabsActivityHeightResizeBehavior.adjustable,
            cornerRadius: 20,
          ),
          browser: const custom_tabs.CustomTabsBrowserConfiguration(
            prefersDefaultBrowser: false,
            fallbackCustomTabs: [
              "com.android.chrome",
              "com.chrome.beta",
              "com.chrome.dev",
              "org.mozilla.firefox",
              "com.microsoft.emmx",
            ],
          ),
        ),
        safariVCOptions: const custom_tabs.SafariViewControllerOptions(
          preferredBarTintColor: Color(0xFF061510),
          preferredControlTintColor: Color(0xFF00E676),
          barCollapsingEnabled: true,
          dismissButtonStyle:
              custom_tabs.SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (_) {
      // Fallback to url_launcher inAppBrowserView (Chrome Custom Tabs)
      try {
        await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.inAppBrowserView,
          browserConfiguration: const url_launcher.BrowserConfiguration(
            showTitle: true,
          ),
        );
      } catch (_) {}
    }
  }

  static Future<void> _openWebMiniChromeSheet(
    BuildContext context,
    String url, {
    required String title,
  }) async {
    final viewType =
        "niooo-mini-chrome-${DateTime.now().microsecondsSinceEpoch}";
    PlatformBridge.registerIframeFactory(viewType, url);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height * 0.90;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF061510),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Chrome Custom Tab Top Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF04100C),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: "Close Mini Browser",
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF00E676),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public_rounded,
                            color: Color(0xFF00E676),
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Chrome Custom Tab",
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PlatformBridge.buildEmbeddedPlayer(
                  viewType: viewType,
                  embedSrc: url,
                  backdropUrl: "",
                  title: title,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
