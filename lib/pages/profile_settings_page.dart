import "dart:ui";
import "package:flutter/material.dart";
import "../models/movie_models.dart";
import "../services/auth_bridge_service.dart";
import "../widgets/glass_container.dart";

// =============================================================================
// PROFILE & OPTIONAL LOGIN SCREEN + FULL-SCREEN ADMIN PANEL LAUNCHER
// =============================================================================
class ProfileSettingsPage extends StatefulWidget {
  final List<MovieItem> movies;
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
  final VoidCallback onOpenFullScreenAdminPanel;

  const ProfileSettingsPage({
    super.key,
    this.movies = const [],
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
    required this.onOpenFullScreenAdminPanel,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final AuthBridgeService _auth = AuthBridgeService.instance;

  @override
  void initState() {
    super.initState();
    _auth.init();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openOptionalAuthDialog({bool startWithSignUp = false}) async {
    bool isSignUp = startWithSignUp;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscurePass = true;

    _auth.clearError();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF061310).withValues(alpha: 0.96),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00E676),
                                      Color(0xFF047857)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E676)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.login_rounded,
                                  color: Color(0xFF03120D),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSignUp
                                          ? "Create Niooo M Account"
                                          : "Sign In to Niooo M",
                                      style: const TextStyle(
                                        color: Color(0xFFF0FDF4),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Text(
                                      "Optional login · Sync profile or access Admin Panel",
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Mode Toggle (Login / Sign Up)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF040B09),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setModalState(() {
                                      isSignUp = false;
                                      _auth.clearError();
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: !isSignUp
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF00E676),
                                                  Color(0xFF10B981)
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Log In",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: !isSignUp
                                              ? const Color(0xFF03120D)
                                              : const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setModalState(() {
                                      isSignUp = true;
                                      _auth.clearError();
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: isSignUp
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF00E676),
                                                  Color(0xFF10B981)
                                                ],
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Sign Up",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSignUp
                                              ? const Color(0xFF03120D)
                                              : const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (isSignUp) ...[
                            _buildFieldLabel("FULL NAME"),
                            const SizedBox(height: 6),
                            _buildModalInput(
                              controller: nameCtrl,
                              hint: "Enter your name",
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 12),
                          ],

                          _buildFieldLabel("EMAIL ADDRESS"),
                          const SizedBox(height: 6),
                          _buildModalInput(
                            controller: emailCtrl,
                            hint: "you@example.com",
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _buildFieldLabel("PASSWORD"),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF040B09),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: TextField(
                              controller: passwordCtrl,
                              obscureText: obscurePass,
                              style: const TextStyle(
                                color: Color(0xFFF0FDF4),
                                fontSize: 13.5,
                              ),
                              decoration: InputDecoration(
                                hintText: "••••••••",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF00E676),
                                  size: 19,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setModalState(
                                      () => obscurePass = !obscurePass),
                                  icon: Icon(
                                    obscurePass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),

                          if (_auth.authError != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF5252)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFFF5252),
                                    size: 17,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _auth.authError!,
                                      style: const TextStyle(
                                        color: Color(0xFFFF8A80),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: GlassButton(
                              onTap: () async {
                                bool ok = false;
                                if (isSignUp) {
                                  ok = await _auth.signUpWithEmail(
                                    displayName: nameCtrl.text,
                                    email: emailCtrl.text,
                                    password: passwordCtrl.text,
                                  );
                                } else {
                                  ok = await _auth.signInWithEmail(
                                    email: emailCtrl.text,
                                    password: passwordCtrl.text,
                                  );
                                }
                                setModalState(() {});
                                if (ok && ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                              },
                              borderRadius: 18,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                isSignUp ? "Create Account" : "Sign In Now",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF03120D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFF0FDF4),
                                side: BorderSide(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.35),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                _auth.signInWithGoogle();
                                Navigator.of(ctx).pop();
                              },
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                color: Color(0xFF00E676),
                                size: 24,
                              ),
                              label: const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF00E676),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildModalInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF040B09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.25),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFFF0FDF4), fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 19),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = _auth.user;
    final isLoggedIn = loggedInUser != null;
    final isAdmin = _auth.isAdmin;

    final effectiveName =
        isLoggedIn ? loggedInUser.displayName : "Guest Cinema Viewer";
    final effectiveSub = isLoggedIn
        ? "${loggedInUser.email} · ${isAdmin ? 'SUPER ADMIN' : widget.membershipTier}"
        : "Browsing without login · Tap top login icon anytime";

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
          // Top Header of Profile Screen with Login Icon on top-right
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
                // Small Admin Button in Profile header when logged in with Admin Email
                if (isAdmin) ...[
                  GestureDetector(
                    onTap: widget.onOpenFullScreenAdminPanel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E676).withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Color(0xFF03120D),
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Admin",
                            style: TextStyle(
                              color: Color(0xFF03120D),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Login / Logout Icon at the top of Profile option (non-mandatory login)
                GlassIconButton(
                  icon: isLoggedIn
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  tooltip: isLoggedIn
                      ? "Sign Out (${loggedInUser.email})"
                      : "Sign In / Sign Up (Optional)",
                  size: 40,
                  color: isLoggedIn
                      ? const Color(0xFFFF8A80)
                      : const Color(0xFF00E676),
                  onTap: () {
                    if (isLoggedIn) {
                      _auth.signOut();
                    } else {
                      _openOptionalAuthDialog(startWithSignUp: false);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
              children: [
                // Profile Identity Card
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFF047857)],
                              ),
                              border:
                                  Border.all(color: Colors.white54, width: 1.5),
                            ),
                            child: Icon(
                              isLoggedIn
                                  ? (isAdmin
                                      ? Icons.verified_user_rounded
                                      : Icons.person_rounded)
                                  : Icons.movie_filter_rounded,
                              color: const Color(0xFF03120D),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        effectiveName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFF0FDF4),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    if (isAdmin) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E676)
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "ADMIN",
                                          style: TextStyle(
                                            color: Color(0xFF00E676),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  effectiveSub,
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Small Admin button inside the profile card as well if Admin is logged in
                          if (isAdmin)
                            GestureDetector(
                              onTap: widget.onOpenFullScreenAdminPanel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF00E676)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.dashboard_customize_rounded,
                                      color: Color(0xFF00E676),
                                      size: 15,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Admin Panel",
                                      style: TextStyle(
                                        color: Color(0xFF00E676),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (!isLoggedIn) ...[
                            Expanded(
                              child: GlassButton(
                                onTap: () => _openOptionalAuthDialog(
                                    startWithSignUp: false),
                                borderRadius: 16,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.login_rounded,
                                      color: Color(0xFF03120D),
                                      size: 17,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Sign In / Sign Up (Optional)",
                                      style: TextStyle(
                                        color: Color(0xFF03120D),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            if (isAdmin)
                              Expanded(
                                child: GlassButton(
                                  onTap: widget.onOpenFullScreenAdminPanel,
                                  borderRadius: 16,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings_rounded,
                                        color: Color(0xFF03120D),
                                        size: 17,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Open Full-Screen Admin Panel",
                                        style: TextStyle(
                                          color: Color(0xFF03120D),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (isAdmin) const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF8A80),
                                side: BorderSide(
                                  color: const Color(0xFFFF5252)
                                      .withValues(alpha: 0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _auth.signOut(),
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: const Text(
                                "Sign Out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        title: "Saved Watchlist",
                        value: "${widget.watchlistCount} Movies",
                        icon: Icons.bookmark_added_rounded,
                        fallbackIcon: Icons.bookmark_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniStatCard(
                        title: "Streamtape Cloud",
                        value: "${widget.movies.length} Active",
                        icon: Icons.cloud_done_rounded,
                        fallbackIcon: Icons.cloud_done_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
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
                    final active = widget.streamQuality == q;
                    return GestureDetector(
                      onTap: () => widget.onQualityChanged(q),
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

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required IconData fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF091714).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(fallbackIcon, color: const Color(0xFF00E676), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFF0FDF4),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FULL-SCREEN ADMIN PANEL OVERLAY (MANAGE ALL MOVIES & ADD POSTERS)
// =============================================================================
class FullScreenAdminPanelPage extends StatefulWidget {
  final List<MovieItem> movies;
  final String adminEmail;
  final VoidCallback onClose;
  final VoidCallback onRefreshCatalog;
  final ValueChanged<MovieItem> onPlayMovie;
  final ValueChanged<MovieItem> onUpdateMovieLocally;
  final ValueChanged<String> onDeleteMovieLocally;

  const FullScreenAdminPanelPage({
    super.key,
    required this.movies,
    required this.adminEmail,
    required this.onClose,
    required this.onRefreshCatalog,
    required this.onPlayMovie,
    required this.onUpdateMovieLocally,
    required this.onDeleteMovieLocally,
  });

  @override
  State<FullScreenAdminPanelPage> createState() =>
      _FullScreenAdminPanelPageState();
}

class _FullScreenAdminPanelPageState extends State<FullScreenAdminPanelPage> {
  // 0: Manage Movies & Posters, 1: Add Movie / Poster, 2: Streamtape API
  int _activeTab = 0;
  String _searchQuery = "";
  String _filterType = "All";

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _posterController = TextEditingController();
  final TextEditingController _backdropController = TextEditingController();
  final TextEditingController _qualityController =
      TextEditingController(text: "1080p Full HD");
  final TextEditingController _yearController =
      TextEditingController(text: "2026");
  final TextEditingController _synopsisController = TextEditingController();
  bool _isFeaturedNew = true;
  bool _isSaving = false;

  final TextEditingController _apiLoginController =
      TextEditingController(text: "fa66d0d4d79c646de270");
  final TextEditingController _apiKeyController =
      TextEditingController(text: "2LBZ94jDzWFxyD");
  bool _isSavingCreds = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentCredentials();
  }

  Future<void> _loadCurrentCredentials() async {
    final creds = await MovieCatalogData.fetchStreamtapeCredentials();
    if (!mounted) return;
    setState(() {
      _apiLoginController.text = creds["login"] ?? "fa66d0d4d79c646de270";
      _apiKeyController.text = creds["key"] ?? "2LBZ94jDzWFxyD";
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _seriesController.dispose();
    _posterController.dispose();
    _backdropController.dispose();
    _qualityController.dispose();
    _yearController.dispose();
    _synopsisController.dispose();
    _apiLoginController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF062E22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00E676), width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.verified_rounded,
                color: Color(0xFF00E676), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Color(0xFFF0FDF4),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPosterAndMovieEditorModal(MovieItem movie) async {
    final titleCtrl = TextEditingController(text: movie.title);
    final seriesCtrl = TextEditingController(text: movie.seriesName);
    final posterCtrl = TextEditingController(text: movie.posterUrl);
    final backdropCtrl = TextEditingController(text: movie.backdropUrl);
    final qualityCtrl = TextEditingController(text: movie.qualityBadge);
    final synopsisCtrl = TextEditingController(text: movie.synopsis);
    bool isFeatured = movie.isFeatured;
    bool applyPosterToWholeSeries = movie.episodeNumber > 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final previewPoster = posterCtrl.text.trim();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.88,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF061310).withValues(alpha: 0.96),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Color(0xFF00E676),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Edit Movie & Add Poster",
                                      style: TextStyle(
                                        color: Color(0xFFF0FDF4),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      "Streamtape ID: ${movie.id}",
                                      style: const TextStyle(
                                        color: Color(0xFF00E676),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 96,
                                  height: 138,
                                  color: const Color(0xFF0A1D18),
                                  child: previewPoster.isNotEmpty
                                      ? Image.network(
                                          previewPoster,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.movie_creation_outlined,
                                            color: Colors.white38,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAdminLabel("MOVIE / EPISODE TITLE"),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: titleCtrl,
                                      hint: "Movie title",
                                      icon: Icons.movie_edit,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildAdminLabel("POSTER IMAGE URL (HD)"),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: posterCtrl,
                                      hint: "https://.../poster.jpg",
                                      icon: Icons.image_rounded,
                                      onChanged: (_) => setModalState(() {}),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFieldBlock(
                                  label: "SERIES / COLLECTION NAME",
                                  controller: seriesCtrl,
                                  hint: "Series or Movie Group",
                                  icon: Icons.video_library_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFieldBlock(
                                  label: "QUALITY BADGE",
                                  controller: qualityCtrl,
                                  hint: "4K HDR / 1080p HD",
                                  icon: Icons.hd_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildFieldBlock(
                            label: "BACKDROP / SPLASH URL (OPTIONAL)",
                            controller: backdropCtrl,
                            hint: "https://.../backdrop.jpg",
                            icon: Icons.panorama_rounded,
                          ),
                          const SizedBox(height: 10),
                          _buildFieldBlock(
                            label: "SYNOPSIS / DESCRIPTION",
                            controller: synopsisCtrl,
                            hint: "Movie description...",
                            icon: Icons.notes_rounded,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFF00E676),
                            title: const Text(
                              "Feature on Home Hero Banner",
                              style: TextStyle(
                                color: Color(0xFFF0FDF4),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            value: isFeatured,
                            onChanged: (v) =>
                                setModalState(() => isFeatured = v),
                          ),
                          if (movie.episodeNumber > 0)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: const Color(0xFF00E676),
                              title: Text(
                                "Apply Poster to all '${movie.seriesName}' episodes",
                                style: const TextStyle(
                                  color: Color(0xFFF0FDF4),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              value: applyPosterToWholeSeries,
                              onChanged: (v) => setModalState(
                                  () => applyPosterToWholeSeries = v),
                            ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: GlassButton(
                              onTap: () async {
                                final newTitle = titleCtrl.text.trim().isEmpty
                                    ? movie.title
                                    : titleCtrl.text.trim();
                                final newPoster = posterCtrl.text.trim().isEmpty
                                    ? movie.posterUrl
                                    : posterCtrl.text.trim();
                                final newBackdrop =
                                    backdropCtrl.text.trim().isEmpty
                                        ? newPoster
                                        : backdropCtrl.text.trim();
                                final newSeries = seriesCtrl.text.trim().isEmpty
                                    ? movie.seriesName
                                    : seriesCtrl.text.trim();
                                final newQuality =
                                    qualityCtrl.text.trim().isEmpty
                                        ? movie.qualityBadge
                                        : qualityCtrl.text.trim();
                                final newSynopsis =
                                    synopsisCtrl.text.trim().isEmpty
                                        ? movie.synopsis
                                        : synopsisCtrl.text.trim();

                                final updated = movie.copyWith(
                                  title: newTitle,
                                  seriesName: newSeries,
                                  posterUrl: newPoster,
                                  backdropUrl: newBackdrop,
                                  qualityBadge: newQuality,
                                  synopsis: newSynopsis,
                                  isFeatured: isFeatured,
                                );

                                widget.onUpdateMovieLocally(updated);
                                await MovieCatalogData.saveAdminMovieOverride({
                                  "id": movie.id,
                                  "title": newTitle,
                                  "seriesName": newSeries,
                                  "posterUrl": newPoster,
                                  "backdropUrl": newBackdrop,
                                  "qualityBadge": newQuality,
                                  "synopsis": newSynopsis,
                                  "isFeatured": isFeatured,
                                });

                                if (applyPosterToWholeSeries &&
                                    movie.seriesName.isNotEmpty) {
                                  final siblings = widget.movies.where(
                                    (m) =>
                                        m.id != movie.id &&
                                        m.seriesName.toLowerCase() ==
                                            movie.seriesName.toLowerCase(),
                                  );
                                  for (final sib in siblings) {
                                    widget.onUpdateMovieLocally(
                                      sib.copyWith(posterUrl: newPoster),
                                    );
                                    await MovieCatalogData
                                        .saveAdminMovieOverride({
                                      "id": sib.id,
                                      "posterUrl": newPoster,
                                    });
                                  }
                                }

                                if (ctx.mounted) Navigator.of(ctx).pop();
                                _showToast(
                                    "Poster & details saved for '$newTitle'!");
                              },
                              borderRadius: 18,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF03120D), size: 19),
                                  SizedBox(width: 8),
                                  Text(
                                    "Save Movie & Poster Changes",
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAddCustomMovie() async {
    final rawInputId = _idController.text.trim();
    final title = _titleController.text.trim();
    final poster = _posterController.text.trim();

    if (rawInputId.isEmpty || title.isEmpty) {
      _showToast("Please enter both Streamtape File ID/Link and Movie Title.");
      return;
    }

    String cleanId = rawInputId;
    final urlMatch = RegExp(r"streamtape\.com\/(?:v|e)\/([a-zA-Z0-9_-]+)")
        .firstMatch(rawInputId);
    if (urlMatch != null && urlMatch.group(1) != null) {
      cleanId = urlMatch.group(1)!;
    }

    setState(() => _isSaving = true);

    final finalPoster = poster.isNotEmpty
        ? poster
        : "https://thumb.tapecontent.net/thumb/$cleanId/thumb.jpg";
    final finalBackdrop = _backdropController.text.trim().isNotEmpty
        ? _backdropController.text.trim()
        : finalPoster;
    final releaseYear = int.tryParse(_yearController.text.trim()) ?? 2026;
    final seriesName = _seriesController.text.trim().isNotEmpty
        ? _seriesController.text.trim()
        : title;
    final synopsis = _synopsisController.text.trim().isNotEmpty
        ? _synopsisController.text.trim()
        : "Watch $title streaming live from Streamtape Cloud in HD.";

    final newMovie = MovieItem(
      id: cleanId,
      title: title,
      seriesName: seriesName,
      tagline: "Streamed live from Niooo M Streamtape Cloud.",
      synopsis: synopsis,
      posterUrl: finalPoster,
      backdropUrl: finalBackdrop,
      embedUrl: "https://streamtape.com/e/$cleanId",
      videoStreamUrl: "/api/streamtape/direct?file=$cleanId",
      rating: 9.4,
      releaseYear: releaseYear,
      duration: "HD Stream",
      maturityRating: "HD",
      qualityBadge: _qualityController.text.trim().isEmpty
          ? "1080p Full HD"
          : _qualityController.text.trim(),
      genres: const ["Action", "Cinema"],
      director: "Niooo Studio Originals",
      cast: const [],
      isFeatured: _isFeaturedNew,
      isTrending: true,
      isNewRelease: true,
    );

    widget.onUpdateMovieLocally(newMovie);

    await MovieCatalogData.saveAdminMovieOverride({
      "id": cleanId,
      "title": title,
      "seriesName": seriesName,
      "posterUrl": finalPoster,
      "backdropUrl": finalBackdrop,
      "releaseYear": releaseYear,
      "qualityBadge": newMovie.qualityBadge,
      "synopsis": synopsis,
      "isFeatured": _isFeaturedNew,
      "isCustomAdded": true,
    });

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _idController.clear();
      _titleController.clear();
      _seriesController.clear();
      _posterController.clear();
      _backdropController.clear();
      _synopsisController.clear();
      _activeTab = 0;
    });
    _showToast("Added '$title' with poster to catalog!");
  }

  @override
  Widget build(BuildContext context) {
    final standaloneCount =
        widget.movies.where((m) => m.episodeNumber == 0).length;
    final seriesEpisodesCount =
        widget.movies.where((m) => m.episodeNumber > 0).length;
    final featuredCount = widget.movies.where((m) => m.isFeatured).length;

    final filteredMovies = widget.movies.where((m) {
      if (_filterType == "Movies" && m.episodeNumber > 0) return false;
      if (_filterType == "Series" && m.episodeNumber == 0) return false;
      if (_filterType == "Featured" && !m.isFeatured) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return m.title.toLowerCase().contains(q) ||
          m.seriesName.toLowerCase().contains(q) ||
          m.id.toLowerCase().contains(q);
    }).toList();

    return GlassContainer(
      margin: EdgeInsets.zero,
      borderRadius: 0,
      blur: 30,
      border: const Border(),
      boxShadow: const [],
      backgroundColor: const Color(0xFF040B09).withValues(alpha: 0.94),
      child: Column(
        children: [
          // Full-Screen Admin Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E676).withValues(alpha: 0.16),
                  const Color(0xFF061511).withValues(alpha: 0.9),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00E676).withValues(alpha: 0.28),
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFFF0FDF4),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF03120D),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Niooo M Admin Panel",
                            style: TextStyle(
                              color: Color(0xFFF0FDF4),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "FULL SCREEN",
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.adminEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassIconButton(
                  icon: Icons.cloud_sync_rounded,
                  tooltip: "Force Sync Streamtape",
                  size: 38,
                  color: const Color(0xFF00E676),
                  onTap: () {
                    widget.onRefreshCatalog();
                    _showToast("Syncing live movies from Streamtape...");
                  },
                ),
              ],
            ),
          ),

          // Admin Stats Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildStatTile(
                  label: "Total Streamtape",
                  value: "${widget.movies.length}",
                  icon: Icons.cloud_done_rounded,
                ),
                const SizedBox(width: 8),
                _buildStatTile(
                  label: "Movies",
                  value: "$standaloneCount",
                  icon: Icons.movie_creation_outlined,
                ),
                const SizedBox(width: 8),
                _buildStatTile(
                  label: "Episodes",
                  value: "$seriesEpisodesCount",
                  icon: Icons.video_collection_outlined,
                ),
                const SizedBox(width: 8),
                _buildStatTile(
                  label: "Featured",
                  value: "$featuredCount",
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ),

          // Navigation Tabs inside Admin Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    icon: Icons.video_settings_rounded,
                    label: "Manage Movies & Posters",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    icon: Icons.add_photo_alternate_rounded,
                    label: "Add Movie / Poster",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    index: 2,
                    icon: Icons.vpn_key_rounded,
                    label: "Streamtape API",
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _activeTab == 0
                ? _buildManageMoviesTab(filteredMovies)
                : _activeTab == 1
                    ? _buildAddMovieTab()
                    : _buildStreamtapeApiTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF10B981)],
                )
              : null,
          color: active ? null : const Color(0xFF091714).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? Colors.white54
                : const Color(0xFF00E676).withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? const Color(0xFF03120D) : const Color(0xFF00E676),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF03120D)
                      : const Color(0xFFF0FDF4),
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageMoviesTab(List<MovieItem> filteredMovies) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF091714),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.25),
                    ),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                      color: Color(0xFFF0FDF4),
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Search by movie title, series, or ID...",
                      hintStyle: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF00E676),
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...["All", "Movies", "Series", "Featured"].map((f) {
                final selected = _filterType == f;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterType = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF00E676).withValues(alpha: 0.2)
                            : const Color(0xFF091714),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF00E676)
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF00E676)
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      const Color(0xFF091714).withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: movie.isFeatured
                        ? const Color(0xFF00E676).withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openPosterAndMovieEditorModal(movie),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              movie.posterUrl,
                              width: 64,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 90,
                                color: const Color(0xFF0D211C),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E676),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 12,
                                color: Color(0xFF03120D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  movie.qualityBadge,
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (movie.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "HERO FEATURED",
                                    style: TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "ID: ${movie.id} · ${movie.duration} · ${movie.releaseYear}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildSmallActionChip(
                                icon: Icons.add_photo_alternate_rounded,
                                label: "Poster / Edit",
                                primary: true,
                                onTap: () =>
                                    _openPosterAndMovieEditorModal(movie),
                              ),
                              _buildSmallActionChip(
                                icon: Icons.play_arrow_rounded,
                                label: "Play",
                                onTap: () => widget.onPlayMovie(movie),
                              ),
                              _buildSmallActionChip(
                                icon: movie.isFeatured
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                label: movie.isFeatured ? "Featured" : "Feature",
                                onTap: () async {
                                  final toggled = !movie.isFeatured;
                                  widget.onUpdateMovieLocally(
                                    movie.copyWith(isFeatured: toggled),
                                  );
                                  await MovieCatalogData.saveAdminMovieOverride({
                                    "id": movie.id,
                                    "isFeatured": toggled,
                                  });
                                  _showToast(
                                    toggled
                                        ? "Added '${movie.title}' to Featured Hero!"
                                        : "Removed from Featured Hero",
                                  );
                                },
                              ),
                              _buildSmallActionChip(
                                icon: Icons.delete_outline_rounded,
                                label: "Hide",
                                isDanger: true,
                                onTap: () async {
                                  widget.onDeleteMovieLocally(movie.id);
                                  await MovieCatalogData.deleteAdminMovie(
                                      movie.id);
                                  _showToast(
                                      "Removed '${movie.title}' from active catalog.");
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddMovieTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF091714).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add New Streamtape Movie & Poster",
              style: TextStyle(
                color: Color(0xFFF0FDF4),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Paste any Streamtape video File ID or URL and attach a custom HD poster.",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldBlock(
              label: "STREAMTAPE FILE ID OR VIDEO URL *",
              controller: _idController,
              hint: "e.g. Zk2Rbvkpl9tqzjD or https://streamtape.com/v/...",
              icon: Icons.cloud_upload_rounded,
            ),
            const SizedBox(height: 12),
            _buildFieldBlock(
              label: "MOVIE OR EPISODE TITLE *",
              controller: _titleController,
              hint: "e.g. Pushpa 2: The Rule (2026)",
              icon: Icons.movie_creation_outlined,
            ),
            const SizedBox(height: 12),
            _buildFieldBlock(
              label: "CUSTOM POSTER IMAGE URL (HD) *",
              controller: _posterController,
              hint: "https://image.tmdb.org/t/p/w500/...",
              icon: Icons.add_photo_alternate_rounded,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFieldBlock(
                    label: "SERIES / GROUP NAME",
                    controller: _seriesController,
                    hint: "Optional series name",
                    icon: Icons.folder_special_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFieldBlock(
                    label: "QUALITY BADGE",
                    controller: _qualityController,
                    hint: "4K IMAX / 1080p HD",
                    icon: Icons.hd_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFieldBlock(
              label: "BACKDROP IMAGE URL (OPTIONAL)",
              controller: _backdropController,
              hint: "https://.../backdrop.jpg",
              icon: Icons.panorama_rounded,
            ),
            const SizedBox(height: 12),
            _buildFieldBlock(
              label: "SYNOPSIS / STORYLINE",
              controller: _synopsisController,
              hint: "Write short movie description...",
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF00E676),
              title: const Text(
                "Pin to Home Hero Spotlight",
                style: TextStyle(
                  color: Color(0xFFF0FDF4),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              value: _isFeaturedNew,
              onChanged: (v) => setState(() => _isFeaturedNew = v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onTap: _isSaving ? () {} : _handleAddCustomMovie,
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.publish_rounded,
                      color: Color(0xFF03120D),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isSaving
                          ? "Publishing Movie..."
                          : "Publish Movie & Poster to Platform",
                      style: const TextStyle(
                        color: Color(0xFF03120D),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamtapeApiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF091714).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_done_rounded,
                    color: Color(0xFF00E676), size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Streamtape Cloud API Configuration",
                    style: TextStyle(
                      color: Color(0xFFF0FDF4),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Connected to your Streamtape account. All movies in your account are automatically fetched, organized, and streamed.",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildFieldBlock(
              label: "STREAMTAPE API USERNAME / LOGIN",
              controller: _apiLoginController,
              hint: "fa66d0d4d79c646de270",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildFieldBlock(
              label: "STREAMTAPE API PASSWORD / KEY",
              controller: _apiKeyController,
              hint: "2LBZ94jDzWFxyD",
              icon: Icons.key_rounded,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onTap: () async {
                  setState(() => _isSavingCreds = true);
                  final ok =
                      await MovieCatalogData.updateStreamtapeCredentials(
                    _apiLoginController.text.trim(),
                    _apiKeyController.text.trim(),
                  );
                  if (!mounted) return;
                  setState(() => _isSavingCreds = false);
                  if (ok) {
                    widget.onRefreshCatalog();
                    _showToast("Streamtape API verified & catalog synced!");
                  } else {
                    _showToast(
                        "Could not verify credentials. Please check Login & Key.");
                  }
                },
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  _isSavingCreds
                      ? "Verifying Streamtape API..."
                      : "Save & Sync All Streamtape Movies",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF03120D),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E676),
                  side: BorderSide(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await MovieCatalogData.restoreDeletedMovies();
                  widget.onRefreshCatalog();
                  _showToast(
                      "Restored all hidden Streamtape movies to catalog!");
                },
                icon: const Icon(Icons.restore_rounded, size: 18),
                label: const Text(
                  "Restore Any Hidden Streamtape Movies",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF091714).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF00E676), size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFF0FDF4),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
    bool isDanger = false,
  }) {
    final bgColor = primary
        ? const Color(0xFF00E676)
        : isDanger
            ? const Color(0xFFFF5252).withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.08);
    final fgColor = primary
        ? const Color(0xFF03120D)
        : isDanger
            ? const Color(0xFFFF5252)
            : const Color(0xFFF0FDF4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary
                ? Colors.white38
                : isDanger
                    ? const Color(0xFFFF5252).withValues(alpha: 0.4)
                    : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fgColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF00E676),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFieldBlock({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdminLabel(label),
        const SizedBox(height: 6),
        _buildTextField(
          controller: controller,
          hint: hint,
          icon: icon,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050E0C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.25),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(color: Color(0xFFF0FDF4), fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    );
  }
}
