const express = require('express');
const cors = require('cors');
const { router: authRouter, authMiddleware } = require('./auth');
const odoo = require('./odooApi');

const app = express();

app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  console.log(`Petición recibida: ${req.method} ${req.originalUrl}`);
  next();
});

app.use('/api', authRouter);

app.get('/api/categorias', authMiddleware, async (req, res) => {
  try {
    const categorias = await odoo.getCategorias(req.odooAuth);
    res.json(categorias);
  } catch (error) {
    console.error('Error getCategorias:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

app.get('/api/productos', authMiddleware, async (req, res) => {
  try {
    const categoriaId = req.query.categoriaId;
    const productos = await odoo.getProductos(req.odooAuth, categoriaId);
    res.json(productos);
  } catch (error) {
    console.error('Error getProductos:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener productos' });
  }
});

app.get('/api/clientes', authMiddleware, async (req, res) => {
  try {
    const clientes = await odoo.getClientes(req.odooAuth);
    res.json(clientes);
  } catch (error) {
    console.error('Error getClientes:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener clientes' });
  }
});

app.post('/api/pedidos', authMiddleware, async (req, res) => {
  try {
    const { clienteId, lineas } = req.body;
    const pedido = await odoo.crearPedido(req.odooAuth, clienteId, lineas);
    res.json(pedido);
  } catch (error) {
    console.error('Error crearPedido:', error.stack || error);
    res.status(500).json({ error: error.message || 'Error al crear el pedido' });
  }
});

app.get('/api/clientes/:id/notas', authMiddleware, async (req, res) => {
  try {
    const notas = await odoo.getNotasCliente(req.odooAuth, parseInt(req.params.id));
    res.json({ notas });
  } catch (error) {
    console.error('Error getNotasCliente:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener notas' });
  }
});

app.post('/api/clientes/:id/notas', authMiddleware, async (req, res) => {
  try {
    const clienteId = parseInt(req.params.id);
    const { nota } = req.body;
    await odoo.agregarNotaCliente(req.odooAuth, clienteId, nota);
    res.json({ ok: true });
  } catch (error) {
    console.error('Error agregarNotaCliente:', error.stack || error);
    res.status(500).json({ error: 'Error al agregar nota' });
  }
});

app.post('/api/clientes', authMiddleware, async (req, res) => {
  try {
    const { name, email, phone } = req.body;
    const nuevoClienteId = await odoo.crearCliente(req.odooAuth, { name, email, phone });
    res.json({ id: nuevoClienteId });
  } catch (error) {
    console.error('Error crearCliente:', error.stack || error);
    res.status(500).json({ error: 'Error al crear cliente' });
  }
});

app.get('/api/clientes/:id/pedidos', authMiddleware, async (req, res) => {
  try {
    const clienteId = parseInt(req.params.id);
    const pedidos = await odoo.getPedidosCliente(req.odooAuth, clienteId);
    res.json(pedidos);
  } catch (error) {
    console.error('Error getPedidosCliente:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener pedidos del cliente' });
  }
});

app.get('/api/clientes/:id/informacion', authMiddleware, async (req, res) => {
  try {
    const clienteId = parseInt(req.params.id);
    const cliente = await odoo.getClienteDetalle(req.odooAuth, clienteId);
    res.json(cliente);
  } catch (error) {
    console.error('Error getClienteDetalle:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener detalle del cliente' });
  }
});

app.get('/api/pedidos/:id', authMiddleware, async (req, res) => {
  try {
    const pedidoId = parseInt(req.params.id);
    const pedido = await odoo.getDetallePedido(req.odooAuth, pedidoId);
    res.json(pedido);
  } catch (error) {
    console.error('Error getDetallePedido:', error.stack || error);
    res.status(500).json({ error: 'Error al obtener detalle del pedido' });
  }
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API REST disponible en http://localhost:${PORT}`);
});
