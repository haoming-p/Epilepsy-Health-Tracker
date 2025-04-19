const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const fhirService = require("../services/fhirService");

// Import the heartRateController to use its functions
const heartRateController = require("../controllers/heartRateController");

// JWT secret key (should be in environment variables for security)
const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key";

const userController = {
  registerUser: async (req, res) => {
    try {
      const { firstName, lastName, email, password, birthDate, gender, phone } =
        req.body;
  
      // check email and password are provided
      if (!email || !password) {
        return res
          .status(400)
          .json({ message: "Please provide email and password" });
      }
  
      // Check if user already exists in our database
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ message: "User already exists" });
      }
  
      // Hash password for security
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
  
      // Prepare Patient resource data for FHIR server
      const patientResource = {
        resourceType: "Patient",
        name: [
          {
            use: "official",
            family: lastName || "",
            given: [firstName || ""],
          },
        ],
        gender: gender || "",
        birthDate: birthDate || "",
        telecom: [
          {
            system: "phone",
            value: phone || "",
            use: "mobile",
          },
          {
            system: "email",
            value: email,
          },
        ],
      };
  
      // Create Patient in FHIR server
      const fhirPatient = await fhirService.createPatient(patientResource);
      const patientId = fhirPatient.id;
  
      // Create user in SQLite
      const newUser = await User.create({
        email,
        password: hashedPassword,
        patientId,
        firstName: firstName || null,
        lastName: lastName || null,
      });
  
      // Generate JWT token for authentication
      const token = jwt.sign(
        { userId: newUser.id, email: newUser.email },
        JWT_SECRET,
        { expiresIn: "48h" }
      );
  
      // Start generating mock heart rate data in the background (don't await)
      generateHeartRateDataInBackground(patientId);
  
      // Return success response with token and IDs (no heart rate data yet)
      res.status(201).json({
        message: "User registered successfully",
        token,
        patientId,
        userId: newUser.id
      });
    } catch (error) {
      console.error("Registration error:", error);
      res
        .status(500)
        .json({ message: error.message || "Server error during registration" });
    }
  },

  loginUser: async (req, res) => {
    try {
      const { email, password } = req.body;

      // Validation - check if email and password are provided
      if (!email || !password) {
        return res
          .status(400)
          .json({ message: "Please provide email and password" });
      }

      // Check if user exists
      const user = await User.findOne({ where: { email } });
      if (!user) {
        return res.status(401).json({ message: "No user exists" });
      }

      // Verify password
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ message: "Invalid credentials" });
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        JWT_SECRET,
        { expiresIn: "7d" }
      );

      // Check if heart rate data exists, if not, generate it in the background
      try {
        const heartRateData = await fhirService.getPatientHeartRateObservations(user.patientId);
        
        // If no heart rate data exists, generate it in the background
        if (!heartRateData.entry || heartRateData.entry.length === 0) {
          generateHeartRateDataInBackground(user.patientId);
        }
      } catch (error) {
        console.error("Error checking heart rate data:", error);
        // Continue with login even if heart rate check fails
      }

      // Return success with token and user info (no heart rate data in response)
      res.json({
        message: "Login successful",
        token,
        userId: user.id,
        patientId: user.patientId
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(500).json({ message: "Server error during login" });
    }
  },

  getUserInfo: async (req, res) => {
    try {
      // Get user ID from the authentication middleware
      const userId = req.userId;

      // Get user from SQLite (excluding password)
      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      // Get patient data from FHIR server using the stored patientId
      const patientData = await fhirService.getPatient(user.patientId);

      // Return combined user and patient data
      res.json({
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          patientId: user.patientId,
        },
        patientData, // Complete FHIR Patient resource
      });
    } catch (error) {
      console.error("Error fetching user info:", error);
      res
        .status(500)
        .json({ message: "Server error retrieving user information" });
    }
  },
};

// Helper function to generate heart rate data in the background
function generateHeartRateDataInBackground(patientId) {
  // Run the data generation asynchronously without waiting for it
  setTimeout(async () => {
    try {
      const mockReq = {
        body: {
          patientId,
          days: 3
        }
      };
      
      const mockRes = {
        status: () => ({
          json: (data) => {
            console.log(`Generated ${data.observationCount} heart rate readings for patient ${patientId}`);
          }
        })
      };
      
      await heartRateController.generateMockHeartRateData(mockReq, mockRes);
      console.log(`Completed heart rate data generation for patient ${patientId}`);
    } catch (error) {
      console.error(`Error generating background heart rate data for patient ${patientId}:`, error);
    }
  }, 0);
}

module.exports = userController;