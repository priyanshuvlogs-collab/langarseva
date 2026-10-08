import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../core/location_service.dart';
import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../langars/data/langar.dart';
import '../langars/data/langar_repository.dart';
import '../langars/presentation/home_screen.dart';
import 'timings_editor.dart';

class SubmitLangarScreen extends ConsumerStatefulWidget {
  const SubmitLangarScreen({super.key});
  @override
  ConsumerState<SubmitLangarScreen> createState() => _SubmitLangarScreenState();
}

class _SubmitLangarScreenState extends ConsumerState<SubmitLangarScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _phone = TextEditingController();
  final _upi = TextEditingController();
  final _url = TextEditingController();
  LatLng? _point;
  List<LangarTiming> _timings = defaultTimings();
  final List<XFile> _photos = [];
  // One read per picked file; re-reading on every rebuild made previews flicker.
  final Map<XFile, Future<Uint8List>> _previews = {};
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _desc, _address, _city, _state, _phone, _upi, _url]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final loc = ref.read(locationProvider).valueOrNull;
    final initial = _point ?? LatLng(loc?.lat ?? fallbackLat, loc?.lng ?? fallbackLng);
    final result = await Navigator.of(context).push<LatLng>(MaterialPageRoute(builder: (_) => MapPickerScreen(initial: initial)));
    if (result == null) return;
    setState(() => _point = result);
    // Best-effort reverse geocode to prefill address fields.
    try {
      final places = await placemarkFromCoordinates(result.latitude, result.longitude);
      if (places.isNotEmpty && mounted) {
        final p = places.first;
        if (_address.text.isEmpty) {
          _address.text = [p.name, p.street, p.subLocality, p.postalCode].where((e) => e != null && e.isNotEmpty).toSet().join(', ');
        }
        if (_city.text.isEmpty) _city.text = p.locality ?? p.subAdministrativeArea ?? '';
        if (_state.text.isEmpty) _state.text = p.administrativeArea ?? '';
      }
    } catch (_) {}
  }

  Future<void> _addPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 75, maxWidth: 1600);
    if (picked.isEmpty) return;
    setState(() {
      for (final x in picked.take(5 - _photos.length)) {
        _photos.add(x);
        _previews[x] = x.readAsBytes();
      }
    });
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_point == null) {
      showSnack(context, l.tapMapToPick);
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(langarRepositoryProvider);
      final urls = <String>[];
      for (final (i, x) in _photos.indexed) {
        final Uint8List bytes = await x.readAsBytes();
        final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        urls.add(await repo.uploadPhoto(user.id, '${DateTime.now().millisecondsSinceEpoch}_$i.$ext', bytes,
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg'));
      }
      await repo.submit(
        name: _name.text.trim(),
        lat: _point!.latitude,
        lng: _point!.longitude,
        description: _desc.text,
        address: _address.text,
        city: _city.text,
        state: _state.text,
        contactPhone: _phone.text,
        donateUpiId: _upi.text,
        donateUrl: _url.text,
        photos: urls,
        timings: _timings,
      );
      ref.invalidate(mySubmissionsProvider);
      ref.invalidate(nearbyLangarsProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          title: Text(l.submittedTitle),
          content: Text(l.submittedInfo),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(l.done))],
        ),
      );
      if (mounted) context.go('/');
    } on PostgrestException catch (e) {
      if (mounted) {
        showSnack(context, switch (e.message) {
          final m when m.contains('langars_upi_fmt') => l.invalidUpi,
          final m when m.contains('langars_url_fmt') => l.invalidUrl,
          final m when m.contains('langars_phone_fmt') => l.invalidPhone,
          'invalid_photo_url' => l.invalidPhoto,
          _ => l.errorGeneric,
        });
      }
    } catch (_) {
      if (mounted) showSnack(context, l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String? req(String? v) => (v == null || v.trim().length < 2) ? l.required : null;
    // Same rules as the database constraints in 0002_hardening.sql.
    String? phone(String? v) =>
        (v == null || v.trim().isEmpty || RegExp(r'^\+?[0-9][0-9 ()-]{5,19}$').hasMatch(v.trim())) ? null : l.invalidPhone;
    String? upi(String? v) =>
        (v == null || v.trim().isEmpty || RegExp(r'^[A-Za-z0-9._-]{2,255}@[A-Za-z0-9]{2,64}$').hasMatch(v.trim())) ? null : l.invalidUpi;
    String? url(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      final u = Uri.tryParse(v.trim());
      return (u != null && u.scheme == 'https' && u.host.contains('.') && v.trim().length <= 500) ? null : l.invalidUrl;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.addLangar)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _name, decoration: InputDecoration(labelText: l.langarName), validator: req, maxLength: 120, textCapitalization: TextCapitalization.words),
            const SizedBox(height: 12),
            TextFormField(controller: _desc, decoration: InputDecoration(labelText: l.description), maxLines: 3, maxLength: 2000),
            const SizedBox(height: 20),
            // Location
            Card(
              child: ListTile(
                leading: Icon(_point == null ? Icons.add_location_alt_outlined : Icons.location_on, color: _point == null ? null : theme.colorScheme.primary),
                title: Text(l.pickLocation),
                subtitle: Text(_point == null ? l.tapMapToPick : '${l.locationPicked} · ${_point!.latitude.toStringAsFixed(5)}, ${_point!.longitude.toStringAsFixed(5)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickLocation,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _address, decoration: InputDecoration(labelText: l.address), validator: req, maxLength: 300),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _city, decoration: InputDecoration(labelText: l.city), validator: req, maxLength: 100)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _state, decoration: InputDecoration(labelText: l.state), maxLength: 100)),
            ]),
            const SizedBox(height: 20),
            Text(l.timings, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TimingsEditor(timings: _timings, onChanged: (t) => setState(() => _timings = t)),
            const SizedBox(height: 20),
            Text(l.photos, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final (i, p) in _photos.indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          FutureBuilder<Uint8List>(
                            future: _previews[p] ??= p.readAsBytes(),
                            builder: (_, s) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: s.hasData
                                  ? Image.memory(s.data!, width: 88, height: 88, fit: BoxFit.cover)
                                  : const SizedBox.square(dimension: 88, child: Center(child: CircularProgressIndicator())),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton.filledTonal(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: _busy ? null : () => setState(() => _previews.remove(_photos.removeAt(i))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_photos.length < 5)
                    OutlinedButton(
                      onPressed: _addPhotos,
                      style: OutlinedButton.styleFrom(fixedSize: const Size(88, 88), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.add_a_photo_outlined),
                        const SizedBox(height: 4),
                        Text(l.addPhotos, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(controller: _phone, decoration: InputDecoration(labelText: l.contactPhone), keyboardType: TextInputType.phone, validator: phone),
            const SizedBox(height: 12),
            TextFormField(controller: _upi, decoration: InputDecoration(labelText: l.donateUpiOptional, hintText: 'name@bank'), validator: upi),
            const SizedBox(height: 12),
            TextFormField(controller: _url, decoration: InputDecoration(labelText: l.donateUrlOptional, hintText: 'https://'), keyboardType: TextInputType.url, validator: url),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined),
              label: Text(l.submit),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, required this.initial});
  final LatLng initial;
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _point = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.pickLocation)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: widget.initial, zoom: 15),
            onTap: (p) => setState(() => _point = p),
            markers: {Marker(markerId: const MarkerId('pick'), position: _point, draggable: true, onDragEnd: (p) => setState(() => _point = p))},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(l.tapMapToPick, textAlign: TextAlign.center))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _point),
        icon: const Icon(Icons.check),
        label: Text(l.done),
      ),
    );
  }
}
