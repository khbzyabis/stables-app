import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/errors.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/hairline.dart';
import '../auth/back_link.dart';

/// Screen 46 — set the stable's location. A real, pannable map (OpenStreetMap
/// tiles tinted to the app's warm palette), a centre pin, and a choice of how
/// precisely to show it.
class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key});
  static const route = '/set-location';

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  static const _default = LatLng(24.8231, 55.2708); // Seih Al Salam, Dubai
  final _map = MapController();
  LatLng _center = _default;
  bool _public = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load the stable's saved pin, if any.
    final s = SessionScope.of(context).activeStable;
    final lat = (s?['lat'] as num?)?.toDouble();
    final lng = (s?['lng'] as num?)?.toDouble();
    if (lat != null && lng != null && _center == _default) {
      _center = LatLng(lat, lng);
      _public = s?['location_public'] == true;
    }
  }

  void _recenter() {
    _map.move(_center, 13);
  }

  Future<void> _save() async {
    final session = SessionScope.of(context);
    final nav = Navigator.of(context);
    final id = session.activeStableId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create a stable first.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await SupabaseService.setStableLocation(
          id, _center.latitude, _center.longitude, _public);
      await session.refresh();
      if (mounted) nav.maybePop();
    } catch (e) {
      AppErrors.report(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Couldn't save: $e")));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackLink(label: 'Stable'),
                  const SizedBox(height: 14),
                  Text(l10n.whereIsStable,
                      style: AppText.heading(32, height: 1.05)),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: AppColors.accent,
                            style: AppText.body(16),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search a place or address',
                              hintStyle:
                                  AppText.body(16, color: AppColors.ink(0.45)),
                            ),
                          ),
                        ),
                        Icon(Icons.search, size: 20, color: AppColors.ink(0.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // The map, gently warmed to the palette.
                      Positioned.fill(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                              Color(0xFFF1E4C9), BlendMode.modulate),
                          child: FlutterMap(
                            mapController: _map,
                            options: MapOptions(
                              initialCenter: _center,
                              initialZoom: 13,
                              onPositionChanged: (pos, _) =>
                                  setState(() => _center = pos.center),
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.pinchZoom |
                                    InteractiveFlag.drag |
                                    InteractiveFlag.doubleTapZoom,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.mystables.app',
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Fixed centre pin — the map pans beneath it.
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 34),
                          child: _CentrePin(),
                        ),
                      ),
                      // Recenter.
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: GestureDetector(
                          onTap: _recenter,
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.warmWhite,
                              shape: BoxShape.circle,
                              boxShadow: AppShadow.md,
                            ),
                            child: Icon(Icons.my_location,
                                size: 21, color: AppColors.accent700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PIN IS HERE',
                      style: AppText.eyebrow(color: AppColors.accent2700)),
                  const SizedBox(height: 8),
                  Text(
                    '${_center.latitude.toStringAsFixed(4)}° N, '
                    '${_center.longitude.toStringAsFixed(4)}° E',
                    style: AppText.body(16, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Hairline(),
                  InkWell(
                    onTap: () => setState(() => _public = !_public),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  _public ? AppColors.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _public
                                      ? AppColors.accent
                                      : AppColors.neutral400,
                                  width: 2),
                            ),
                            child: _public
                                ? const Icon(Icons.check,
                                    size: 16, color: AppColors.bg)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Show the exact pin to everyone',
                                    style: AppText.body(16, height: 1.35)),
                                const SizedBox(height: 4),
                                Text(
                                    _public
                                        ? 'Riders, staff and the vet get directions straight to the gate'
                                        : 'Only the area is shown until someone joins the stable',
                                    style: AppText.body(14,
                                        height: 1.4, color: AppColors.ink(0.5))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Hairline(),
                  const SizedBox(height: 20),
                  AppButton(
                    label: _saving ? 'Saving…' : l10n.saveLocation,
                    minHeight: 54,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The centre marker: a terracotta teardrop with a home glyph.
class _CentrePin extends StatelessWidget {
  const _CentrePin();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bg, width: 3),
            boxShadow: AppShadow.md,
          ),
          child: const Icon(Icons.home_rounded, size: 20, color: AppColors.bg),
        ),
        Container(
          width: 3,
          height: 14,
          color: AppColors.accent,
        ),
      ],
    );
  }
}
