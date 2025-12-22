# Phase 2 – Admin & College Access Testing Documentation

This document outlines the testing procedures for **PlayTalk Phase 2**, focusing on role permissions, secure backend behavior, and college-level data isolation.

---

## 🛠 Setup & Environment

* **Backend:** `http://localhost:3000`
* **Database:** Firebase Realtime Database
* **Testing Tool:** Postman

### Test Entities
| Role | ID | Description |
| :--- | :--- | :--- |
| **College** | `CLG_001` | Primary testing organization |
| **Super Admin** | `ADMIN_SA` | Full college-level management |
| **Match Admin** | `ADMIN_MA` | Assigned to specific matches |

---

## 🛡️ 1. Authentication & Role Security

### Test 1: Anonymous Access (Blocked)
**Purpose:** Ensure API endpoints cannot be accessed without an Admin ID.
* **Endpoint:** `POST /admin/create-tournament`
* **Headers:** None
* **Expected Result:** ```json
    { "error": "Admin ID missing" }
    ```
* **Conclusion:** Anonymous access is successfully blocked.

### Test 2: Role-Based Restriction (Blocked)
**Purpose:** Verify that Match Admins cannot perform Super Admin actions.
* **Endpoint:** `POST /admin/create-tournament`
* **Header:** `x-admin-id: ADMIN_MA`
* **Expected Result:**
    ```json
    { "error": "Super admin access required" }
    ```
* **Conclusion:** Permissions are correctly enforced based on roles.

---

## 🏆 2. Admin Operations

### Test 3: Super Admin Tournament Creation
**Purpose:** Verify Super Admin can create tournaments for their college.
* **Endpoint:** `POST /admin/create-tournament`
* **Header:** `x-admin-id: ADMIN_SA`
* **Body:**
    ```json
    {
      "name": "Badminton Cup",
      "sport": "badminton",
      "mode": "manual"
    }
    ```
* **Expected Result:**
    ```json
    {
      "message": "Tournament created",
      "tournament_id": "T001"
    }
    ```

### Test 4: Assigning Match Admins
**Purpose:** Verify Super Admin can delegate match management.
* **Endpoint:** `POST /admin/assign-match`
* **Header:** `x-admin-id: ADMIN_SA`
* **Body:**
    ```json
    {
      "match_id": "M001",
      "match_admin_id": "ADMIN_MA"
    }
    ```
* **Expected Result:** `{ "message": "Match admin assigned" }`

### Test 5: Filtered Admin View
**Purpose:** Ensure Match Admins only see matches they are assigned to.
* **Endpoint:** `GET /admin/my-matches`
* **Header:** `x-admin-id: ADMIN_MA`
* **Expected Result:**
    ```json
    [
      { "match_id": "M001", "assigned_admin": "ADMIN_MA" }
    ]
    ```

---

## 🔒 3. College Data Isolation (Security)

### Test 6: Cross-College Data Injection
**Purpose:** Ensure an admin cannot access or create data for a different college.
* **Endpoint:** `POST /admin/create-tournament`
* **Header:** `x-admin-id: ADMIN_SA`
* **Body (Unauthorized Attempt):**
    ```json
    {
      "name": "Unauthorized Tournament",
      "college_id": "FAKE_COLLEGE_ID"
    }
    ```
* **Expected Behavior:** The backend must ignore the `college_id` in the request body and use the ID associated with the admin's session.
* **Verification (Firebase Check):**
    * **Correct:** `tournaments/CLG_001/` (New record created here)
    * **Incorrect:** `tournaments/FAKE_COLLEGE_ID/` (Remains empty)
* **Conclusion:** College-level isolation works correctly.

---

## ✅ Results Summary
* **Security:** Pass
* **Role Management:** Pass
* **Data Integrity:** Pass