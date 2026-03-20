const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');

router.get('/restaurants', foodController.getRestaurants);
router.get('/categories', foodController.getCategories);
router.get('/items', foodController.getMenuItems);
router.get('/search', foodController.searchFood);

module.exports = router;
