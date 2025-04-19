const express = require('express');
const router = express.Router();
const userRoutes = require('./userRoutes');
const medicationRoutes = require('./medicationRoutes');
const heartRateRoutes = require('./heartRateRoutes');

// Mount route files
router.use('/users', userRoutes);
router.use('/medications', medicationRoutes);
router.use('/heartrate', heartRateRoutes);

module.exports = router;