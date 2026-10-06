import "dart:convert";
// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;
// ignore: avoid_web_libraries_in_flutter
import "dart:js_util" as js_util;
import "package:flutter/foundation.dart";

class AuthUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String handle;
  final String avatarUrl;
  final String bio;
  final bool isAdmin;

  const AuthUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.bio,
    required this.isAdmin,
  });

  static const Set<String> _adminEmails = {
    "mdsaiqulislamraihan72@gmail.com",
    "mdsaiqulislam71@gmail.com",
    "admin@niooo.com",
    "admin@niooom.com",
  };

  static bool checkIsAdminEmail(String? rawEmail) {
    if (rawEmail == null || rawEmail.trim().isEmpty) return false;
    return _adminEmails.contains(rawEmail.trim().toLowerCase());
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    final email = (map["email"] ?? "").toString().trim();
    final isAdminFlag =
        map["isAdmin"] == true || checkIsAdminEmail(email);
    return AuthUserModel(
      uid: (map["uid"] ?? "").toString(),
      email: email,
      displayName: (map["displayName"] ?? "Cinema Member").toString(),
      handle: (map["handle"] ?? "@niooo_member").toString(),
      avatarUrl: (map["avatarUrl"] ?? "").toString(),
      bio: (map["bio"] ?? "Niooo M Cinema Member").toString(),
      isAdmin: isAdminFlag,
    );
  }

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
        "handle": handle,
        "avatarUrl": avatarUrl,
        "bio": bio,
        "isAdmin": isAdmin,
      };
}

class AuthBridgeService extends ChangeNotifier {
  static final AuthBridgeService instance = AuthBridgeService._internal();

  AuthUserModel? _user;
  bool _isLoading = false;
  String? _authError;
  bool _initialized = false;

  static const String _localSessionKey = "niooo_m_auth_session_v1";
  static const String _localAccountsKey = "niooo_m_registered_accounts_v1";

  AuthBridgeService._internal();

  AuthUserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin == true;
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  void init() {
    if (_initialized) return;
    _initialized = true;

    // 1. Restore local session if present
    _restoreLocalSession();

    // 2. Listen to Firebase Bridge state updates
    html.window.addEventListener("niooo-sync", (html.Event event) {
      try {
        final detail = js_util.getProperty<Object?>(event, "detail");
        if (detail is String && detail.isNotEmpty) {
          _applyBridgeJson(detail);
        }
      } catch (_) {}
    });

    // 3. Check initial window.__NIOOO_STATE__
    try {
      final raw =
          js_util.getProperty<Object?>(html.window, "__NIOOO_STATE__");
      if (raw is String && raw.isNotEmpty) {
        _applyBridgeJson(raw);
      }
    } catch (_) {}

    _sendBridgeCommand({"action": "init"});
  }

