const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const foodController = require('../controllers/foodController');

router.get('/restaurants', foodController.getRestaurants);
router.get('/categories', foodController.getCategories);
router.get('/items', foodController.getMenuItems);
router.get('/search', foodController.searchFood);
router.post('/checkout', auth, foodController.checkout);

module.exports = router;
