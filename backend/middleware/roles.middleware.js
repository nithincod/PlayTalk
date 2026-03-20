export function requireSuperAdmin(req, res, next) {
  if (req.user.role !== "super_admin") {
    return res.status(403).json({ error: "Super admin only" });
  }

  if (req.user.approvalStatus !== "approved") {
    return res.status(403).json({ error: "Super admin not approved yet" });
  }

  next();
}

export function requireMatchAdmin(req, res, next) {
  if (req.user.role !== "match_admin") {
    return res.status(403).json({ error: "Match admin only" });
  }

  if (req.user.approvalStatus !== "approved") {
    return res.status(403).json({ error: "Match admin not approved yet" });
  }

  next();
}

export function requireApprovedUser(req, res, next) {
  if (req.user.approvalStatus !== "approved") {
    return res.status(403).json({ error: "Account not approved yet" });
  }

  next();
}