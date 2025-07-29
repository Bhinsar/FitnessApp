const User = require("../model/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

//Register User
exports.registerUser = async (req, res) => {
  try {
    const { email, password, name, profile } = req.body;
    // Validate required fields
    if (!email || !password || !name || !profile) {
      return res
        .status(400)
        .json({ message: "Email, password, name, and profile are required." });
    }
    // Check if user already exists
    const existingUser = await User.findOne({ email: email });
    if (existingUser) {
      return res.status(400).json({
        message: "User with this email already exists. Please login.",
      });
    }
    const hashpassword = await bcrypt.hash(password, 10);
    const newUser = new User({
      email: email,
      password: hashpassword,
      name: name.trim(),
      profile: profile || {},
    });
    const savedUser = await newUser.save();
    // Generate JWT token
    const token = jwt.sign({ id: savedUser._id }, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });
    const refreshToken = jwt.sign(
      { id: savedUser._id },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );
    return res.status(201).json({
      message: "User registered successfully",
      user: {
        id: savedUser._id,
        email: savedUser.email,
        name: savedUser.name,
        profile: savedUser.profile,
      },
      token: token,
      refreshToken: refreshToken,
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};

//Login User
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    // Validate required fields
    if (!email || !password) {
      return res
        .status(400)
        .json({ message: "Email and password are required." });
    }
    // Find user by email
    const user = await User.findOne({ email: email });
    if (!user) {
      return res.status(400).json({ message: "Invalid email or password." });
    }
    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password." });
    }
    // Generate JWT token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });
    const refreshToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });
    return res.status(200).json({
      message: "User logged in successfully",
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        profile: user.profile,
      },
      token: token,
      refreshToken: refreshToken,
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};

//Refresh Token
exports.refreshToken = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ message: "Refresh token is required." });
    }
    // Verify the refresh token
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
      if (err) {
        return res.status(403).json({ message: "Invalid refresh token." });
      }
      // Generate a new JWT token
      const newToken = jwt.sign({ id: decoded.id }, process.env.JWT_SECRET, {
        expiresIn: "1d",
      });
      const newRefreshToken = jwt.sign(
        { id: decoded.id },
        process.env.JWT_SECRET,
        {
          expiresIn: "7d",
        }
      );
      return res.status(200).json({
        message: "Token refreshed successfully",
        token: newToken,
        refreshToken: newRefreshToken,
      });
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};

//Profile Update
exports.updateProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, email, profile } = req.body;
    // Validate required fields
    if (!name || !profile) {
      return res
        .status(400)
        .json({ message: "Name and profile are required." });
    }
    // Find user by ID
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }
    // Update user profile
    user.name = name.trim();
    user.profile = profile;
    if (email) {
      // Check if email is already in use
      const existingUser = await User.findOne({ email: email });
      if (existingUser && existingUser._id.toString() !== userId) {
        return res.status(400).json({
          message: "Email is already in use by another user.",
        });
      }
      user.email = email;
    }
    const updatedUser = await user.save();
    return res.status(200).json({
      message: "Profile updated successfully",
      user: {
        id: updatedUser._id,
        email: updatedUser.email,
        name: updatedUser.name,
        profile: updatedUser.profile,
      },
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};

//Get User Profile
exports.getUserProfile = async (req, res) => {
  try {
    const { _id: userId } = req.user;
    // Find user by ID
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }
    return res.status(200).json({
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        profile: user.profile,
      },
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server error", error: error.message });
  }
};