import 'dart:convert';
import 'package:http/http.dart' as http;

/// Devuelve el Map de notas, o null si no existe
Future<Map<String, dynamic>?> fetchNotas(String nombre) async {
  final url = Uri.parse(
      'https://pefpef.com/ver_notas.php?nombre=${Uri.encodeComponent(nombre)}'
  );
  final res = await http.get(url, headers: {'Accept': 'application/json'});
  if (res.statusCode == 200 && !res.body.contains('No hay notas')) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {}
  }
  return null;
}