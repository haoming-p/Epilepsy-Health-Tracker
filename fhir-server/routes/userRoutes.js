const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');

// User routes
router.post('/register', userController.registerUser);
router.get('/me', auth, userController.getUserInfo);
router.get('/patients', userController.getAllPatients);

module.exports = router;