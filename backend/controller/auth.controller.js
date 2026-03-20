import { db } from "../config/firebase.js";

export async function registerProfile(req, res) {
  try {
    const { uid, name, email, role, collegeId, designation, coordinatorIdNumber, phone } = req.body;

    if (!uid || !name || !email || !role) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    if (!["super_admin", "match_admin", "user"].includes(role)) {
      return res.status(400).json({ error: "Invalid role" });
    }

    let approvalStatus = "approved";

    if (role === "match_admin") {
      approvalStatus = "pending";
    }

    const userProfile = {
      uid,
      name,
      email,
      role,
      approvalStatus,
      collegeId: collegeId || null,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    await db.ref(`users/${uid}`).set(userProfile);

    if (role === "match_admin") {
      await db.ref(`match_admin_requests/${uid}`).set({
        uid,
        name,
        email,
        collegeId: collegeId || null,
        status: "pending",
        requestedAt: Date.now(),
      });
    }

    if (role === "super_admin") {
      await db.ref(`super_admin_requests/${uid}`).set({
        uid,
        name,
        email,
        collegeId: collegeId || null,
        designation: designation || "",
        coordinatorIdNumber: coordinatorIdNumber || "",
        phone: phone || "",
        proofUrls: [],
        status: "pending",
        submittedAt: Date.now(),
      });
    }

    return res.json({
      message: "Profile registered successfully",
      profile: userProfile,
    });
  } catch (err) {
    console.error("REGISTER PROFILE ERROR:", err);
    return res.status(500).json({ error: "Failed to register profile" });
  }
}

export async function getCurrentProfile(req, res) {
  try {
    return res.json({
      uid: req.user.uid,
      name: req.user.name,
      email: req.user.email,
      role: req.user.role,
      approvalStatus: req.user.approvalStatus,
      collegeId: req.user.collegeId || null,
    });
  } catch (err) {
    console.error("GET CURRENT PROFILE ERROR:", err);
    return res.status(500).json({ error: "Failed to fetch profile" });
  }
}