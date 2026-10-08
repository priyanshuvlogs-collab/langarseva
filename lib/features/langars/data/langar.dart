import 'package:flutter/material.dart';

enum LangarStatus { pending, approved, rejected }

LangarStatus statusFromString(String? s) => switch (s) {
      'approved' => LangarStatus.approved,
      'rejected' => LangarStatus.rejected,
      _ => LangarStatus.pending,
    };

class Langar {
  const Langar({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.description,
    this.address,
    this.city,
    this.state,
    this.photos = const [],
    this.contactPhone,
    this.donateUpiId,
    this.donateUrl,
    this.distanceM,
    this.isOpen,
    this.status = LangarStatus.approved,
    this.submittedBy,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final double lat;
  final double lng;
  final String? address;
  final String? city;
  final String? state;
  final List<String> photos;
  final String? contactPhone;
  final String? donateUpiId;
  final String? donateUrl;
  final double? distanceM;
  final bool? isOpen;
  final LangarStatus status;
  final String? submittedBy;
  final String? rejectionReason;
  final DateTime? createdAt;

  bool get hasDonation => (donateUpiId?.isNotEmpty ?? false) || (donateUrl?.isNotEmpty ?? false);

  String get shortAddress => [address, city].where((e) => e != null && e.isNotEmpty).join(', ');

  factory Langar.fromJson(Map<String, dynamic> j) => Langar(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        address: j['address'] as String?,
        city: j['city'] as String?,
        state: j['state'] as String?,
        photos: (j['photos'] as List?)?.cast<String>() ?? const [],
        contactPhone: j['contact_phone'] as String?,
        donateUpiId: j['donate_upi_id'] as String?,
        donateUrl: j['donate_url'] as String?,
        distanceM: (j['distance_m'] as num?)?.toDouble(),
        isOpen: j['is_open'] as bool?,
        status: statusFromString(j['status'] as String?),
        submittedBy: j['submitted_by'] as String?,
        rejectionReason: j['rejection_reason'] as String?,
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at'] as String),
      );

  Langar copyWith({double? distanceM, bool? isOpen}) => Langar(
        id: id,
        name: name,
        description: description,
        lat: lat,
        lng: lng,
        address: address,
        city: city,
        state: state,
        photos: photos,
        contactPhone: contactPhone,
        donateUpiId: donateUpiId,
        donateUrl: donateUrl,
        distanceM: distanceM ?? this.distanceM,
        isOpen: isOpen ?? this.isOpen,
        status: status,
        submittedBy: submittedBy,
        rejectionReason: rejectionReason,
        createdAt: createdAt,
      );
}

class LangarTiming {
  const LangarTiming({required this.dayOfWeek, this.opensAt, this.closesAt, this.is24h = false});

  /// 0 = Sunday ... 6 = Saturday (Postgres convention).
  final int dayOfWeek;
  final TimeOfDay? opensAt;
  final TimeOfDay? closesAt;
  final bool is24h;

  factory LangarTiming.fromJson(Map<String, dynamic> j) => LangarTiming(
        dayOfWeek: j['day_of_week'] as int,
        opensAt: parseTime(j['opens_at'] as String?),
        closesAt: parseTime(j['closes_at'] as String?),
        is24h: j['is_24h'] as bool? ?? false,
      );

  Map<String, dynamic> toJson(String langarId) => {
        'langar_id': langarId,
        'day_of_week': dayOfWeek,
        'opens_at': is24h ? null : formatTime(opensAt),
        'closes_at': is24h ? null : formatTime(closesAt),
        'is_24h': is24h,
      };

  static TimeOfDay? parseTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String? formatTime(TimeOfDay? t) =>
      t == null ? null : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class SevaSlot {
  const SevaSlot({
    required this.id,
    required this.langarId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    this.description,
    this.joined = 0,
    this.langarName,
  });
  final String id;
  final String langarId;
  final String title;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int joined;
  final String? langarName;

  int get spotsLeft => (capacity - joined).clamp(0, capacity);
  bool get isFull => spotsLeft == 0;

  factory SevaSlot.fromJson(Map<String, dynamic> j) {
    final counts = j['seva_slot_counts'];
    int joined = 0;
    if (counts is Map) {
      joined = (counts['joined'] as num?)?.toInt() ?? 0;
    } else if (counts is List && counts.isNotEmpty) {
      joined = ((counts.first as Map)['joined'] as num?)?.toInt() ?? 0;
    }
    final langar = j['langars'];
    return SevaSlot(
      id: j['id'] as String,
      langarId: j['langar_id'] as String,
      title: j['title'] as String,
      description: j['description'] as String?,
      startsAt: DateTime.parse(j['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(j['ends_at'] as String).toLocal(),
      capacity: (j['capacity'] as num).toInt(),
      joined: joined,
      langarName: langar is Map ? langar['name'] as String? : null,
    );
  }
}
