const express = require('express');
const router = express.Router();
const heartRateController = require('../controllers/heartRateController');

// Heart Rate routes
router.post('/mock', heartRateController.generateMockHeartRateData); 
router.get('/:patientId/abnormal', heartRateController.getAbnormalHeartRates); 

module.exports = router;