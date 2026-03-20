import express from "express";
import { submitMatchEvent } from "../controller/matchevent.controller.js";
import { authMiddleware } from "../middleware/auth.middleware.js";
import { requireMatchAdmin } from "../middleware/roles.middleware.js";

const router = express.Router();

router.post(
  "/admin/tournament/:tournamentId/match/:matchId/event",
  authMiddleware,
  requireMatchAdmin,
  submitMatchEvent
);

export default router;