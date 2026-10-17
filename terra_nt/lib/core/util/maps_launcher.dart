import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

typedef MapUrlLauncher = Future<bool> Function(Uri url);

/// Sends Google Maps URLs to the installed Google Maps app when available.
/// On iOS devices without Google Maps, opens the native Apple Maps route
/// instead of leaving the user in Google's web interstitial.
Future<bool> launchDrivingDirections(
  Uri googleMapsUrl, {
  required MapUrlLauncher launcher,
}) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final googleAppUrl = googleMapsUrl.replace(scheme: 'comgooglemapsurl');
    try {
      if (await canLaunchUrl(googleAppUrl)) {
        return await launcher(googleAppUrl);
      }
    } catch (_) {
      // The Google Maps iOS app is optional; use the system map below.
    }

    final parameters = googleMapsUrl.queryParameters;
    final origin = parameters['origin'];
    final destination = parameters['destination'] ?? parameters['daddr'];
    if (destination == null) return false;
    final appleQuery = <String>[
      if (origin != null) 'source=${Uri.encodeQueryComponent(origin)}',
      for (final waypoint
          in (parameters['waypoints'] ?? '')
              .split('|')
              .where((v) => v.isNotEmpty))
        'waypoint=${Uri.encodeQueryComponent(waypoint)}',
      'destination=${Uri.encodeQueryComponent(destination)}',
      'mode=driving',
    ].join('&');
    return launcher(Uri.parse('https://maps.apple.com/directions?$appleQuery'));
  }

  return launcher(googleMapsUrl);
}

/// Opens map URLs outside the app's embedded browser view.
Future<bool> launchMapExternally(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);
