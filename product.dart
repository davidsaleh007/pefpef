class Product {
  final int id;
  final String nombre;
  final String marca;
  final double precio;
  final String imagenUrl;
  final bool tieneNotas;

  Product({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.precio,
    required this.imagenUrl,
    required this.tieneNotas,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
      imagenUrl: json['imagen_url'] ?? '',
      tieneNotas: json['tiene_notas'] == 1 || json['tiene_notas'] == '1',
    );
  }
}