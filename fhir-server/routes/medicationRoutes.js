const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');
const auth = require('../middleware/auth');

// Test route to check if the server is running
router.get('/test', (req, res) => {
    res.status(200).json({ message: 'Test route works!' });
  });

// Create a new medication
router.post('/addMedication', auth, medicationController.createMedication);

// Add medication schedule to a patient
router.post('/schedule', auth, medicationController.addMedicationSchedule);

// Record medication taken
router.post('/taken', auth, medicationController.recordMedicationTaken);

// Get patient's medication schedule
router.get('/schedule/:patientId', auth, medicationController.getPatientMedicationSchedule);

// Get medications taken by a patient
router.get('/taken/:patientId', auth, medicationController.getMedicationsTaken);

module.exports = router;