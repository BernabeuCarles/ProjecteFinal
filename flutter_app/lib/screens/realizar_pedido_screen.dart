import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/producto.dart';
import '../models/categoria.dart';
import '../providers/pedido_provider.dart';
import 'resumen_pedido_screen.dart';

class RealizarPedidoScreen extends StatefulWidget {
  final Map<String, dynamic> cliente;
  final String token;

  const RealizarPedidoScreen({
    required this.cliente,
    required this.token,
  });

  @override
  _RealizarPedidoScreenState createState() => _RealizarPedidoScreenState();
}

class _RealizarPedidoScreenState extends State<RealizarPedidoScreen>
    with SingleTickerProviderStateMixin {
  List<Categoria> categorias = [];
  List<Producto> productos = [];
  bool isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _fetchCategoriasYProductos();
  }

  Future<void> _fetchCategoriasYProductos() async {
    try {
      final catResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/categorias'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (catResponse.statusCode == 200) {
        final catData = json.decode(catResponse.body);

        categorias = (catData as List)
            .map((e) => Categoria.fromJson(e))
            .where((c) => [4, 5, 6].contains(c.id))
            .toList();

        _tabController = TabController(length: categorias.length, vsync: this);
        _tabController!.addListener(() {
          if (!_tabController!.indexIsChanging) {
            _fetchProductos(categorias[_tabController!.index].id);
          }
        });

        await _fetchProductos(categorias.first.id);
      }
    } catch (e) {
      print('Error al obtener categorías: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchProductos(int categoriaId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/productos?categoriaId=$categoriaId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productos = (data as List).map((e) => Producto.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = Provider.of<PedidoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido para ${widget.cliente['name']}'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: isLoading || _tabController == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.lightBlue[50],
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.black,
                    indicatorColor: Colors.lightBlue,
                    tabs: categorias.map((c) => Tab(text: c.name)).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      final cantidad =
                          pedidoProvider.obtenerCantidad(producto.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        color:
                            producto.qtyAvailable < 6 ? Colors.red[100] : null,
                        child: ListTile(
                          leading: producto.imageBase64 != null
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(
                                      base64Decode(producto.imageBase64!)),
                                  radius: 25,
                                )
                              : CircleAvatar(
                                  child: Icon(Icons.image_not_supported),
                                  radius: 25,
                                ),
                          title: Text(producto.name),
                          subtitle: Text(
                            'Precio: ${producto.listPrice.toStringAsFixed(2)}€',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    pedidoProvider.quitarProducto(producto),
                              ),
                              Text('$cantidad', style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    pedidoProvider.agregarProducto(producto),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    width: 220,
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.shopping_basket),
                      label: Text('Ver Pedido', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        if (pedidoProvider.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No hay productos seleccionados'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumenPedidoScreen(
                              cliente: widget.cliente,
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
