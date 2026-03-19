const express = require('express');
const router = express.Router();

router.get('/status', (req, res) => {
  res.json({ 
    status: 'online',
    feature: 'chat',
    enabled: true
  });
});

module.exports = router;
