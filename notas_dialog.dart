// notas_styled.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra un bottom sheet animado y estilizado para las notas de un perfume árabe.
void showStyledNotasDialog(
    BuildContext context,
    String nombre,
    Map<String, dynamic> notas,
    ) {
  // ---------------------------------------------------
  // Función auxiliar: crea una sección de notas
  Widget buildSection(
      String label,
      IconData icon,
      Color color,
      Color chipColor,
      List<String> tags,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (ctx, opacity, child) => Opacity(opacity: opacity, child: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.map((n) {
              return Chip(
                label: Text(n, style: GoogleFonts.poppins(color: Colors.black87)),
                backgroundColor: chipColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  // ---------------------------------------------------

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.4,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      builder: (ctx, scroll) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (ctx, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: ((scale - 0.8) / 0.2).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ListView(
              controller: scroll,
              children: [
                // Barra de agarre
                Center(
                  child: Container(
                    height: 4,
                    width: 50,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Título
                Text(
                  'Notas de $nombre',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.amber[200],
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // Secciones
                if ((notas['notas_salida'] as List).isNotEmpty)
                  buildSection(
                    'Salida',
                    Icons.star,
                    const Color(0xFFFFA726),
                    const Color(0xFFFFE082),
                    List<String>.from(notas['notas_salida']),
                  ),

                if ((notas['notas_corazon'] as List).isNotEmpty)
                  buildSection(
                    'Corazón',
                    Icons.favorite,
                    const Color(0xFFF48FB1),
                    const Color(0xFFF8BBD0),
                    List<String>.from(notas['notas_corazon']),
                  ),

                if ((notas['notas_fondo'] as List).isNotEmpty)
                  buildSection(
                    'Fondo',
                    Icons.texture,
                    const Color(0xFF8D6E63),
                    const Color(0xFFBCAAA4),
                    List<String>.from(notas['notas_fondo']),
                  ),

                // Botón Cerrar
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cerrar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}