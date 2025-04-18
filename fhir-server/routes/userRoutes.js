const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');

// User routes
router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);
router.get('/me', auth, userController.getUserInfo);

module.exports = router;