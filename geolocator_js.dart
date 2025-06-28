// lib/utils/geolocator_js.dart
import 'dart:async';
import 'dart:js' as js;

class GeolocatorJS {
  /// Retorna un Map con 'latitude', 'longitude' y 'accuracy',
  /// o lanza String en caso de error.
  static Future<Map<String, dynamic>> getCurrentPosition() {
    final completer = Completer<Map<String, dynamic>>();
    final promise = js.context.callMethod('getFlutterGeolocation', []);
    promise.callMethod('then', [
          (result) {
        completer.complete({
          'latitude': result['latitude'],
          'longitude': result['longitude'],
          'accuracy': result['accuracy'],
        });
      }
    ]);
    promise.callMethod('catch', [
          (error) => completer.completeError(error)
    ]);
    return completer.future;
  }
}