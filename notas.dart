class NotasPerfume {
  final List<String> notasSalida;
  final List<String> notasCorazon;
  final List<String> notasFondo;

  NotasPerfume({
    required this.notasSalida,
    required this.notasCorazon,
    required this.notasFondo,
  });

  factory NotasPerfume.fromJson(Map<String, dynamic> json) {
    return NotasPerfume(
      notasSalida: List<String>.from(json['notas_salida'] ?? []),
      notasCorazon: List<String>.from(json['notas_corazon'] ?? []),
      notasFondo: List<String>.from(json['notas_fondo'] ?? []),
    );
  }
}