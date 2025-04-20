const fhirService = require('../services/fhirService');

const heartRateController = {
  // Generate mock heart rate data for a patient
  generateMockHeartRateData: async (req, res) => {
    try {
      const { patientId, days = 3 } = req.body;
      
      if (!patientId) {
        return res.status(400).json({ message: 'Patient ID is required' });
      }
      
      const createdObservations = [];
      const abnormalObservations = [];
      const now = new Date();
      
      // Generate data for the specified number of days
      for (let day = 0; day < days; day++) {
        const date = new Date(now);
        date.setDate(date.getDate() - day);
        let hasAbnormalForDay = false;
        
        // Generate 8 readings throughout the day
        for (let readingIndex = 0; readingIndex < 8; readingIndex++) {
          // Just set the hours evenly throughout the day (0, 3, 6, 9, 12, 15, 18, 21)
          const hours = readingIndex * 3;
          const mins = Math.floor(Math.random() * 60); // Random minute within the hour
          date.setHours(hours, mins, 0, 0);
          
          // Generate a realistic heart rate
          // Base heart rate between 70-90
          const baseHeartRate = 70 + Math.floor(Math.random() * 20);
          
          // Add some variation based on time of day
          let timeVariation = 0;
          if (hours >= 6 && hours <= 9) {
            // Morning activity - higher heart rate
            timeVariation = Math.floor(Math.random() * 20) + 10;
          } else if (hours >= 12 && hours <= 14) {
            // After lunch - slightly higher
            timeVariation = Math.floor(Math.random() * 15) + 5;
          } else if (hours >= 17 && hours <= 19) {
            // Evening exercise - higher heart rate
            timeVariation = Math.floor(Math.random() * 30) + 15;
          } else if (hours >= 22 || hours <= 5) {
            // Sleep - lower heart rate
            timeVariation = -Math.floor(Math.random() * 20) - 10;
          }
          
          // Random variation
          const randomVariation = Math.floor(Math.random() * 15) - 7; // -7 to +7
          
          // Calculate final heart rate
          let heartRate = Math.max(40, Math.min(200, baseHeartRate + timeVariation + randomVariation));
          
          // Determine if abnormal (< 80 or > 165)
          let isAbnormal = heartRate < 80 || heartRate > 165;
          
          // If this is the last reading of the day and we still don't have an abnormal reading,
          // force an abnormal reading to ensure each day has at least one
          if (readingIndex === 7 && !hasAbnormalForDay) {
            // Generate either a low or high abnormal reading
            if (Math.random() < 0.5) {
              // Generate low abnormal (below 80)
              heartRate = Math.max(40, Math.min(79, 60 + Math.floor(Math.random() * 19)));
            } else {
              // Generate high abnormal (above 165)
              heartRate = Math.max(166, Math.min(200, 166 + Math.floor(Math.random() * 34)));
            }
            isAbnormal = true;
          }
          
          if (isAbnormal) {
            hasAbnormalForDay = true;
          }

          // Prepare the data
          const heartRateData = {
            patientId,
            value: heartRate,
            timestamp: date.toISOString(),
            abnormal: isAbnormal
          };
          
          // Create the observation
          const result = await fhirService.createHeartRateObservation(heartRateData);
          createdObservations.push(result.id);
          
          // Store abnormal observations
          if (isAbnormal) {
            abnormalObservations.push({
              id: result.id,
              value: heartRate,
              date: date.toISOString().split('T')[0],
              time: date.toISOString().split('T')[1].substring(0, 8),
              abnormal: true
            });
          }
        }
      }
      
      res.status(201).json({
        message: `Successfully generated ${createdObservations.length} mock heart rate observations`,
        observationCount: createdObservations.length,
        abnormalObservations: abnormalObservations
      });
    } catch (error) {
      console.error('Error generating mock heart rate data:', error);
      res.status(500).json({ message: 'Failed to generate mock heart rate data' });
    }
  },

  // Get abnormal heart rate measurements for a patient
  getAbnormalHeartRates: async (req, res) => {
    try {
      const { patientId } = req.params;
      
      if (!patientId) {
        return res.status(400).json({ message: 'Patient ID is required' });
      }
      
      // Fetch heart rate observations from FHIR
      const result = await fhirService.getPatientHeartRateObservations(patientId);
      // console.log("RAW FHIR response:", JSON.stringify(result, null, 2));

      

      const abnormalHeartRates = [];
      
      if (result.entry && result.entry.length > 0) {
        result.entry.forEach(entry => {
          const obs = entry.resource;
          const heartRate = obs.valueQuantity?.value;
          
          // Check if abnormal (< 80 or > 165)
          if (heartRate < 60 || heartRate > 100) {
            const timestamp = obs.effectiveDateTime;
            const datePart = timestamp.split('T')[0];
            const timePart = timestamp.split('T')[1].substring(0, 8);
            
            abnormalHeartRates.push({
              id: obs.id,
              value: heartRate,
              date: datePart,
              time: timePart,
              abnormal: true
            });
          }
        });
      }
      
      res.json({
        patientId,
        abnormalHeartRates
      });
    } catch (error) {
      console.error('Error getting abnormal heart rates:', error);
      res.status(500).json({ message: 'Failed to get abnormal heart rates' });
    }
  }
};

module.exports = heartRateController;