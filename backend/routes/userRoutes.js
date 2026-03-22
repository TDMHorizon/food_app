// PHẦN PUSH (backend): API phục vụ tab "Khác" — thẻ, đơn hàng, thông báo, inbox (/api/user/...)
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const userController = require('../controllers/userController');

router.get('/cards', auth, userController.getCards);
router.post('/cards', auth, userController.addCard);
router.delete('/cards/:id', auth, userController.deleteCard);
router.get('/orders', auth, userController.getOrders);
router.get('/notifications', auth, userController.getNotifications);
router.get('/notifications/unread-count', auth, userController.getUnreadNotificationCount);
router.get('/inbox', auth, userController.getInbox);

module.exports = router;
