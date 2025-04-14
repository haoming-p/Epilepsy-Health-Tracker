const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');
const auth = require('../middleware/auth');

// Medication routes
router.post('/', auth, medicationController.createMedication);
router.post('/patient', auth, medicationController.addMedicationToPatient);
router.get('/patient/:patientId', auth, medicationController.getPatientMedications);

module.exports = router;