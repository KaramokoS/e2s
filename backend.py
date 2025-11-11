# backend.py
from PySide6.QtCore import QObject, Slot, Signal
import json
from database import get_connection

class Backend(QObject):
    patientFound = Signal(str)  # Signal envoyé vers QML si patient trouvé
    patientNotFound = Signal(str)  # Signal si l’ID n’existe pas

    @Slot(str)
    def search_patient_by_id(self, json_str):
        """Recherche un patient à partir de son ID et renvoie les infos JSON"""
        try:
            data = json.loads(json_str)
            patient_id = data.get("patientId")

            conn = get_connection()
            cur = conn.cursor()
            cur.execute("SELECT * FROM patients WHERE patient_id = ?", (patient_id,))

            row = cur.fetchone()

            conn.close()

            if row:
                patient = {
                    "patientId": row["patient_id"],
                    "name": row["name"],
                    "gender": row["gender"],
                    "birthDate": row["birth_date"]
                }
                print(f"✅ Patient trouvé : {patient}")
                self.patientFound.emit(json.dumps(patient))
            else:
                print("❌ Aucun patient trouvé pour cet ID.")
                self.patientNotFound.emit(patient_id)

        except Exception as e:
            print("Erreur recherche patient :", e)
            self.patientNotFound.emit("Erreur lors de la recherche.")
