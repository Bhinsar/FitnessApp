const express = require('express');
const { authMiddleware } = require('../middlewars/authMiddlewar');
const { generateAIWorkoutPlan, getExerciseGif, generateAIMealPlan} = require('../controllers/aiPlanController');
const router = express.Router();

router.get("/aiPlan/generateAIWorkoutPlan", authMiddleware, generateAIWorkoutPlan);
router.get("/aiPlan/get-gif", getExerciseGif);
router.get("/aiPlan/generateAIMealPlan", authMiddleware, generateAIMealPlan);

module.exports = router;