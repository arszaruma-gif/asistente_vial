const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// 🗄️ Conexión con PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'asistencia_vial',
  password: '12345', // 💻 ¡CAMBIA ESTO por tu clave real de pgAdmin!
  port: 5432,
});

pool.connect((err, client, release) => {
  if (err) {
    return console.error('❌ Error de conexión con pgAdmin:', err.stack);
  }
  console.log('✅ Conexión exitosa a la base de datos en pgAdmin (Tabla: conductors).');
  release();
});

// 🚀 ENDPOINT: Recibe el formulario completo desde Flutter
app.post('/api/drivers', async (req, res) => {
  const {
    name, 
    sector_domicilio,
    fecha_nacimiento,
    email, // Aquí viaja el número de cédula desde Flutter
    hora_inicio,
    zonas_interes, 
    tipo_vehiculo,
    alertas_tiempo_real,
    plate,
    tipo_licencia,
    frecuencia_uso,
    password
  } = req.body;

  const cedula = email; 

  if (!cedula || !plate) {
    return res.status(400).json({ error: 'La Cédula y la Placa son campos obligatorios.' });
  }

  try {
    const query = `
      INSERT INTO conductors (
        name, sector_domicilio, fecha_nacimiento, cedula, hora_inicio, 
        zonas_interes, tipo_vehiculo, alertas_tiempo_real, 
        plate, tipo_licencia, frecuencia_uso, password
      ) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
      RETURNING id, name, cedula, plate;
    `;

    const values = [
      name || 'Conductor Anónimo', 
      sector_domicilio || 'No especificado',
      fecha_nacimiento || '',
      cedula,
      hora_inicio || '',
      zonas_interes || [], 
      tipo_vehiculo || 'Carro',
      alertas_tiempo_real !== undefined ? alertas_tiempo_real : true,
      plate,
      tipo_licencia || 'Licencia Tipo B',
      frecuencia_uso || 'Diaria',
      password || '123456'
    ];

    const result = await pool.query(query, values);
    console.log(`📥 [API] ¡Registro Exitoso!: Conductor: ${result.rows[0].name} | Cédula: ${cedula}`);
    
    res.status(201).json({
      message: '✅ Conductor guardado con éxito en el sistema',
      driver: result.rows[0]
    });

  } catch (error) {
    console.error('❌ Error al guardar en Postgres:', error.message);
    if (error.code === '23505') {
      return res.status(400).json({ error: 'Este número de cédula ya está registrado.' });
    }
    res.status(500).json({ error: 'Error interno en el servidor.' });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor REST activo en http://localhost:${PORT}`);
  console.log(`📶 Esperando peticiones de tu celular.`);
});