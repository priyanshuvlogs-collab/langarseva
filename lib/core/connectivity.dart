import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  yield _offline(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(_offline);
});

bool _offline(List<ConnectivityResult> r) => r.isEmpty || r.every((e) => e == ConnectivityResult.none);
