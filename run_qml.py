import sys
import os
import json
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtGui import QGuiApplication

from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
from reportlab.graphics.barcode import code128
from reportlab.lib.pagesizes import A4


os.environ["QT_QPA_PLATFORM"] = "xcb"
import os
os.environ["QT_QUICK_BACKEND"] = "software"


class PrescriptionBackend(QObject):
    @Slot(str)
    def generatePrescriptionPDF(self, json_string):
        """Slot appelé depuis QML"""
        data = json.loads(json_string)

        output_pdf = "ref_files/monordonnance.pdf"

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


if __name__ == "__main__":
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()
    backend = PrescriptionBackend()
    engine.rootContext().setContextProperty("PrescriptionBackend", backend)

    qml_file = os.path.join(os.path.dirname(__file__), "window.qml")
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
