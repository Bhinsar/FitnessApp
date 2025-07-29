const express = require("express");
const { model } = require("mongoose");
const router = express.Router();
const {
  registerUser,
  loginUser,
  refreshToken,
  getUserProfile,
  updateProfile,
} = require("../controllers/userController");
const { authMiddleware } = require("../middlewars/authMiddlewar");

router.post("/auth/register", registerUser);
router.post("/auth/login", loginUser);
router.post("/auth/refresh-token", refreshToken);

router.get("/auth/get-profile", authMiddleware, getUserProfile);
router.put("/auth/update-profile", authMiddleware, updateProfile);

module.exports = router;
