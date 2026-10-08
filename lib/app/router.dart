import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase_client.dart';
import '../features/admin/admin_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/langars/presentation/home_screen.dart';
import '../features/langars/presentation/langar_detail_screen.dart';
import '../features/profile/favourites_screen.dart';
import '../features/profile/my_submissions_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/seva/my_seva_screen.dart';
import '../features/submit/submit_langar_screen.dart';

/// Routes that need a signed-in user. Visiting them signed out redirects to /login?next=...
const _authRoutes = {'/add', '/profile/submissions', '/profile/seva', '/profile/favourites', '/admin'};

/// Turns a stream (the Supabase auth state stream) into a Listenable so GoRouter
/// re-evaluates `redirect` without being rebuilt.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Built once per app lifetime. Auth changes only trigger `redirect`, never a new router,
/// so navigation state (and `?next=`) survives sign-in and sign-out.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(supabaseProvider).auth;
  final refresh = _StreamListenable(auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = auth.currentUser != null;
      final path = state.uri.path;
      if (!signedIn && _authRoutes.contains(path)) {
        return '/login?next=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (signedIn && path == '/login') {
        return state.uri.queryParameters['next'] ?? '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/langar/:id', builder: (_, s) => LangarDetailScreen(id: s.pathParameters['id']!)),
      // Web share links: https://langarseva.app/l/<id>
      GoRoute(path: '/l/:id', redirect: (_, s) => '/langar/${s.pathParameters['id']}'),
      GoRoute(path: '/add', builder: (_, __) => const SubmitLangarScreen()),
      GoRoute(path: '/login', builder: (_, s) => LoginScreen(next: s.uri.queryParameters['next'])),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/profile/submissions', builder: (_, __) => const MySubmissionsScreen()),
      GoRoute(path: '/profile/seva', builder: (_, __) => const MySevaScreen()),
      GoRoute(path: '/profile/favourites', builder: (_, __) => const FavouritesScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
