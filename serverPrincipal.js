const express = require('express');
const path = require('path');
const cors = require('cors');
const procesosRoutes = require('./serverProcesos');

const app = express();
const PORT = 3000;

// Logger simple para diagnosticar rutas que sí/NO llegan
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.originalUrl}`);
  next();
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas de la API (DEBE ir antes de static)
app.use('/api', procesosRoutes);

// 404 JSON SOLO para /api/* (evita HTML)
app.use('/api', (req, res) => {
  res.status(404).json({ error: 'Ruta API no encontrada', path: req.originalUrl });
});

// Static + raíz
app.use(express.static(path.join(__dirname, 'public')));
app.get('/', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
