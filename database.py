import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "hospital.db"

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_connection()
    cur = conn.cursor()

    cur.executescript("""
    PRAGMA foreign_keys = ON;

    -- === Table des patients ===
    CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        birth_date TEXT,
        gender TEXT,
        address TEXT,
        phone TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    -- === Table des hospitalisations ===
    CREATE TABLE IF NOT EXISTS hospitalizations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        admission_date TEXT,
        discharge_date TEXT,
        service TEXT,
        room_number TEXT,
        responsible_doctor TEXT,
        reporter_doctor TEXT,
        report_json TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
    );

    -- === Table des suivis d’hospitalisation ===
    CREATE TABLE IF NOT EXISTS followups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospitalization_id INTEGER NOT NULL,
        followup_json TEXT,
        reporter_doctor TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(hospitalization_id) REFERENCES hospitalizations(id) ON DELETE CASCADE
    );

    -- === Table des sorties d’hospitalisation ===
    CREATE TABLE IF NOT EXISTS discharges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospitalization_id INTEGER NOT NULL,
        discharge_json TEXT,
        reporter_doctor TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(hospitalization_id) REFERENCES hospitalizations(id) ON DELETE CASCADE
    );

    -- === Table des ordonnances ===
    CREATE TABLE IF NOT EXISTS prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        prescription_json TEXT,
        doctor_name TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
    );
    """)

    conn.commit()
    conn.close()
    print(f"✅ Base de données initialisée à : {DB_PATH}")



def ensure_patient_exists(patient_data):
    """
    Vérifie si un patient existe déjà, sinon l’insère.
    patient_data = {
        "patient_id": "P123",
        "name": "Jean Dupont",
        "birth_date": "1985-04-15",
        "gender": "M",
        "address": "Alger",
        "phone": "0555555555"
    }
    """
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("SELECT id FROM patients WHERE patient_id = ?", (patient_data["patient_id"],))
        existing = cur.fetchone()

        if existing:
            print(f"ℹ️ Patient déjà existant : {patient_data['patient_id']}")
        else:
            cur.execute("""
                INSERT INTO patients (patient_id, name, birth_date, gender, address, phone)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                patient_data["patient_id"],
                patient_data["name"],
                patient_data.get("birth_date"),
                patient_data.get("gender"),
                patient_data.get("address"),
                patient_data.get("phone")
            ))
            conn.commit()
            print(f"✅ Nouveau patient ajouté : {patient_data['patient_id']}")

    except sqlite3.Error as e:
        print("❌ Erreur SQLite :", e)
    finally:
        conn.close()
