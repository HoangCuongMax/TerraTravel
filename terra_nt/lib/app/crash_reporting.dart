import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Network failures fetching public map resources are expected without signal.
/// Limit suppression to known map hosts; failures elsewhere stay reportable.
bool _isOfflineTileError(Object error) {
  if (error is! SocketException || error is! http.ClientException) return false;
  final uri = (error as http.ClientException).uri;
  return uri != null &&
      uri.scheme == 'https' &&
      (uri.host == 'tiles.openfreemap.org' ||
          uri.host == 'fonts.openfreemap.org' ||
          uri.host == 'assets.openfreemap.com');
}

/// Keep Firebase at startup and allow the actual handlers to be tested without
/// initialising Firebase or sending test crashes to the console.
void installCrashReporting({
  required void Function(FlutterErrorDetails) recordFlutterFatalError,
  required void Function(Object, StackTrace) recordFatalError,
}) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // A disposed tile can finish after its image listener was removed. Flutter
    // then sends its expected network failure here, even with silent == true.
    if (details.library == 'image resource service' &&
        _isOfflineTileError(details.exception)) {
      return;
    }
    recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    recordFatalError(error, stack);
    return true;
  };
}
