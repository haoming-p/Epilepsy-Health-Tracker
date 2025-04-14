const { Sequelize } = require('sequelize');
const path = require('path');

// Create a SQLite database connection
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: path.join(__dirname, '../database.sqlite'),
  logging: false
});

// Test connection
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('SQLite connection established.');
  } catch (error) {
    console.error('Unable to connect to SQLite database:', error);
  }
};

// Initialize connection
testConnection();

module.exports = sequelize;