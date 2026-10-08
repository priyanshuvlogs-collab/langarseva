import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import '../langars/data/langar.dart';

class SevaRepository {
  SevaRepository(this._db);
  final SupabaseClient _db;

  static const _cols = 'id,langar_id,title,description,starts_at,ends_at,capacity,joined';

  Future<List<SevaSlot>> upcomingForLangar(String langarId) async {
    final rows = await _db
        .from('seva_slots')
        .select(_cols)
        .eq('langar_id', langarId)
        .gte('ends_at', DateTime.now().toUtc().toIso8601String())
        .order('starts_at');
    return rows.map(SevaSlot.fromJson).toList();
  }

  Future<Set<String>> mySlotIds(String userId) async {
    final rows = await _db.from('seva_signups').select('slot_id').eq('user_id', userId).eq('status', 'joined');
    return rows.map((r) => r['slot_id'] as String).toSet();
  }

  Future<List<SevaSlot>> mySlots(String userId) async {
    final rows = await _db
        .from('seva_signups')
        .select('seva_slots($_cols,langars(name))')
        .eq('user_id', userId)
        .eq('status', 'joined');
    final slots = rows
        .where((r) => r['seva_slots'] != null)
        .map((r) => SevaSlot.fromJson(r['seva_slots'] as Map<String, dynamic>))
        .toList();
    slots.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return slots;
  }

  Future<void> join(String userId, String slotId) =>
      _db.from('seva_signups').upsert({'slot_id': slotId, 'user_id': userId, 'status': 'joined'});

  Future<void> leave(String userId, String slotId) =>
      _db.from('seva_signups').delete().eq('slot_id', slotId).eq('user_id', userId);

  Future<void> createSlot({
    required String langarId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    String? description,
  }) =>
      _db.from('seva_slots').insert({
        'langar_id': langarId,
        'title': title,
        'description': description,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': endsAt.toUtc().toIso8601String(),
        'capacity': capacity,
      });
}

final sevaRepositoryProvider = Provider<SevaRepository>((ref) => SevaRepository(ref.watch(supabaseProvider)));

final sevaSlotsProvider =
    FutureProvider.family<List<SevaSlot>, String>((ref, langarId) => ref.watch(sevaRepositoryProvider).upcomingForLangar(langarId));

final mySlotIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(sevaRepositoryProvider).mySlotIds(user.id);
});

final mySevaProvider = FutureProvider<List<SevaSlot>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(sevaRepositoryProvider).mySlots(user.id);
});
