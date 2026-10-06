import "package:flutter/material.dart";
import "../widgets/glass_container.dart";

class ProfileSettingsPage extends StatelessWidget {
  final String displayName;
  final String handle;
  final String membershipTier;
  final String streamQuality;
  final bool dolbyAtmosEnabled;
  final bool autoplayTrailers;
  final int watchlistCount;
  final int watchedCount;
  final ValueChanged<String> onQualityChanged;
  final ValueChanged<bool> onToggleDolbyAtmos;
  final ValueChanged<bool> onToggleAutoplay;
  final VoidCallback onReturnToWelcome;

  const ProfileSettingsPage({
    super.key,
    required this.displayName,
    required this.handle,
    required this.membershipTier,
    required this.streamQuality,
    required this.dolbyAtmosEnabled,
    required this.autoplayTrailers,
    required this.watchlistCount,
    required this.watchedCount,
    required this.onQualityChanged,
    required this.onToggleDolbyAtmos,
    required this.onToggleAutoplay,
    required this.onReturnToWelcome,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: EdgeInsets.zero,
      borderRadius: 0,
      blur: 28,
      border: const Border(),
      boxShadow: const [],
      backgroundColor: const Color(0xFF050C0A).withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                const Text(
                  "Cinema Profile",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF0FDF4),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                GlassButton(
                  onTap: onReturnToWelcome,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: const Text(
                    "Welcome Screen",
                    style: TextStyle(
                      color: Color(0xFF03120D),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        const Color(0xFF091714).withValues(alpha: 0.78),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF047857)],
                          ),
                          border: Border.all(color: Colors.white54, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.movie_filter_rounded,
                          color: Color(0xFF03120D),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Color(0xFFF0FDF4),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$handle · $membershipTier",
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "STREAMING QUALITY",
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    "4K IMAX HDR",
                    "1080p Full HD",
                    "Auto Adaptive",
                  ].map((q) {
                    final active = streamQuality == q;
                    return GestureDetector(
                      onTap: () => onQualityChanged(q),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF00E676),
                                    Color(0xFF10B981),
                                  ],
                                )
                              : null,
                          color: active
                              ? null
                              : const Color(0xFF091714).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: active
                                ? Colors.white54
                                : const Color(0xFF00E676)
                                    .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          q,
                          style: TextStyle(
                            color: active
                                ? const Color(0xFF03120D)
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
