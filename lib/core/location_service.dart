import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Fallback centre when location is unavailable: Connaught Place, New Delhi.
const fallbackLat = 28.6315;
const fallbackLng = 77.2167;

enum LocationFailure { none, denied, deniedForever, serviceOff, timeout }

class UserLocation {
  const UserLocation({
    required this.lat,
    required this.lng,
    required this.isFallback,
    this.label,
    this.failure = LocationFailure.none,
  });
  final double lat;
  final double lng;
  final bool isFallback;
  final String? label;
  final LocationFailure failure;

  static const fallback = UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true);
}

class LocationController extends StateNotifier<AsyncValue<UserLocation>> {
  LocationController() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true, failure: LocationFailure.deniedForever));
        return;
      }
      if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
        state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true, failure: LocationFailure.denied));
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true, failure: LocationFailure.serviceOff));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      state = AsyncValue.data(UserLocation(lat: pos.latitude, lng: pos.longitude, isFallback: false));
    } on TimeoutException {
      state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true, failure: LocationFailure.timeout));
    } catch (_) {
      state = const AsyncValue.data(UserLocation(lat: fallbackLat, lng: fallbackLng, isFallback: true, failure: LocationFailure.timeout));
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
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}

final locationProvider =
    StateNotifierProvider<LocationController, AsyncValue<UserLocation>>((ref) => LocationController());