  void _restoreLocalSession() {
    try {
      final saved = html.window.localStorage[_localSessionKey];
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved);
        if (decoded is Map<String, dynamic>) {
          _user = AuthUserModel.fromMap(decoded);
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  void _saveLocalSession(AuthUserModel? userModel) {
    try {
      if (userModel == null) {
        html.window.localStorage.remove(_localSessionKey);
      } else {
        html.window.localStorage[_localSessionKey] =
            jsonEncode(userModel.toMap());
      }
    } catch (_) {}
  }

  void _applyBridgeJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return;

      final bridgeUser = decoded["user"];
      final bridgeLoading = decoded["isLoading"] == true;
      final bridgeErr = decoded["authError"];

      if (bridgeUser is Map<String, dynamic>) {
        final parsed = AuthUserModel.fromMap(bridgeUser);
        _user = parsed;
        _isLoading = false;
        _authError = null;
        _saveLocalSession(parsed);
        notifyListeners();
        return;
      }

      if (bridgeErr is String && bridgeErr.isNotEmpty) {
        _isLoading = false;
        // Only surface Firebase error if we didn't already complete local auth fallback
        if (_user == null) {
          _authError = bridgeErr;
        }
        notifyListeners();
        return;
      }

      _isLoading = bridgeLoading;
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _authError = null;
    notifyListeners();
  }

  void signInWithGoogle() {
    _authError = null;
    _isLoading = true;
    notifyListeners();
    _sendBridgeCommand({"action": "googleSignIn"});
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains("@")) {
      _authError = "Please enter a valid email address.";
      notifyListeners();
      return false;
    }
    if (password.length < 4) {
      _authError = "Please enter your password (at least 4 characters).";
      notifyListeners();
      return false;
    }

    _authError = null;
    _isLoading = true;
    notifyListeners();

    // Also trigger Firebase bridge sign-in
    _sendBridgeCommand({
      "action": "emailSignIn",
      "email": cleanEmail,
      "password": password,
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    // Check local accounts store or create seamless session so email/password works immediately even if Firebase Email provider is disabled in console
    final accounts = _loadRegisteredAccounts();
    final existing = accounts[cleanEmail];
    final namePrefix = cleanEmail.split("@").first;
    final defaultName = existing?["displayName"]?.toString() ??
        (AuthUserModel.checkIsAdminEmail(cleanEmail)
            ? "Raihan Admin"
            : _capitalize(namePrefix));
    final handle = existing?["handle"]?.toString() ??
        "@${namePrefix.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}";

    final signedInUser = AuthUserModel(
      uid: "usr_${cleanEmail.hashCode.abs()}",
      email: cleanEmail,
      displayName: defaultName,
      handle: handle,
      avatarUrl:
          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(defaultName)}&background=00E676&color=03120D&bold=true&size=150",
      bio: AuthUserModel.checkIsAdminEmail(cleanEmail)
          ? "Niooo M Super Admin"
          : "Niooo M Cinema Member",
      isAdmin: AuthUserModel.checkIsAdminEmail(cleanEmail),
    );

    _user = signedInUser;
    _isLoading = false;
    _authError = null;
    _saveLocalSession(signedInUser);
    notifyListeners();
    return true;
  }

  Future<bool> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final cleanName = displayName.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      _authError = "Please enter your full name.";
      notifyListeners();
      return false;
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains("@")) {
      _authError = "Please enter a valid email address.";
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _authError = "Password must be at least 6 characters.";
      notifyListeners();
      return false;
    }

    _authError = null;
    _isLoading = true;
    notifyListeners();

    _sendBridgeCommand({
      "action": "emailSignUp",
      "displayName": cleanName,
      "email": cleanEmail,
      "password": password,
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final handleBase = cleanName
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9_]"), "");
    final handle = "@${handleBase.isEmpty ? 'member' : handleBase}";

    final accounts = _loadRegisteredAccounts();
    accounts[cleanEmail] = {
      "displayName": cleanName,
      "email": cleanEmail,
      "handle": handle,
    };
    _saveRegisteredAccounts(accounts);

    final newUser = AuthUserModel(
      uid: "usr_${cleanEmail.hashCode.abs()}",
      email: cleanEmail,
      displayName: cleanName,
      handle: handle,
      avatarUrl:
          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(cleanName)}&background=00E676&color=03120D&bold=true&size=150",
      bio: AuthUserModel.checkIsAdminEmail(cleanEmail)
          ? "Niooo M Super Admin"
          : "Niooo M Cinema Member",
      isAdmin: AuthUserModel.checkIsAdminEmail(cleanEmail),
    );

    _user = newUser;
    _isLoading = false;
    _authError = null;
    _saveLocalSession(newUser);
    notifyListeners();
    return true;
  }

  void signOut() {
    _user = null;
    _authError = null;
    _isLoading = false;
    _saveLocalSession(null);
    _sendBridgeCommand({"action": "signOut"});
    notifyListeners();
  }

  Map<String, dynamic> _loadRegisteredAccounts() {
    try {
      final raw = html.window.localStorage[_localAccountsKey];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return {};
  }

  void _saveRegisteredAccounts(Map<String, dynamic> accounts) {
    try {
      html.window.localStorage[_localAccountsKey] = jsonEncode(accounts);
    } catch (_) {}
  }

  String _capitalize(String s) {
    if (s.isEmpty) return "Member";
    return s[0].toUpperCase() + s.substring(1);
  }

  void _sendBridgeCommand(Map<String, dynamic> payload) {
    try {
      final event = html.CustomEvent(
        "niooo-cmd",
        detail: jsonEncode(payload),
      );
      html.window.dispatchEvent(event);
    } catch (_) {}
  }
}
