const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');
const sequelize = require('./config/database');
require('dotenv').config();

// Initialize Express app
const app = express();

// Set port from environment variables or use default
const PORT = process.env.PORT || 3001;

// =======================================================
// Middleware Setup
// =======================================================

// Enable CORS - allows frontend to communicate with this API
app.use(cors());

// Parse JSON request bodies
app.use(express.json());

// =======================================================
// Database Connection
// =======================================================

// Initialize database and sync models
sequelize.sync()
  .then(() => console.log('Database synchronized'))
  .catch(err => {
    console.error('Database synchronization error:', err);
    process.exit(1);
  });

// =======================================================
// Routes Registration
// =======================================================

// Register all API routes under the /api prefix
app.use('/api', apiRoutes);

// Simple health check route
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// =======================================================
// Server Startup
// =======================================================

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});