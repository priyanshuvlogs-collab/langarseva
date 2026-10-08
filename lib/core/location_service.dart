import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Fallback centre when location is unavailable: Connaught Place, New Delhi.
const fallbackLat = 28.6315;
const fallbackLng = 77.2167;

class UserLocation {
  const UserLocation({required this.lat, required this.lng, required this.isFallback, this.label});
  final double lat;
  final double lng;
  final bool isFallback;
  final String? label;

  UserLocation copyWith({double? lat, double? lng, bool? isFallback, String? label}) => UserLocation(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        isFallback: isFallback ?? this.isFallback,
        label: label ?? this.label,
      );
}

class LocationController extends StateNotifier<AsyncValue<UserLocation>> {
  LocationController() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final granted = perm == LocationPermission.always || perm == LocationPermission.whileInUse;
      if (!enabled || !granted) {
        state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      state = AsyncValue.data(UserLocation(lat: pos.latitude, lng: pos.longitude, isFallback: false));
    } catch (_) {
      state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true));
    }
  }

  /// Geocode a free-text place name and recentre there.
  Future<bool> searchPlace(String query) async {
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) return false;
      final r = results.first;
      state = AsyncValue.data(UserLocation(lat: r.latitude, lng: r.longitude, isFallback: true, label: query));
      return true;
    } catch (_) {
      return false;
    }
  }

  void setManual(double lat, double lng, {String? label}) {
    state = AsyncValue.data(UserLocation(lat: lat, lng: lng, isFallback: true, label: label));
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}

final locationProvider =
    StateNotifierProvider<LocationController, AsyncValue<UserLocation>>((ref) => LocationController());
