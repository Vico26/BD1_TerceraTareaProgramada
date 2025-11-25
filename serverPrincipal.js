const express = require('express');
const path = require('path'); // para manejar rutas de archivos
const cors = require('cors');
const procesosRoutes = require('./serverProcesos');

const app = express();
const PORT = 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas de la API
app.use('/api', procesosRoutes);

// Servir archivos estáticos (index.html, CSS, JS)
app.use(express.static(path.join(__dirname, 'public')));

// Ruta raíz: enviar index.html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});