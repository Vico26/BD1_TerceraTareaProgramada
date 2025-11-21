// serverPrincipal.js
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Rutas hacia los otros servidores/microservicios
const procesos = require('./routes/procesos'); // Debe apuntar a tu archivo de rutas
const consultas = require('./routes/consultas');
const reportes = require('./routes/reportes');

app.use('/procesos', procesos);
app.use('/consultas', consultas);
app.use('/reportes', reportes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor principal corriendo en puerto ${PORT}`);
});
