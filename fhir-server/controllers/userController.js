const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const fhirService = require("../services/fhirService");

// JWT secret key (should be in environment variables for security)
const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key";

const userController = {
  registerUser: async (req, res) => {
    try {
      const { firstName, lastName, email, password, birthDate, gender, phone } = req.body;
      
      // Check only for required fields
      if (!email || !password) {
        return res.status(400).json({ message: "Email and password are required" });
      }
  
      // Check if user already exists
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ message: "User already exists" });
      }
  
      // Hash password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
  
      // Prepare Patient resource with optional fields
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
          // Only add phone if provided
          ...(phone ? [{
            system: "phone",
            value: phone,
            use: "mobile",
          }] : []),
          // Email is required
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
        firstName: firstName || "",
        lastName: lastName || "",
      });
  
      // Generate JWT token and return response
      const token = jwt.sign(
        { userId: newUser.id, email: newUser.email },
        JWT_SECRET,
        { expiresIn: "24h" }
      );
  
      res.status(201).json({
        message: "User registered successfully",
        token,
        patientId,
        userId: newUser.id,
      });
    } catch (error) {
      console.error("Registration error:", error);
      res.status(500).json({ 
        message: error.message || "Server error during registration" 
      });
    }
  },

  loginUser: async (req, res) => {
    try {
      const { email, password } = req.body;
  
      // Validation - check if email and password are provided
      if (!email || !password) {
        return res.status(400).json({ message: "Please provide email and password" });
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
  
      // Return success with token and user info
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
  
  getAllPatients: async (req, res) => {
    try {
      // Extract pagination parameters from the query string (if provided)
      const limit = parseInt(req.query.limit) || 50;
      const offset = parseInt(req.query.offset) || 0;

      // Fetch patients from FHIR server
      const result = await fhirService.getAllPatients(limit, offset);

      // Format the response to be more client-friendly
      const formattedData = {
        total: result.total || 0,
        offset: offset,
        limit: limit,
        patients: [],
      };

      // Extract relevant data from each patient
      if (result.entry && result.entry.length > 0) {
        formattedData.patients = result.entry.map((entry) => {
          const patient = entry.resource;

          // Extract name components
          const name =
            patient.name && patient.name.length > 0 ? patient.name[0] : {};
          const family = name.family || "";
          const given = name.given || [];

          // Extract contact information
          const telecom = patient.telecom || [];
          const email = telecom.find((t) => t.system === "email")?.value || "";
          const phone = telecom.find((t) => t.system === "phone")?.value || "";

          // Return simplified patient info
          return {
            id: patient.id,
            name: {
              family: family,
              given: given,
              fullName: [...given, family].filter(Boolean).join(" "),
            },
            gender: patient.gender || "",
            birthDate: patient.birthDate || "",
            contact: {
              email: email,
              phone: phone,
            },
          };
        });
      }

      // Include pagination links
      formattedData.links = {
        self: `/api/users/patients?limit=${limit}&offset=${offset}`,
        next:
          offset + limit < result.total
            ? `/api/users/patients?limit=${limit}&offset=${offset + limit}`
            : null,
        previous:
          offset > 0
            ? `/api/users/patients?limit=${limit}&offset=${Math.max(
                0,
                offset - limit
              )}`
            : null,
      };

      // Return the formatted patient data
      res.json(formattedData);
    } catch (error) {
      console.error("Error getting all patients:", error);
      res.status(500).json({ message: "Failed to get patients" });
    }
  },
};

module.exports = userController;
