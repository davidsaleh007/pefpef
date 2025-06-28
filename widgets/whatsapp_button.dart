import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class WhatsAppButton extends StatefulWidget {
  const WhatsAppButton({super.key});

  @override
  State<WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<WhatsAppButton>
    with SingleTickerProviderStateMixin {

  static const _phone = '573144613936';
  static const _text = '¡Hola! Me interesa un perfume.';

  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final Animation<double> _animY = Tween(begin: -8.0, end: 8.0)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_ctl);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _openWhatsapp() async {
    final uriApp = Uri.parse('whatsapp://send?phone=$_phone&text=${Uri.encodeComponent(_text)}');
    final uriWeb = Uri.parse('https://wa.me/$_phone?text=${Uri.encodeComponent(_text)}');

    if (kIsWeb) {
      // Web version: always open browser link
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    } else {
      // Mobile: Try app, fallback to browser
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animY,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _animY.value),
        child: child,
      ),
      child: FloatingActionButton(
        onPressed: _openWhatsapp,
        backgroundColor: const Color(0xFF25D366),
        tooltip: 'Chatear por WhatsApp',
        child: ClipOval(
          child: Image.asset(
            'assets/whatsappiconchat.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}