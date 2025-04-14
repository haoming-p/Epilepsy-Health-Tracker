const axios = require("axios");

// This service encapsulates all interactions with the FHIR server.

const FHIR_SERVER_URL =
  process.env.FHIR_SERVER_URL || "https://hapi.fhir.org/baseR4";

const fhirService = {

  createPatient: async (patientData) => {
    try {
      // Make POST request to FHIR server's Patient endpoint
      const response = await axios.post(
        `${FHIR_SERVER_URL}/Patient`,
        patientData,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );

      // Return the created Patient resource, including its ID
      return response.data;
    } catch (error) {
      // Log detailed error information for debugging
      console.error(
        "FHIR createPatient error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to create patient in FHIR server");
    }
  },

  getPatient: async (patientId) => {
    try {
      // Make GET request to fetch specific Patient by ID
      const response = await axios.get(
        `${FHIR_SERVER_URL}/Patient/${patientId}`,
        {
          headers: {
            Accept: "application/json",
          },
        }
      );

      // Return the Patient resource
      return response.data;
    } catch (error) {
      console.error(
        "FHIR getPatient error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to retrieve patient from FHIR server");
    }
  },
  
  getAllPatients: async (limit = 50, offset = 0) => {
    try {
      // Build the query URL with pagination parameters
      const queryUrl = `${FHIR_SERVER_URL}/Patient?_count=${limit}&_offset=${offset}`;

      // Make GET request to fetch all patients
      const response = await axios.get(queryUrl, {
        headers: {
          Accept: "application/json",
        },
      });

      return response.data;
    } catch (error) {
      console.error(
        "FHIR getAllPatients error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to retrieve patients from FHIR server");
    }
  },


  createMedication: async (medicationData) => {
    try {
      // Make POST request to create Medication resource
      const response = await axios.post(
        `${FHIR_SERVER_URL}/Medication`,
        medicationData,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );

      // Return the created Medication resource
      return response.data;
    } catch (error) {
      console.error(
        "FHIR createMedication error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to create medication in FHIR server");
    }
  },

  createMedicationStatement: async (data) => {
    try {
      // Construct the MedicationStatement resource
      const medicationStatement = {
        resourceType: "MedicationStatement",
        status: "active",
        medicationReference: {
          reference: `Medication/${data.medicationId}`,
          display: data.medicationName,
        },
        subject: {
          reference: `Patient/${data.patientId}`,
        },
        effectiveDateTime: data.dateTime || new Date().toISOString(),
        dosage: [
          {
            text: data.dosage,
          },
        ],
        note: data.notes ? [{ text: data.notes }] : undefined,
      };

      // Make POST request to create MedicationStatement
      const response = await axios.post(
        `${FHIR_SERVER_URL}/MedicationStatement`,
        medicationStatement,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );

      // Return the created MedicationStatement resource
      return response.data;
    } catch (error) {
      console.error(
        "FHIR createMedicationStatement error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to create medication statement in FHIR server");
    }
  },

  getPatientMedicationStatements: async (patientId) => {
    try {
      // Make GET request with patient filter to find all related MedicationStatements
      const response = await axios.get(
        `${FHIR_SERVER_URL}/MedicationStatement?patient=${patientId}`,
        {
          headers: {
            Accept: "application/json",
          },
        }
      );

      // Return the Bundle of MedicationStatements
      return response.data;
    } catch (error) {
      console.error(
        "FHIR getMedicationStatements error:",
        error.response?.data || error.message
      );
      throw new Error(
        "Failed to retrieve medication statements from FHIR server"
      );
    }
  },

  createHeartRateObservation: async (data) => {
    try {
      // Construct the Observation resource for heart rate
      const observation = {
        resourceType: "Observation",
        status: "final",
        code: {
          coding: [
            {
              system: "http://loinc.org",
              code: "8867-4",
              display: "Heart rate",
            },
          ],
          text: "Heart rate",
        },
        subject: {
          reference: `Patient/${data.patientId}`,
        },
        effectiveDateTime: data.timestamp || new Date().toISOString(),
        valueQuantity: {
          value: data.value,
          unit: "beats/minute",
          system: "http://unitsofmeasure.org",
          code: "/min",
        },
      };

      // Make POST request to create Observation
      const response = await axios.post(
        `${FHIR_SERVER_URL}/Observation`,
        observation,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        }
      );

      // Return the created Observation resource
      return response.data;
    } catch (error) {
      console.error(
        "FHIR createHeartRateObservation error:",
        error.response?.data || error.message
      );
      throw new Error("Failed to create heart rate observation in FHIR server");
    }
  },

  getPatientHeartRateObservations: async (patientId, startDate, endDate) => {
    try {
      // Build query URL with patient and code for heart rate
      let queryUrl = `${FHIR_SERVER_URL}/Observation?patient=${patientId}&code=http://loinc.org|8867-4`;

      // Add date filtering if provided
      if (startDate) {
        queryUrl += `&date=ge${startDate}`;
      }
      if (endDate) {
        queryUrl += `&date=le${endDate}`;
      }

      // Make GET request to fetch heart rate observations
      const response = await axios.get(queryUrl, {
        headers: {
          Accept: "application/json",
        },
      });

      // Return the Bundle of Observations
      return response.data;
    } catch (error) {
      console.error(
        "FHIR getHeartRateObservations error:",
        error.response?.data || error.message
      );
      throw new Error(
        "Failed to retrieve heart rate observations from FHIR server"
      );
    }
  },
};

module.exports = fhirService;
