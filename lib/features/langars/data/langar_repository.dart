import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_client.dart';
import 'langar.dart';

class LangarRepository {
  LangarRepository(this._db);
  final SupabaseClient _db;

  static const _cols =
      'id,name,description,lat,lng,address,city,state,photos,contact_phone,donate_upi_id,donate_url,status,submitted_by,rejection_reason,created_at';

  Future<List<Langar>> nearby({
    required double lat,
    required double lng,
    double radiusM = 25000,
    bool openNow = false,
    int limit = 100,
  }) async {
    final rows = await _db.rpc('nearby_langars', params: {
      'p_lat': lat,
      'p_lng': lng,
      'p_radius_m': radiusM,
      'p_open_now': openNow,
      'p_limit': limit,
    });
    return (rows as List).map((r) => Langar.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Langar?> byId(String id) async {
    final row = await _db.from('langars').select(_cols).eq('id', id).maybeSingle();
    return row == null ? null : Langar.fromJson(row);
  }

  Future<List<LangarTiming>> timings(String langarId) async {
    final rows = await _db
        .from('langar_timings')
        .select('day_of_week,opens_at,closes_at,is_24h')
        .eq('langar_id', langarId)
        .order('day_of_week')
        .order('opens_at');
    return rows.map(LangarTiming.fromJson).toList();
  }

  Future<List<Langar>> mySubmissions(String userId) async {
    final rows =
        await _db.from('langars').select(_cols).eq('submitted_by', userId).order('created_at', ascending: false);
    return rows.map(Langar.fromJson).toList();
  }

  Future<List<Langar>> pending() async {
    final rows = await _db.from('langars').select(_cols).eq('status', 'pending').order('created_at');
    return rows.map(Langar.fromJson).toList();
  }

  Future<void> setStatus(String id, LangarStatus status, {String? reason}) async {
    await _db.from('langars').update({
      'status': status.name,
      'rejection_reason': status == LangarStatus.rejected ? reason : null,
    }).eq('id', id);
  }

  /// Uploads [bytes] to `langar-photos/<uid>/<name>` and returns its public URL.
  Future<String> uploadPhoto(String userId, String name, Uint8List bytes, {String contentType = 'image/jpeg'}) async {
    final path = '$userId/$name';
    await _db.storage.from('langar-photos').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));
    return _db.storage.from('langar-photos').getPublicUrl(path);
  }

  Future<String> submit({
    required String name,
    required double lat,
    required double lng,
    String? description,
    String? address,
    String? city,
    String? state,
    String? contactPhone,
    String? donateUpiId,
    String? donateUrl,
    List<String> photos = const [],
    List<LangarTiming> timings = const [],
  }) async {
    final row = await _db
        .from('langars')
        .insert({
          'name': name,
          'description': _n(description),
          'lat': lat,
          'lng': lng,
          'address': _n(address),
          'city': _n(city),
          'state': _n(state),
          'contact_phone': _n(contactPhone),
          'donate_upi_id': _n(donateUpiId),
          'donate_url': _n(donateUrl),
          'photos': photos,
        })
        .select('id')
        .single();
    final id = row['id'] as String;
    if (timings.isNotEmpty) {
      await _db.from('langar_timings').insert(timings.map((t) => t.toJson(id)).toList());
    }
    return id;
  }

  Future<void> replaceTimings(String langarId, List<LangarTiming> timings) async {
    await _db.from('langar_timings').delete().eq('langar_id', langarId);
    if (timings.isNotEmpty) {
      await _db.from('langar_timings').insert(timings.map((t) => t.toJson(langarId)).toList());
    }
  }

  // ---- favourites ----
  Future<Set<String>> favouriteIds(String userId) async {
    final rows = await _db.from('favourites').select('langar_id').eq('user_id', userId);
    return rows.map((r) => r['langar_id'] as String).toSet();
  }

  Future<List<Langar>> favourites(String userId) async {
    final rows = await _db.from('favourites').select('langars($_cols)').eq('user_id', userId);
    return rows.where((r) => r['langars'] != null).map((r) => Langar.fromJson(r['langars'] as Map<String, dynamic>)).toList();
  }

  Future<void> addFavourite(String userId, String langarId) =>
      _db.from('favourites').upsert({'user_id': userId, 'langar_id': langarId});

  Future<void> removeFavourite(String userId, String langarId) =>
      _db.from('favourites').delete().eq('user_id', userId).eq('langar_id', langarId);

  Future<void> report(String userId, String langarId, String reason) =>
      _db.from('reports').insert({'user_id': userId, 'langar_id': langarId, 'reason': reason});

  static String? _n(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

final langarRepositoryProvider = Provider<LangarRepository>((ref) => LangarRepository(ref.watch(supabaseProvider)));

final langarByIdProvider = FutureProvider.family<Langar?, String>((ref, id) => ref.watch(langarRepositoryProvider).byId(id));

final langarTimingsProvider =
    FutureProvider.family<List<LangarTiming>, String>((ref, id) => ref.watch(langarRepositoryProvider).timings(id));

final favouriteIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(langarRepositoryProvider).favouriteIds(user.id);
});

final mySubmissionsProvider = FutureProvider<List<Langar>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(langarRepositoryProvider).mySubmissions(user.id);
});

final favouritesProvider = FutureProvider<List<Langar>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(langarRepositoryProvider).favourites(user.id);
});

final pendingLangarsProvider = FutureProvider<List<Langar>>((ref) => ref.watch(langarRepositoryProvider).pending());
