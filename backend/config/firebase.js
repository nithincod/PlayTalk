import admin from "firebase-admin";
import fs from "fs";

const serviceAccount = JSON.parse(
  fs.readFileSync("./firebase-key.json", "utf8")
);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://playtalk-5df80-default-rtdb.firebaseio.com",
  });
}

const db = admin.database();
const auth = admin.auth();

export { admin, db, auth };