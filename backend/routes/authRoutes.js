const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/social', authController.socialLogin);
// PHẦN PUSH: Hồ sơ app — đọc / cập nhật user (cần Bearer token)
router.get('/profile', auth, authController.getProfile);
router.put('/profile', auth, authController.updateProfile);

module.exports = router;
