const fhirService = require('../services/fhirService');

const medicationController = {
  
  // Create a new medication
  // minimal request: { name: 'Aspirin' }
  // detailed request: { name: 'Aspirin', strength: { value: 500, unit: 'mg' }, form: 'tablet', notes: 'Take with food' }
  createMedication: async (req, res) => {
    try {
      const { name, strength, form, notes } = req.body;
      
      const medicationData = {
        resourceType: 'Medication',
        code: {
          coding: [
            {
              system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
              code: 'user-medication', // Generic code for user-entered medications
              display: name
            }
          ],
          text: name
        },
        form: form ? {
          text: form 
        } : undefined,
        amount: strength ? {
          numerator: {
            value: strength.value,
            unit: strength.unit || 'mg'
          },
          denominator: {
            value: 1
          }
        } : undefined,
        note: notes ? [{ text: notes }] : undefined
      };

      const result = await fhirService.createMedication(medicationData);
      
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

  // add medication schedule to a patient
  // minimal request: {"patientId": "patient-123", "medicationName": "Lisinopril"}
  // detailed request: {"patientId": "patient-123", "medicationName": "Lisinopril", "dosage": "Take 1 tablet daily", "frequency": 1, "timing": ["08:00", "20:00"], "startDate": "2023-10-01", "endDate": "2023-10-31", "notes": "Take with water"}
  addMedicationSchedule: async (req, res) => {
    try {
      const { 
        patientId, 
        medicationId, 
        medicationName,
        dosage, 
        frequency,
        timing, // Array of times to take medication (e.g., ["08:00", "20:00"])
        startDate,
        endDate,
        notes 
      } = req.body;

      if (!patientId || (!medicationId && !medicationName)) {
        return res.status(400).json({ message: 'Patient ID and either Medication ID or name are required' });
      }

      // Create medication first if only name is provided
      let actualMedicationId = medicationId;
      if (!medicationId && medicationName) {
        const medicationData = {
          resourceType: 'Medication',
          code: {
            coding: [{ system: 'http://www.nlm.nih.gov/research/umls/rxnorm', code: 'user-medication', display: medicationName }],
            text: medicationName
          }
        };
        const medResult = await fhirService.createMedication(medicationData);
        actualMedicationId = medResult.id;
      }

      // Create MedicationRequest for scheduling
      const medicationRequest = {
        resourceType: "MedicationRequest",
        status: "active",
        intent: "plan",
        medicationReference: {
          reference: `Medication/${actualMedicationId}`,
          display: medicationName
        },
        subject: {
          reference: `Patient/${patientId}`
        },
        authoredOn: new Date().toISOString(),
        dosageInstruction: [{
          text: dosage || "As directed",
          timing: {
            repeat: {
              frequency: frequency || 1,
              period: 1,
              periodUnit: "d",
              timeOfDay: timing || ["09:00"]
            }
          }
        }],
        dispenseRequest: {
          validityPeriod: {
            start: startDate || new Date().toISOString(),
            end: endDate || undefined
          }
        },
        note: notes ? [{ text: notes }] : undefined
      };

      // Use a new function in the FHIR service to create MedicationRequest
      const result = await fhirService.createMedicationRequest(medicationRequest);
      
      res.status(201).json({
        message: 'Medication schedule created successfully',
        requestId: result.id,
        request: result
      });
    } catch (error) {
      console.error('Error creating medication schedule:', error);
      res.status(500).json({ message: 'Failed to create medication schedule' });
    }
  },

  // Record medication taken
  // detailed request: {"patientId": "patient-123", "medicationId": "med-456", "medicationName": "Lisinopril", "dateTime": "2023-10-01T08:00:00Z", "dosageTaken": "1 tablet
  recordMedicationTaken: async (req, res) => {
    try {
      const { 
        patientId, 
        medicationId,
        medicationName,
        dateTime, // When the medication was taken
        dosageTaken, // What dosage was actually taken
        notes 
      } = req.body;

      if (!patientId || (!medicationId && !medicationName)) {
        return res.status(400).json({ message: 'Patient ID and either Medication ID or name are required' });
      }

      // Create MedicationStatement for recording intake
      const statementData = {
        patientId,
        medicationId,
        medicationName,
        dateTime: dateTime || new Date().toISOString(),
        dosage: dosageTaken || 'As prescribed',
        notes,
        status: 'completed' // This indicates the medication was taken
      };

      const result = await fhirService.createMedicationStatement(statementData);
      
      res.status(201).json({
        message: 'Medication intake recorded successfully',
        statementId: result.id,
        statement: result
      });
    } catch (error) {
      console.error('Error recording medication intake:', error);
      res.status(500).json({ message: 'Failed to record medication intake' });
    }
  },

  // Get patient's medication schedule
  getPatientMedicationSchedule: async (req, res) => {
    try {
      const { patientId } = req.params;
      
      // Use a new function in the FHIR service to get MedicationRequests
      const result = await fhirService.getPatientMedicationRequests(patientId);
      
      res.json(result);
    } catch (error) {
      console.error('Error getting medication schedule:', error);
      res.status(500).json({ message: 'Failed to get medication schedule' });
    }
  },

  // Get medications taken by a patient
  getMedicationsTaken: async (req, res) => {
    try {
      const { patientId } = req.params;
      const { startDate, endDate } = req.query;
      
      // Use existing function but add filter for completed statements
      const result = await fhirService.getPatientMedicationStatements(patientId, 'completed', startDate, endDate);
      
      res.json(result);
    } catch (error) {
      console.error('Error getting medications taken:', error);
      res.status(500).json({ message: 'Failed to get medications taken' });
    }
  }
};

module.exports = medicationController;