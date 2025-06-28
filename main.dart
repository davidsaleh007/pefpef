import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'product.dart';
import 'notas_styled.dart';
import 'widgets/whatsapp_button.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Perfumes PefPef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, textTheme: GoogleFonts.poppinsTextTheme()),
      home: const ProductGrid(),
    );
  }
}

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 700;

class Casa {
  final String name;
  final String icon;
  Casa({required this.name, required this.icon});
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.precio * quantity;
}

Future<Map<String, dynamic>?> fetchNotas(String nombre) async {
  final url = Uri.parse('https://pefpef.com/ver_notas.php?nombre=${Uri.encodeComponent(nombre)}');
  final res = await http.get(url, headers: {'Accept': 'application/json'});
  if (res.statusCode == 200 && !res.body.contains('No hay notas')) {
    return jsonDecode(res.body);
  }
  return null;
}

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});
  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  List<Product> productos = [];
  List<CartItem> carrito = [];
  List<Casa> casas = [];
  bool loading = true;
  String filtro = '';
  List<String> marcas = [];
  final _searchCtrl = TextEditingController();

  double get total => carrito.fold(0, (sum, i) => sum + i.total);
  int get totalUnits => carrito.fold(0, (sum, i) => sum + i.quantity);

  @override
  void initState() {
    super.initState();
    _loadCasas();
    _loadProductos();
  }

  Future<void> _loadCasas() async {
    final res = await http.get(Uri.parse('https://pefpef.com/casas.php'));
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      setState(() {
        casas = (data['casas'] as List).map((j) => Casa(name: j['name'], icon: j['icon'])).toList();
      });
    }
  }

  Future<void> _loadProductos() async {
    const rawToken = 'pefpef123securetoken';
    final token = Uri.encodeComponent(rawToken);
    final marcaParam = marcas.isEmpty ? '' : '&marca=${Uri.encodeComponent(marcas.join(','))}';
    final filterParam = filtro.isEmpty ? '' : '&nombre=${Uri.encodeComponent(filtro)}';
    final uri = Uri.parse('https://pefpef.com/productos.php?token=$token$marcaParam$filterParam');
    final res = await http.get(uri);
    final List data = jsonDecode(res.body);
    setState(() {
      productos = data.map((j) => Product.fromJson(j)).toList();
      loading = false;
    });
  }

  void _toggleMarca(String m) {
    setState(() {
      if (marcas.contains(m)) {
        marcas.remove(m);
      } else {
        marcas.add(m);
      }
      loading = true;
    });
    _loadProductos();
  }

  void _addCart(Product p) {
    setState(() {
      final ex = carrito.firstWhere((i) => i.product.nombre == p.nombre, orElse: () {
        final newItem = CartItem(product: p, quantity: 0);
        carrito.add(newItem);
        return newItem;
      });
      ex.quantity++;
    });
  }

  String _buildWhatsappMessage() {
    final buffer = StringBuffer("Hola, quiero comprar:\n");
    for (final item in carrito) {
      buffer.writeln("- ${item.product.nombre} x${item.quantity} = ${item.total.toStringAsFixed(0)} COP");
    }
    buffer.writeln("Total: ${total.toStringAsFixed(0)} COP");
    return buffer.toString();
  }

  void _sendWhatsapp() async {
    final msg = Uri.encodeComponent(_buildWhatsappMessage());
    final uriApp = Uri.parse("whatsapp://send?phone=573215064945&text=$msg");
    final uriWeb = Uri.parse("https://wa.me/573215064945?text=$msg");

    if (kIsWeb) {
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb);
      }
    } else {
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: Text('Catálogo de Perfumes PefPef', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Stack(
            children: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {
                if (mobile) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                    builder: (context) => StatefulBuilder(
                      builder: (context, setModalState) => SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Column(
                            children: [
                              Text("🛒 Tu carrito", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
                              const SizedBox(height: 12),
                              Expanded(
                                child: carrito.isEmpty
                                    ? Center(child: Text("Vacío"))
                                    : ListView.builder(
                                  itemCount: carrito.length,
                                  itemBuilder: (_, i) {
                                    final item = carrito[i];
                                    return ListTile(
                                      title: Text(item.product.nombre),
                                      subtitle: Text('${item.total.toStringAsFixed(0)} COP'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () {
                                            setState(() {
                                              if (item.quantity > 1) item.quantity--;
                                              else carrito.removeAt(i);
                                            });
                                            setModalState(() {});
                                          }),
                                          Text('${item.quantity}'),
                                          IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () {
                                            setState(() => item.quantity++);
                                            setModalState(() {});
                                          }),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(),
                              Text("Total: ${total.toStringAsFixed(0)} COP", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: carrito.isEmpty ? null : _sendWhatsapp,
                                icon: Icon(Icons.send),
                                label: Text('Finalizar Compra por WhatsApp'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
              if (carrito.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text('$totalUnits', style: TextStyle(fontSize: 12, color: Colors.white))),
                ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre…',
                      suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: () {
                        filtro = _searchCtrl.text;
                        _loadProductos();
                      }),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      filtro = _searchCtrl.text;
                      _loadProductos();
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), // Added padding
                  child: Row(
                    children: casas.map((casa) {
                      // START: === MODIFIED SECTION FOR ANIMATION ===
                      final bool isSelected = marcas.contains(casa.name);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _toggleMarca(casa.name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 65,
                            height: 65,
                            transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                            transformAlignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(casa.icon),
                                fit: BoxFit.cover,
                                // Dim the image if not selected
                                colorFilter: !isSelected
                                    ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                                    : null,
                              ),
                              // Add a border to show selection
                              border: Border.all(
                                color: isSelected ? Colors.deepPurple.shade300 : Colors.transparent,
                                width: 3,
                              ),
                              // Add a shadow to make it pop when selected
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                                  : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                      // END: === MODIFIED SECTION FOR ANIMATION ===
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productos.length,
                    itemBuilder: (_, i) {
                      final p = productos[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(p.imagenUrl, fit: BoxFit.cover, width: double.infinity),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(p.nombre, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            Text('${p.precio.toStringAsFixed(0)} COP', style: GoogleFonts.poppins(color: Colors.deepPurple)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                elevation: 3,
                              ),
                              onPressed: () => _addCart(p),
                              child: Text('Agregar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: () async {
                                final notas = await fetchNotas(p.nombre);
                                if (notas != null) showStyledNotasDialog(context, p.nombre, notas);
                              },
                              child: Text('Ver Notas', style: GoogleFonts.poppins(color: Colors.deepPurple)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!mobile)
            Container(
              width: 280,
              decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade300))),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(12), child: Text('🛒 Tu Pedido', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: carrito.isEmpty
                        ? Center(child: Text('Vacío'))
                        : ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (_, i) {
                        final item = carrito[i];
                        return ListTile(
                          title: Text(item.product.nombre),
                          subtitle: Text('${item.total.toStringAsFixed(0)} COP'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () {
                                setState(() {
                                  if (item.quantity > 1) item.quantity--;
                                  else carrito.removeAt(i);
                                });
                              }),
                              Text('${item.quantity}'),
                              IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () {
                                setState(() => item.quantity++);
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('Total: ${total.toStringAsFixed(0)} COP', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: carrito.isEmpty ? null : _sendWhatsapp,
                          icon: Icon(Icons.send),
                          label: Text('Comprar por WhatsApp'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: const WhatsAppButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}