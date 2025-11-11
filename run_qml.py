import datetime
import sys
import os
import json
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtGui import QGuiApplication
from urllib.parse import urlparse, unquote
from pathlib import Path


from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
from reportlab.graphics.barcode import code128
from reportlab.lib.pagesizes import A4
import backend as bck
from database import init_db, get_connection, ensure_patient_exists



os.environ["QT_QPA_PLATFORM"] = "xcb"
os.environ["QT_QUICK_BACKEND"] = "software"


class PrescriptionBackend(QObject):
    @Slot(str, str)
    def generate_discharge_report(self, json_data, qml_url):
        """
        Génère un PDF de sortie d'hospitalisation à partir des données JSON.
        """

        parsed = urlparse(qml_url)
        output_pdf = Path(unquote(parsed.path))
        output_pdf = str(output_pdf)

        data = json.loads(json_data)

        c = canvas.Canvas(output_pdf, pagesize=A4)
        width, height = A4
        y = height - 50

        # === EN-TÊTE ===
        c.setFont("Helvetica-Bold", 18)
        c.drawCentredString(width / 2, y, "Compte Rendu de Sortie d'Hospitalisation")
        y -= 40

        # === INFORMATIONS PATIENT ===
        c.setFont("Helvetica-Bold", 12)
        c.drawString(40, y, "Informations du patient :")
        y -= 20
        c.setFont("Helvetica", 10)
        c.drawString(50, y, f"Nom du patient : {data.get('patientName', '')}")
        y -= 14
        c.drawString(50, y, f"Identifiant : {data.get('patientId', '')}")
        y -= 14
        c.drawString(50, y, f"Date de sortie : {data.get('dischargeDate', '')[:10]}")
        y -= 14
        c.drawString(50, y, f"Rédacteur du rapport : Dr {data.get('reporterDoctor', '')}")
        y -= 30

        # === SECTIONS PRINCIPALES ===
        def draw_section(title, text):
            nonlocal y
            if not text:
                return
            if y < 120:
                c.showPage()
                y = height - 50
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, title)
            y -= 16
            c.setFont("Helvetica", 10)
            text_obj = c.beginText(50, y)
            for line in text.split("\n"):
                if y < 80:
                    c.drawText(text_obj)
                    c.showPage()
                    y = height - 50
                    text_obj = c.beginText(50, y)
                text_obj.textLine(line)
                y -= 12
            c.drawText(text_obj)
            y -= 20

        draw_section("Synthèse d'hospitalisation :", data.get("synthesis", ""))
        draw_section("Conclusion médicale :", data.get("conclusion", ""))

        # === SIGNATURE & PIED DE PAGE ===
        c.setFont("Helvetica-Bold", 11)
        c.drawRightString(width - 60, 100, f"Dr {data.get('reporterDoctor', '')}")
        c.line(width - 160, 95, width - 40, 95)
        c.setFont("Helvetica", 9)
        c.drawRightString(width - 60, 80, "Signature")

        c.setFont("Helvetica-Oblique", 9)
        c.drawCentredString(width / 2, 40, f"Document généré le {datetime.datetime.now().strftime('%d/%m/%Y à %H:%M')} - PharmNet Hospital")

        c.save()
        print(f"✅ PDF de sortie généré : {output_pdf}")

        # === ENREGISTREMENT EN BASE ===
        conn = get_connection()
        cur = conn.cursor()

        # Trouver l’hospitalisation correspondante
        cur.execute("SELECT id FROM hospitalizations WHERE patient_id = ? ORDER BY id DESC LIMIT 1", (data.get("patientId"),))
        hosp = cur.fetchone()
        hospitalization_id = hosp["id"] if hosp else None

        cur.execute("""
            INSERT INTO discharges (hospitalization_id, discharge_json, reporter_doctor)
            VALUES (?, ?, ?)
        """, (hospitalization_id, json_data, data.get("reporterDoctor")))
        conn.commit()
        conn.close()
        print("✅ Sortie d'hospitalisation sauvegardée en base de données.")

    @Slot(str, str)
    def generate_followup_report(self, json_data, qml_url):
        """
        Génère un PDF de suivi d'hospitalisation à partir d'un JSON produit par le QML.
        """
        parsed = urlparse(qml_url)
        output_pdf = Path(unquote(parsed.path))
        output_pdf = str(output_pdf)

        data = json.loads(json_data)

        c = canvas.Canvas(output_pdf, pagesize=A4)
        width, height = A4
        y = height - 50

        # === EN-TÊTE ===
        c.setFont("Helvetica-Bold", 18)
        c.drawCentredString(width / 2, y, "Suivi d'Hospitalisation")
        y -= 40

        # === INFORMATIONS GÉNÉRALES ===
        c.setFont("Helvetica-Bold", 12)
        c.drawString(40, y, "Informations du patient")
        y -= 20
        c.setFont("Helvetica", 10)
        c.drawString(50, y, f"Nom du patient : {data.get('patientName', '')}")
        y -= 14
        c.drawString(50, y, f"Identifiant : {data.get('patientId', '')}")
        y -= 14
        c.drawString(50, y, f"Date de visite : {data.get('visitDate', '')[:10]}")
        y -= 14
        c.drawString(50, y, f"Rédigé par : Dr {data.get('reporterDoctor', '')}")
        y -= 30

        # === CONTENU DU SUIVI ===
        def draw_section(title, text):
            nonlocal y
            if not text:
                return
            if y < 120:
                c.showPage()
                y = height - 50
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, title)
            y -= 16
            c.setFont("Helvetica", 10)
            text_obj = c.beginText(50, y)
            for line in text.split("\n"):
                if y < 80:
                    c.drawText(text_obj)
                    c.showPage()
                    y = height - 50
                    text_obj = c.beginText(50, y)
                text_obj.textLine(line)
                y -= 12
            c.drawText(text_obj)
            y -= 20

        draw_section("Observation et suivi :", data.get("followUpText", ""))
        draw_section("Examens complémentaires :", data.get("complementaryExam", ""))

        # === PIED DE PAGE ===
        c.setFont("Helvetica-Oblique", 9)
        c.drawCentredString(width / 2, 40, f"Document généré le {datetime.datetime.now().strftime('%d/%m/%Y à %H:%M')} - PharmNet Hospital")

        c.save()
        print(f"✅ PDF de suivi généré : {output_pdf}")

        # === ENREGISTREMENT EN BASE ===
        conn = get_connection()
        cur = conn.cursor()

        # Récupère la dernière hospitalisation du patient
        cur.execute("SELECT id FROM hospitalizations WHERE patient_id = ? ORDER BY id DESC LIMIT 1", (data.get("patientId"),))
        hosp = cur.fetchone()
        hospitalization_id = hosp["id"] if hosp else None

        cur.execute("""
            INSERT INTO followups (hospitalization_id, followup_json, reporter_doctor)
            VALUES (?, ?, ?)
        """, (hospitalization_id, json_data, data.get("reporterDoctor")))
        conn.commit()
        conn.close()
        print("💾 Suivi hospitalier enregistré dans la base.")


    @Slot(str, str)
    def generate_hospitalization_report(self, json_data, qml_url):
        """
        Génère un PDF de compte rendu d'hospitalisation à partir des données JSON.
        Appelée depuis QML : ex. HospitalizationForm.printRequested(json)
        """
        parsed = urlparse(qml_url)
        output_pdf = Path(unquote(parsed.path))
        output_pdf = str(output_pdf)
        data = json.loads(json_data)
        c = canvas.Canvas(output_pdf, pagesize=A4)
        width, height = A4
        y = height - 50

        # === En-tête ===
        c.setFont("Helvetica-Bold", 16)
        c.drawCentredString(width / 2, y, "Compte Rendu d'Hospitalisation")
        y -= 40

        # === Informations Patient ===
        c.setFont("Helvetica-Bold", 12)
        c.drawString(40, y, "Informations du patient :")
        y -= 20
        c.setFont("Helvetica", 11)
        c.drawString(50, y, f"Nom : {data.get('patientName', '')}")
        y -= 14
        c.drawString(50, y, f"Identifiant : {data.get('patientId', '')}")
        y -= 14
        c.drawString(50, y, f"Service : {data.get('service', '')}")
        y -= 14
        c.drawString(50, y, f"Chambre : {data.get('roomNumber', '')}")
        y -= 14
        c.drawString(50, y, f"Admission : {data.get('admissionDate', '')[:10]}  |  Sortie : {data.get('dischargeDate', '')[:10]}")
        y -= 14
        c.drawString(50, y, f"Médecin responsable : {data.get('responsibleDoctor', '')}")
        y -= 14
        c.drawString(50, y, f"Rédacteur du rapport : {data.get('reporterDoctor', '')}")
        y -= 30

        # === Contenu médical ===
        def draw_section(title, text):
            nonlocal y
            if not text:
                return
            if y < 100:
                c.showPage()
                y = height - 50
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, title)
            y -= 16
            c.setFont("Helvetica", 10)
            text_obj = c.beginText(50, y)
            for line in text.split("\n"):
                if y < 80:
                    c.drawText(text_obj)
                    c.showPage()
                    y = height - 60
                    text_obj = c.beginText(50, y)
                text_obj.textLine(line)
                y -= 12
            c.drawText(text_obj)
            y -= 20

        sections = [
            ("Motif d'admission", data.get("reason")),
            ("Antécédents médicaux", data.get("backgrounds")),
            ("Antécédents chirurgicaux", data.get("surgicalBackgrounds")),
            ("Antécédents familiaux", data.get("familyBackgrounds")),
            ("Mode de vie", data.get("wayOfLife")),
            ("Traitement habituel", data.get("treatment")),
            ("Histoire de la maladie", data.get("historyOfDisease")),
            ("Examen clinique", data.get("clinicalExamination")),
            ("Hypothèse diagnostique", data.get("diagnosticHypothesis")),
            ("Prise en charge initiale", data.get("initialSupport")),
            ("Bilan biologique", data.get("biologicalAssessment")),
            ("Imagerie", data.get("imaging")),
            ("Évolution", data.get("evolution"))
        ]

        for title, text in sections:
            draw_section(title, text)

        # === Pied de page ===
        c.setFont("Helvetica-Oblique", 9)
        c.drawCentredString(width / 2, 40, f"Document généré le {datetime.datetime.now().strftime('%d/%m/%Y à %H:%M')} - PharmNet Hospital")

        c.save()
        print(f"✅ Compte rendu PDF généré : {output_pdf}")

        # === Enregistrement en base ===
        patient_info = {
            "patient_id": data["patient"]["ID"],
            "name": data["patient"]["name"],
            "birth_date": data["patient"].get("birth_date"),
            "gender": data["patient"].get("gender"),
            "address": data["patient"].get("address"),
            "phone": data["patient"].get("phone")
        }
        ensure_patient_exists(patient_info)
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO hospitalizations (
                patient_id, admission_date, discharge_date, service, room_number,
                responsible_doctor, reporter_doctor, report_json
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            data.get("patientId"),
            data.get("admissionDate"),
            data.get("dischargeDate"),
            data.get("service"),
            data.get("roomNumber"),
            data.get("responsibleDoctor"),
            data.get("reporterDoctor"),
            json_data
        ))
        conn.commit()
        conn.close()
        print("💾 Données hospitalisation enregistrées dans la base.")

    @Slot(str, str)
    def generatePrescriptionPDF(self, json_string, qml_url):
        """Slot appelé depuis QML"""
        data = json.loads(json_string)

        parsed = urlparse(qml_url)
        output_pdf = Path(unquote(parsed.path))
        output_pdf = str(output_pdf)

        c = canvas.Canvas(output_pdf, pagesize=A4)
        width, height = A4

        y = height - 50

        # === Informations médecin ===
        c.setFont("Helvetica-Bold", 14)
        c.drawString(40, y, f"Dr {data['doctor']['name']}")
        y -= 18
        c.setFont("Helvetica-BoldOblique", 12)
        c.drawString(40, y, data['doctor']['specialty'])
        y -= 16
        c.setFont("Helvetica", 11)
        c.drawString(40, y, data['doctor']['city'])
        y -= 16
        c.drawString(40, y, f"Tel : {data['doctor']['phone']}")
        y -= 16
        c.drawString(40, y, f"N° Ordre : {data['doctor']['order_number']}")

        # === Titre Ordonnance ===
        y -= 50
        c.setFont("Helvetica-Bold", 26)
        c.drawCentredString(width/2, y, "Ordonnance")

        # === Informations patient ===
        y -= 40
        c.setFont("Helvetica", 11)
        c.drawString(40, y, f"Fait le : {data['date']}")
        c.drawRightString(width - 40, y, f"Patient(e) : {data['patient']['name']}")
        y -= 16
        c.drawRightString(width - 40, y, f"ID : {data['patient']['ID']}")

        # === Liste des médicaments ===
        y -= 40
        for med in data['prescriptions']:
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, med['title'])
            c.drawRightString(width - 60, y, f"Qte: {med['qty']}")
            y -= 16
            c.setFont("Helvetica", 10)
            c.drawString(40, y, f"D.C.I ({med['dci']})")
            y -= 14
            text = c.beginText(40, y)
            text.setFont("Helvetica", 10)
            for line in med['details'].split('\n'):
                text.textLine(line)
                y -= 12
            c.drawText(text)
            y -= 12

        # === Code-barres ===
        barcode_value = data.get('barcode', '0000-000')
        barcode = code128.Code128(barcode_value, barHeight=20*mm, barWidth=0.4)
        barcode.drawOn(c, 40, 100)

        # === Numéro ordonnance & site ===
        c.setFont("Helvetica-Bold", 12)
        c.drawRightString(width - 80, 110, barcode_value)
        c.setFont("Helvetica", 9)
        c.drawRightString(width - 80, 95, "https://www.action.africa/")

        c.showPage()
        c.save()
        print(f"✅ Ordonnance PDF généré : {output_pdf}")

        patient_info = {
            "patient_id": data["patient"]["ID"],
            "name": data["patient"]["name"],
            "birth_date": data["patient"].get("birth_date"),
            "gender": data["patient"].get("gender"),
            "address": data["patient"].get("address"),
            "phone": data["patient"].get("phone")
        }
        ensure_patient_exists(patient_info)

        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO prescriptions (patient_id, prescription_json, doctor_name)
            VALUES (?, ?, ?)
        """, (
            data["patient"]["ID"],
            json_string,
            data["doctor"]["name"]
        ))
        conn.commit()
        conn.close()
        print("✅ Ordonnance sauvegardée en base de données.")

    @Slot(str)
    def get_patient_folder(patient_id: str):
        conn = get_connection()
        cur = conn.cursor()

        # Récupère les infos patient
        cur.execute("SELECT * FROM patients WHERE patient_id = ?", (patient_id,))
        patient = cur.fetchone()

        # Récupère hospitalisations, suivis, ordonnances
        cur.execute("SELECT * FROM hospitalizations WHERE patient_id = ?", (patient_id,))
        hospitalizations = cur.fetchall()

        cur.execute("SELECT * FROM prescriptions WHERE patient_id = ?", (patient_id,))
        prescriptions = cur.fetchall()

        # Pour chaque hospitalisation, on peut charger les suivis et sorties
        dossier = {
            "patient": dict(patient) if patient else None,
            "hospitalizations": [],
            "prescriptions": [dict(p) for p in prescriptions]
        }

        for hosp in hospitalizations:
            hid = hosp["id"]
            cur.execute("SELECT * FROM followups WHERE hospitalization_id = ?", (hid,))
            followups = [dict(f) for f in cur.fetchall()]
            cur.execute("SELECT * FROM discharges WHERE hospitalization_id = ?", (hid,))
            discharge = cur.fetchone()
            dossier["hospitalizations"].append({
                "info": dict(hosp),
                "followups": followups,
                "discharge": dict(discharge) if discharge else None
            })

        conn.close()
        return dossier


if __name__ == "__main__":
    init_db()  # Crée les tables si besoin

    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()
    backend = PrescriptionBackend()
    patientBackend = bck.Backend()
    engine.rootContext().setContextProperty("PatientBackend", patientBackend)
    engine.rootContext().setContextProperty("PrescriptionBackend", backend)

    qml_file = os.path.join(os.path.dirname(__file__), "window.qml")
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
