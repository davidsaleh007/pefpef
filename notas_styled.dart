// lib/notas_styled.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra un diálogo centrado y auto‐ajustable para las notas.
void showStyledNotasDialog(
    BuildContext context,
    String nombre,
    Map<String, dynamic> notas,
    ) {
  final mq = MediaQuery.of(context);
  final isMobile = mq.size.width < 700;
  final dialogWidth = isMobile
      ? mq.size.width * 0.9    // 90% ancho en móvil
      : 600.0;                 // máximo 600px en escritorio

  showGeneralDialog(
    context: context,
    barrierLabel: 'Notas',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // solo lo necesario
              children: [
                Text(
                  'Notas de $nombre',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.amber[200],
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((notas['notas_salida'] as List).isNotEmpty)
                          _buildSection(
                            icon: Icons.star,
                            label: 'Salida',
                            tags: notas['notas_salida'],
                            color: Colors.orangeAccent,
                            chipColor: Colors.orange[200]!,
                          ),
                        if ((notas['notas_corazon'] as List).isNotEmpty)
                          _buildSection(
                            icon: Icons.favorite,
                            label: 'Corazón',
                            tags: notas['notas_corazon'],
                            color: Colors.pinkAccent,
                            chipColor: Colors.pink[100]!,
                          ),
                        if ((notas['notas_fondo'] as List).isNotEmpty)
                          _buildSection(
                            icon: Icons.texture,
                            label: 'Fondo',
                            tags: notas['notas_fondo'],
                            color: Colors.brown,
                            chipColor: Colors.brown[200]!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0)
              .animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
          child: child,
        ),
      );
    },
  );
}

Widget _buildSection({
  required IconData icon,
  required String label,
  required List tags,
  required Color color,
  required Color chipColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: tags.map<Widget>((n) {
            return Chip(
              label: Text(n, style: GoogleFonts.poppins(color: Colors.black87)),
              backgroundColor: chipColor,
            );
          }).toList(),
        ),
      ],
    ),
  );
}