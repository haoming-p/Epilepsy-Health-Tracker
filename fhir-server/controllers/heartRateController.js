const fhirService = require('../services/fhirService');

const heartRateController = {
  // Add a heart rate measurement for a patient
  addHeartRate: async (req, res) => {
    try {
      const { patientId, value, timestamp } = req.body;
      if (!patientId || !value) {
        return res.status(400).json({ message: 'Patient ID and heart rate value are required' });
      }
      if (value < 30 || value > 220) {
        return res.status(400).json({ message: 'Heart rate value must be between 30 and 220 BPM' });
      }

      // Prepare data for the Observation
      const heartRateData = {
        patientId,
        value,
        timestamp: timestamp || new Date().toISOString()
      };

      // Create the Observation in FHIR
      const result = await fhirService.createHeartRateObservation(heartRateData);
      
      res.status(201).json({
        message: 'Heart rate observation created successfully',
        observationId: result.id,
        observation: result
      });
    } catch (error) {
      console.error('Error adding heart rate measurement:', error);
      res.status(500).json({ message: 'Failed to add heart rate measurement' });
    }
  },

  // Get heart rate measurements for a patient
  getPatientHeartRates: async (req, res) => {
    try {
      const { patientId } = req.params;
      const { startDate, endDate } = req.query;
      if (!patientId) {
        return res.status(400).json({ message: 'Patient ID is required' });
      }
      // Fetch heart rate observations from FHIR
      const result = await fhirService.getPatientHeartRateObservations(patientId, startDate, endDate);
            const formattedData = {
        patientId,
        heartRates: []
      };
            if (result.entry && result.entry.length > 0) {
        formattedData.heartRates = result.entry.map(entry => {
          const obs = entry.resource;
          return {
            id: obs.id,
            value: obs.valueQuantity?.value,
            unit: obs.valueQuantity?.unit,
            timestamp: obs.effectiveDateTime,
            status: obs.status
          };
        });
      }
            res.json(formattedData);
    } catch (error) {
      console.error('Error getting patient heart rates:', error);
      res.status(500).json({ message: 'Failed to get patient heart rates' });
    }
  },
  
  // Generate mock heart rate data for a patient
  generateMockHeartRateData: async (req, res) => {
    try {
      const { patientId, days = 7, readingsPerDay = 24 } = req.body;
      
      if (!patientId) {
        return res.status(400).json({ message: 'Patient ID is required' });
      }
      
      const createdObservations = [];
      const now = new Date();
      
      // Generate data for the specified number of days
      for (let day = 0; day < days; day++) {
        const date = new Date(now);
        date.setDate(date.getDate() - day);
        
        // Generate readings throughout the day
        for (let reading = 0; reading < readingsPerDay; reading++) {
          // Calculate time - distribute readings evenly throughout the day
          const hour = Math.floor((24 / readingsPerDay) * reading);
          date.setHours(hour, Math.floor(Math.random() * 60), 0, 0);
          
          // Generate a realistic heart rate
          // Base heart rate between 60-80, with fluctuations throughout the day
          const baseHeartRate = 60 + Math.floor(Math.random() * 20);
          const activityVariation = Math.floor(Math.random() * 40) - 10; // -10 to +30
          const heartRate = Math.max(40, Math.min(200, baseHeartRate + activityVariation));
          
          // Prepare the data
          const heartRateData = {
            patientId,
            value: heartRate,
            timestamp: date.toISOString()
          };
          
          // Create the observation
          const result = await fhirService.createHeartRateObservation(heartRateData);
          createdObservations.push(result.id);
        }
      }
      
      res.status(201).json({
        message: `Successfully generated ${createdObservations.length} mock heart rate observations`,
        observationCount: createdObservations.length
      });
    } catch (error) {
      console.error('Error generating mock heart rate data:', error);
      res.status(500).json({ message: 'Failed to generate mock heart rate data' });
    }
  }
};

module.exports = heartRateController;