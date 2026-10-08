import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';

class AuthController {
  AuthController(this._db);
  final SupabaseClient _db;

  Future<void> sendOtp(String phone) => _db.auth.signInWithOtp(phone: phone);

  Future<void> verifyOtp(String phone, String token) =>
      _db.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS && Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
      serverClientId: Env.googleWebClientId.isNotEmpty ? Env.googleWebClientId : null,
      scopes: const ['email'],
    );
    final account = await googleSignIn.signIn();
    if (account == null) return; // user cancelled
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw const AuthException('No Google ID token returned');
    await _db.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: auth.accessToken);
  }

  Future<void> signInWithApple() async {
    final rawNonce = _randomNonce();
    final hashed = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: hashed,
    );
    final idToken = credential.identityToken;
    if (idToken == null) throw const AuthException('No Apple ID token returned');
    await _db.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce);
    final name = [credential.givenName, credential.familyName].where((e) => e != null && e.isNotEmpty).join(' ');
    if (name.isNotEmpty) {
      await _db.from('profiles').update({'display_name': name}).eq('id', _db.auth.currentUser!.id);
    }
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<void> deleteAccount() async {
    await _db.rpc('delete_my_account');
    await _db.auth.signOut();
  }

  static String _randomNonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref.watch(supabaseProvider)));

/// Current user's profile row (role, display name). Null when signed out.
final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(supabaseProvider).from('profiles').select().eq('id', user.id).maybeSingle();
});

final isAdminProvider = Provider<bool>((ref) => ref.watch(profileProvider).valueOrNull?['role'] == 'admin');
