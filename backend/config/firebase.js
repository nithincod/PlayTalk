import admin from "firebase-admin";
import fs from "fs";
import path from "path";

// 🔐 Load service account
const serviceAccount = JSON.parse(
  fs.readFileSync(
    path.resolve("firebase-key.json"),
    "utf8"
  )
);

// ✅ Initialize ONCE
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://playtalk-5df80-default-rtdb.firebaseio.com",
  });
}

export const db = admin.database();
export default admin;
