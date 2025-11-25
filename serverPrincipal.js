const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

// Importar todas las rutas desde serverProcesos.js
const procesosRouter = require('./serverProcesos');

const app = express();
const PORT = 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Rutas
app.use('/api', procesosRouter);

// Ruta de prueba
app.get('/', (req, res) => {
    res.send('Servidor funcionando correctamente!');
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
