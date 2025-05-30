const axios = require('axios');
const odooUrl = 'http://localhost:8069';
const db = 'bp_db';

async function login(username, password) {
  const res = await axios.post(`${odooUrl}/jsonrpc`, {
    jsonrpc: "2.0", method: "call",
    params: { service: "common", method: "authenticate", args: [db, username, password, {}] },
    id: 1
  });
  const uid = res.data.result;
  if (!uid) throw new Error('Login fallido');
  return { uid, username, password };
}

async function odooCall(auth, model, method, args, kwargs = {}) {
  const resp = await axios.post(`${odooUrl}/jsonrpc`, {
    jsonrpc: "2.0", method: "call",
    params: { service: "object", method: "execute_kw", args: [db, auth.uid, auth.password, model, method, args, kwargs] },
    id: new Date().getTime()
  });
  return resp.data.result;
}

async function getCategorias(auth) {
  return await odooCall(auth, 'product.category', 'search_read', [[]], { fields: ['id','name'] });
}

async function getProductos(auth, categoriaId = null) {
  const domain = categoriaId ? [['categ_id', '=', Number(categoriaId)]] : [];
  return await odooCall(auth, 'product.template', 'search_read', [domain], {
    fields: ['id', 'name', 'list_price', 'categ_id', 'image_1920', 'qty_available']  
  });
}



async function getClientes(auth) {
  return await odooCall(auth, 'res.partner','search_read',[
    [['customer_rank','>',0],['user_id','=',auth.uid]]
  ],{ fields:['id','name','email','phone','customer_rank','user_id'] });
}

async function crearPedido(auth, clienteId, lineasPedido) {
  if (!Array.isArray(lineasPedido) || lineasPedido.length === 0) {
    throw new Error('El pedido debe tener al menos una línea');
  }

  const orderLines = lineasPedido.map(linea => [
    0, 0, {
      product_id: linea.productoId,
      product_uom_qty: linea.cantidad,
      price_unit: linea.precio,
    }
  ]);

  const orderId = await odooCall(auth, 'sale.order', 'create', [{
    partner_id: clienteId,
    order_line: orderLines,
  }]);

  return { id: orderId };
}

async function getNotasCliente(auth, clienteId) {
  const r = await odooCall(auth,'res.partner','read',[[clienteId]],{fields:['comment']});
  return r[0]?.comment||'';
}

async function agregarNotaCliente(auth, clienteId, nota) {
  const actual = await getNotasCliente(auth, clienteId);
  const nueva = actual?`${actual}\n${new Date()}: ${nota}`:`${new Date()}: ${nota}`;
  return await odooCall(auth,'res.partner','write',[[clienteId],{comment:nueva}]);
}

async function crearCliente(auth, {
  name, email, phone,
  company_name, street, city, state, country, zip
}) {
  return await odooCall(auth, 'res.partner', 'create', [{
    name,
    email,
    phone,
    customer_rank: 1,
    user_id: auth.uid,
    company_name,
    street,
    city,
    state,
    country,
    zip
  }]);
}


async function getPedidosCliente(auth, clienteId) {
  const pedidos = await odooCall(auth, 'sale.order', 'search_read', [
    [['partner_id', '=', clienteId]],
  ], {
    fields: ['id', 'name', 'date_order', 'state', 'amount_total', 'invoice_ids'],
    order: 'date_order desc',
    limit: 10,
  });

  const todasFacturasIds = pedidos.flatMap(p => p.invoice_ids);

  let estadosFacturas = {};
  if (todasFacturasIds.length > 0) {
    const facturas = await odooCall(auth, 'account.move', 'read', [todasFacturasIds], {
      fields: ['id', 'payment_state'],
    });
    facturas.forEach(f => {
      estadosFacturas[f.id] = f.payment_state;
    });
  }

  return pedidos.map(p => ({
    id: p.id,
    name: p.name,
    fecha: p.date_order,
    total: p.amount_total,
    estado: p.state, 
    pagado: p.invoice_ids.some(fid => estadosFacturas[fid] === 'paid')
  }));
}

async function getClienteDetalle(auth, clienteId) {
  const resultado = await odooCall(auth, 'res.partner', 'read', [[clienteId]], {
    fields: [
      'id', 'name', 'email', 'phone', 'mobile', 'street', 'city', 'state_id',
      'zip', 'country_id', 'company_name', 'comment', 'vat'
    ]
  });

  if (resultado.length === 0) throw new Error('Cliente no encontrado');
  const cliente = resultado[0];

  function limpiarCampo(campo) {
    return typeof campo === 'string' ? campo : '';
  }

  return {
    id: cliente.id,
    nombre: limpiarCampo(cliente.name),
    email: limpiarCampo(cliente.email),
    telefono: limpiarCampo(cliente.phone),
    movil: limpiarCampo(cliente.mobile),
    calle: limpiarCampo(cliente.street),
    ciudad: limpiarCampo(cliente.city),
    provincia: Array.isArray(cliente.state_id) ? cliente.state_id[1] : '',
    codigo_postal: limpiarCampo(cliente.zip),
    pais: Array.isArray(cliente.country_id) ? cliente.country_id[1] : '',
    empresa: limpiarCampo(cliente.company_name),
    notas: limpiarCampo(cliente.comment),
    cif: limpiarCampo(cliente.vat),
  };
}


async function getDetallePedido(auth, pedidoId) {
  const pedidos = await odooCall(auth, 'sale.order', 'read', [[pedidoId]], {
    fields: ['name', 'order_line']
  });

  const lineIds = pedidos[0].order_line;

  const lineas = await odooCall(auth, 'sale.order.line', 'read', [lineIds], {
    fields: ['product_id', 'product_uom_qty', 'price_unit', 'name']
  });

  return lineas.map(l => ({
    nombre_producto: l.product_id[1],
    descripcion: l.name,
    cantidad: l.product_uom_qty,
    precio_unitario: l.price_unit,
    total: l.product_uom_qty * l.price_unit,
  }));
}


module.exports = {
  login, getCategorias, getProductos, getClientes,
  crearPedido, getNotasCliente, agregarNotaCliente, crearCliente, getPedidosCliente, getClienteDetalle, getDetallePedido
};
