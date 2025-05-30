require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const odoo = require('./odooApi');

const router = express.Router();
const secret = process.env.JWT_SECRET;

router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const auth = await odoo.login(username, password);
    const token = jwt.sign(
      { uid: auth.uid, username, password },
      secret,
      { expiresIn: '1h' }
    );
    res.json({ token, userId: auth.uid });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(401).json({ error: 'Login inválido' });
  }
});

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, secret);
    odoo.login(decoded.username, decoded.password)
      .then(auth => {
        if (!auth.uid) {
          return res.status(401).json({ error: 'Credenciales inválidas para Odoo' });
        }
        req.odooAuth = auth;
        next();
      })
      .catch(err => {
        console.error('Error al loguear en Odoo:', err);
        res.status(401).json({ error: 'Token inválido o credenciales incorrectas' });
      });
  } catch (err) {
    console.error('Error verificando token:', err);
    res.status(401).json({ error: 'Token inválido' });
  }
}

module.exports = { router, authMiddleware };
