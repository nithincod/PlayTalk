import express from "express";
import { registerProfile, getCurrentProfile } from "../controller/auth.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";

const router = express.Router();

// after Firebase Auth signup, frontend calls this to create profile in RTDB
router.post("/auth/register-profile", registerProfile);

// fetch current logged-in user profile
router.get("/auth/me", authMiddleware, getCurrentProfile);

export default router;