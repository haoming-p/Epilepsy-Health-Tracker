const fhirService = require('../services/fhirService');

const medicationController = {
  // Create a new medication
  createMedication: async (req, res) => {
    try {
      const { name, code, form, strength } = req.body;
      // Construct the FHIR Medication resource
      const medicationData = {
        resourceType: 'Medication',
        code: {
          coding: [
            {
              system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
              code: code || 'unknown',
              display: name
            }
          ],
          text: name
        },
        form: form ? {
          coding: [
            {
              system: 'http://terminology.hl7.org/CodeSystem/v3-orderableDrugForm',
              code: form.code || 'TAB',
              display: form.display || 'Tablet'
            }
          ],
          text: form.text || 'Tablet'
        } : undefined,
        amount: strength ? {
          numerator: {
            value: strength.value,
            unit: strength.unit
          },
          denominator: {
            value: 1
          }
        } : undefined
      };

      // Create the Medication in FHIR
      const result = await fhirService.createMedication(medicationData);
      
      // Return success with the created Medication
      res.status(201).json({
        message: 'Medication created successfully',
        medicationId: result.id,
        medication: result
      });
    } catch (error) {
      console.error('Error creating medication:', error);
      res.status(500).json({ message: 'Failed to create medication' });
    }
  },

  // Add a medication to a patient
  addMedicationToPatient: async (req, res) => {
    try {
      const { patientId, medicationId, medicationName, dosage, dateTime, notes } = req.body;
      if (!patientId || !medicationId) {
        return res.status(400).json({ message: 'Patient ID and Medication ID are required' });
      }

      // Prepare data for the MedicationStatement
      const statementData = {
        patientId,
        medicationId,
        medicationName, 
        dosage: dosage || 'As directed',
        dateTime: dateTime || new Date().toISOString(),
        notes 
      };

      // Create the MedicationStatement in FHIR
      const result = await fhirService.createMedicationStatement(statementData);
      
      res.status(201).json({
        message: 'Medication statement created successfully',
        statementId: result.id,
        statement: result
      });
    } catch (error) {
      console.error('Error adding medication to patient:', error);
      res.status(500).json({ message: 'Failed to add medication to patient' });
    }
  },

  // Get medications for a patient
  getPatientMedications: async (req, res) => {
    try {
      const { patientId } = req.params;
      if (!patientId) {
        return res.status(400).json({ message: 'Patient ID is required' });
      }

      // Fetch medication statements from FHIR
      const result = await fhirService.getPatientMedicationStatements(patientId);
      
      res.json(result);
    } catch (error) {
      console.error('Error getting patient medications:', error);
      res.status(500).json({ message: 'Failed to get patient medications' });
    }
  }
};

module.exports = medicationController;