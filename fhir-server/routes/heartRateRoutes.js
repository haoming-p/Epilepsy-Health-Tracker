const express = require('express');
const router = express.Router();
const heartRateController = require('../controllers/heartRateController');
const auth = require('../middleware/auth');

// Heart Rate routes
router.post('/', auth, heartRateController.addHeartRate);
router.get('/patient/:patientId', auth, heartRateController.getPatientHeartRates);
router.post('/generate-mock', auth, heartRateController.generateMockHeartRateData);

module.exports = router;