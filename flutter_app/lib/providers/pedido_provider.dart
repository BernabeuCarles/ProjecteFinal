import 'package:flutter/material.dart';
import '../models/producto.dart';

class PedidoProvider with ChangeNotifier {
  final Map<int, int> _cantidades = {};
  final Map<int, Producto> _productos = {};

  void agregarProducto(Producto producto) {
    _productos[producto.id] = producto;
    incrementarCantidad(producto.id);
  }

  void quitarProducto(Producto producto) {
    disminuirCantidad(producto.id);
  }

  void incrementarCantidad(int productoId) {
    _cantidades[productoId] = (_cantidades[productoId] ?? 0) + 1;
    notifyListeners();
  }

  void disminuirCantidad(int productoId) {
    final cantidadActual = _cantidades[productoId] ?? 0;
    if (cantidadActual > 0) {
      _cantidades[productoId] = cantidadActual - 1;

      if (_cantidades[productoId] == 0) {
        _productos.remove(productoId);
        _cantidades.remove(productoId);
      }

      notifyListeners();
    }
  }

  int obtenerCantidad(int productoId) => _cantidades[productoId] ?? 0;

  List<PedidoItem> get items {
    return _cantidades.entries
        .where((e) => e.value > 0)
        .map((e) => PedidoItem(
              producto: _productos[e.key]!,
              cantidad: e.value,
            ))
        .toList();
  }

  void limpiarPedido() {
    _cantidades.clear();
    _productos.clear();
    notifyListeners();
  }

  double get total {
    return items.fold(0.0, (sum, item) {
      return sum + (item.producto.listPrice * item.cantidad);
    });
  }

  int get cantidadTotal => _cantidades.values.fold(0, (a, b) => a + b);
}

class PedidoItem {
  final Producto producto;
  final int cantidad;

  PedidoItem({required this.producto, required this.cantidad});
}
