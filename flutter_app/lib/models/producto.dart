class Producto {
  final int id;
  final String name;
  final double listPrice;
  final String? imageBase64;
  final int qtyAvailable;

  Producto({
    required this.id,
    required this.name,
    required this.listPrice,
    this.imageBase64,
    required this.qtyAvailable,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      name: json['name'],
      listPrice: (json['list_price'] as num).toDouble(),
      imageBase64: (json['image_1920'] is String) ? json['image_1920'] : null,
      qtyAvailable: (json['qty_available'] as num?)?.toInt() ?? 0,
    );
  }
}
