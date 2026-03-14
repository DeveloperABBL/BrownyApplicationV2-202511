import 'package:browny_applications_new/core/core_index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart' as line;

enum SocialLoginType {
  // ignore: constant_identifier_names
  FACEBOOK,
  // ignore: constant_identifier_names
  GOOGLE,
  // ignore: constant_identifier_names
  Apple,
  // ignore: constant_identifier_names
  LINE,
}

/// Helper class สำหรับจัดการ Social Login ผ่าน Firebase Authentication
///
/// รองรับ:
/// - Google Sign-In
/// - Apple Sign-In
/// - Facebook Login (เตรียมไว้ - รอ App ID และ App Secret)
/// - LINE Login (ไม่ผ่าน Firebase - ใช้ flutter_line_sdk โดยตรง)
class SocialAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ========== Google Sign-In ==========

  /// Sign in with Google
  /// Returns: [UserCredential] if successful, null if cancelled or failed
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  static Future<void> signOutGoogle({bool needThrowable = false}) async {
    await _googleSignIn.signOut();
  }

  // ========== Apple Sign-In ==========

  /// Sign in with Apple
  /// Returns: [UserCredential] if successful, null if cancelled or failed
  ///
  /// Note: Apple Sign-In is only available on iOS 13+ and macOS 10.15+
  static Future<UserCredential?> signInWithApple() async {
    try {
      // Source - https://stackoverflow.com/a/76943114
      // Posted by Eric Su, modified by community. See post 'Timeline' for change history
      // Retrieved 2026-02-02, License - CC BY-SA 4.0
      AppleAuthProvider appleProvider = AppleAuthProvider();

      // add required 'email' scope
      appleProvider = appleProvider.addScope('email');

      // add optional 'name' scope
      appleProvider = appleProvider.addScope('name');

      // show the Apple sign in UI
      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        appleProvider,
      );

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Check if Apple Sign-In is available on this device
  static Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      return false;
    }
  }

  // ========== Facebook Login ==========

  /// Sign in with Facebook
  /// Returns: [UserCredential] if successful, null if cancelled or failed
  ///
  /// **Note: ต้อง configure Facebook App ID และ App Secret ใน Firebase Console ก่อน**
  /// และตั้งค่าใน:
  /// - Android: strings.xml
  /// - iOS: Info.plist
  ///
  /// **iOS 13.1+**: Use Limited Login to avoid "Bad Signature" error
  /// Set [useLimitedLogin] to true (iOS only, requires iOS 13.1+)
  static Future<UserCredential?> signInWithFacebook({
    bool useLimitedLogin = true, // Enable Limited Login for iOS by default
  }) async {
    try {
      // Trigger the Facebook authentication flow
      await signOut();
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // If user cancels the sign-in
      if (loginResult.status != LoginStatus.success) {
        return null;
      }

      // Get the access token
      final AccessToken? accessToken = loginResult.accessToken;
      if (accessToken == null) {
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in to Firebase with the Facebook credential
      return await _auth.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  /// Sign out from Facebook
  static Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  // ========== LINE Login (ไม่ผ่าน Firebase) ==========

  /// Initialize LINE SDK
  ///
  /// **ต้องเรียก method นี้ใน main() ก่อนใช้งาน LINE Login**
  ///
  /// Parameters:
  /// - [channelId]: LINE Channel ID จาก LINE Developers Console
  static Future<void> initLineSDK(String channelId) async {
    try {
      await line.LineSDK.instance.setup(channelId);
      debugPrint('LINE SDK initialized successfully');
    } catch (e) {
      debugPrint('Error initializing LINE SDK: $e');
      rethrow;
    }
  }

  /// Sign in with LINE
  /// Returns: [line.LoginResult] if successful, null if cancelled or failed
  ///
  /// **Note: LINE Login ไม่รองรับใน Firebase Authentication**
  /// ต้องจัดการ authentication token และ user data เอง
  static Future<line.LoginResult?> signInWithLINE() async {
    try {
      final result = await line.LineSDK.instance.login(
        scopes: ['profile', 'openid', 'email'],
      );
      return result;
    } catch (e) {
      debugPrint('Error signing in with LINE: $e');
      rethrow;
    }
  }

  /// Get current LINE access token
  static Future<line.StoredAccessToken?> getCurrentLINEAccessToken() async {
    try {
      final result = await line.LineSDK.instance.currentAccessToken;
      return result;
    } catch (e) {
      debugPrint('Error getting LINE access token: $e');
      return null;
    }
  }

  /// Get LINE user profile
  static Future<line.UserProfile?> getLINEProfile() async {
    try {
      final result = await line.LineSDK.instance.getProfile();
      return result;
    } catch (e) {
      debugPrint('Error getting LINE profile: $e');
      return null;
    }
  }

  /// Sign out from LINE
  static Future<void> signOutLINE({bool needThrowable = false}) async {
    try {
      await line.LineSDK.instance.logout();
    } catch (e) {
      debugPrint('Error signing out from LINE: $e');
      if (needThrowable) {
        rethrow;
      }
    }
  }

  // ========== Common Methods ==========

  /// Get Facebook Login debug information
  /// Use this to troubleshoot "Bad Signature" or other Facebook login issues
  static Future<Map<String, dynamic>?> getFacebookDirectInfo() async {
    try {
      final accessToken = await FacebookAuth.instance.accessToken;
      final userInfo = accessToken;

      return {
        'isLoggedIn': accessToken != null,
        'hasToken': accessToken?.tokenString != null,
        'tokenLength': accessToken?.tokenString.length ?? 0,
        'userInfo': userInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting Facebook debug info: $e');
      return null;
    }
  }

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Sign out from Firebase (และ Google ถ้ามีการ login ด้วย Google)
  static Future<void> signOut() async {
    // Sign out from Google if signed in
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      await FacebookAuth.instance.logOut();
    }

    // Sign out from Firebase
    await _auth.signOut();
  }

  /// Listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;
}
