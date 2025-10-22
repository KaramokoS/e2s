// HospitalizationForm.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 20

    // === Signaux ===
    signal saveRequested(string hospitalizationJson)
    signal printRequested(string hospitalizationJson)
    signal shareRequested(string hospitalizationJson, string target)

    // === Données ===
    property string patientName: ""
    property string patientId: ""
    property string service: ""
    property string roomNumber: ""
    property date admissionDate: new Date()
    property date dischargeDate: new Date()
    property string responsibleDoctor: ""
    property string reporterDoctor: ""
    property string reason: ""
    property string backgrounds: ""
    property string surgicalBackgrounds: ""
    property string familyBackgrounds: ""
    property string treatment: ""
    property string evolution: ""
    property string wayOfLife: ""
    property string historyOfDisease: ""
    property string clinicalExamination: ""
    property string diagnosticHypothesis: ""
    property string initialSupport: ""
    property string biologicalAssessment: ""
    property string imaging: ""

    property bool showSurgical: false
    property bool showFamily: false

    // === Fonction utilitaire ===
    function buildJson() {
        var data = {
            patientName, patientId, service, roomNumber,
            admissionDate: admissionDate.toISOString(),
            dischargeDate: dischargeDate.toISOString(),
            responsibleDoctor, reporterDoctor,
            reason, backgrounds, surgicalBackgrounds, familyBackgrounds,
            treatment, evolution, wayOfLife, historyOfDisease, clinicalExamination,
            diagnosticHypothesis, initialSupport, biologicalAssessment, imaging
        }
        return JSON.stringify(data)
    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 20
        contentWidth: parent.width
        contentHeight: column.implicitHeight
        clip: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 14
            anchors.margins: 20

            // === En-tête ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Label {
                    text: qsTr("Fiche d'hospitalisation")
                    font.pixelSize: 26
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "← Retour"
                    onClicked: {
                        var view = root.parent
                        if (view && view.pop) view.pop()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

            // === Informations patient ===
            GroupBox {
                title: qsTr("Informations du patient")
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Label { text: qsTr("Nom du patient :") }
                    TextField { text: root.patientName; onTextChanged: root.patientName = text }

                    Label { text: qsTr("Identifiant patient :") }
                    TextField { text: root.patientId; onTextChanged: root.patientId = text }

                    Label { text: qsTr("Service :") }
                    TextField { text: root.service; onTextChanged: root.service = text }

                    Label { text: qsTr("Chambre :") }
                    TextField { text: root.roomNumber; onTextChanged: root.roomNumber = text }
                }
            }

            // === Informations médicales ===
            GroupBox {
                title: qsTr("Informations médicales")
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Label { text: qsTr("Date d'admission :") }
                    RowLayout {
                        spacing: 6
                        TextField {
                            readOnly: true
                            text: Qt.formatDate(root.admissionDate, "dd/MM/yyyy")
                            width: 120
                        }
                        Button { text: "📅"; onClicked: admissionDialog.open() }
                    }

                    Label { text: qsTr("Date de sortie :") }
                    RowLayout {
                        spacing: 6
                        TextField {
                            readOnly: true
                            text: Qt.formatDate(root.dischargeDate, "dd/MM/yyyy")
                            width: 120
                        }
                        Button { text: "📅"; onClicked: dischargeDialog.open() }
                    }

                    Label { text: qsTr("Médecin responsable :") }
                    TextField { text: root.responsibleDoctor; onTextChanged: root.responsibleDoctor = text }

                    Label { text: qsTr("Identité du rédacteur :") }
                    TextField { text: root.reporterDoctor; onTextChanged: root.reporterDoctor = text }
                }
            }

            // === Compte rendu médical ===
            GroupBox {
                title: qsTr("Compte rendu médical")
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 12

                    Label { text: qsTr("Motif d'Admission :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.reason
                        wrapMode: Text.Wrap
                        onTextChanged: root.reason = text
                    }

                    // --- Antécédents médicaux + boutons d'ajout ---
                    
                    Label { text: qsTr("Antécédents Médicaux :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.backgrounds
                        wrapMode: Text.Wrap
                        onTextChanged: root.backgrounds = text
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Button {
                            text: qsTr("➕ Chirurgicaux")
                            onClicked: root.showSurgical = true
                        }
                        Button {
                            text: qsTr("➕ Familiaux")
                            onClicked: root.showFamily = true
                        }
                    }
                    // --- Antécédents chirurgicaux (affichage conditionnel) ---
                    ColumnLayout {
                        visible: root.showSurgical
                        spacing: 4
                        Label { text: qsTr("Antécédents Chirurgicaux :") }
                        TextArea {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            text: root.surgicalBackgrounds
                            wrapMode: Text.Wrap
                            onTextChanged: root.surgicalBackgrounds = text
                        }
                    }

                    // --- Antécédents familiaux (affichage conditionnel) ---
                    ColumnLayout {
                        visible: root.showFamily
                        spacing: 4
                        Label { text: qsTr("Antécédents Familiaux :") }
                        TextArea {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            text: root.familyBackgrounds
                            wrapMode: Text.Wrap
                            onTextChanged: root.familyBackgrounds = text
                        }
                    }

                    Label { text: qsTr("Mode de vie :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.wayOfLife
                        wrapMode: Text.Wrap
                        onTextChanged: root.wayOfLife = text
                    }

                    Label { text: qsTr("Traitement Habituel :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.treatment
                        wrapMode: Text.Wrap
                        onTextChanged: root.treatment = text
                    }

                    Label { text: qsTr("Histoire de la Maladie :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.historyOfDisease
                        wrapMode: Text.Wrap
                        onTextChanged: root.historyOfDisease = text
                    }

                    Label { text: qsTr("Examen Clinique :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.clinicalExamination
                        wrapMode: Text.Wrap
                        onTextChanged: root.clinicalExamination = text
                    }

                    Label { text: qsTr("Hypothèse Diagnostique :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.diagnosticHypothesis
                        wrapMode: Text.Wrap
                        onTextChanged: root.diagnosticHypothesis = text
                    }
                    Label { text: qsTr("Prise en Charge Initiale :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.initialSupport
                        wrapMode: Text.Wrap
                        onTextChanged: root.initialSupport = text
                    }
                    Label { text: qsTr("Bilan Biologique :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.biologicalAssessment
                        wrapMode: Text.Wrap
                        onTextChanged: root.biologicalAssessment = text
                    }

                    Label { text: qsTr("Imagerie :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        text: root.imaging
                        wrapMode: Text.Wrap
                        onTextChanged: root.imaging = text
                    }
                }
            }

            // === Actions ===
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("Sauvegarder")
                    onClicked: root.saveRequested(root.buildJson())
                }
                Button {
                    text: qsTr("Imprimer PDF")
                    onClicked: root.printRequested(root.buildJson())
                }
                Button {
                    text: qsTr("Partager")
                    onClicked: shareMenu.open()
                }

                Menu {
                    id: shareMenu
                    title: qsTr("Partager")
                    MenuItem { text: "E-mail"; onTriggered: root.shareRequested(root.buildJson(), "email") }
                    MenuItem { text: "Dossier partagé"; onTriggered: root.shareRequested(root.buildJson(), "sharedRecord") }
                }
            }
        }
    }

    // === Dialogues de calendrier ===
    Dialog {
        id: admissionDialog
        modal: true
        title: qsTr("Sélectionner la date d'admission")
        standardButtons: Dialog.Ok | Dialog.Cancel
    }

    Dialog {
        id: dischargeDialog
        modal: true
        title: qsTr("Sélectionner la date de sortie")
        standardButtons: Dialog.Ok | Dialog.Cancel
    }

    // === Charger depuis JSON ===
    function loadFromJson(json) {
        try {
            var o = JSON.parse(json)
            patientName = o.patientName || ""
            patientId = o.patientId || ""
            service = o.service || ""
            roomNumber = o.roomNumber || ""
            admissionDate = o.admissionDate ? new Date(o.admissionDate) : new Date()
            dischargeDate = o.dischargeDate ? new Date(o.dischargeDate) : new Date()
            responsibleDoctor = o.responsibleDoctor || ""
            reporterDoctor = o.reporterDoctor || ""
            reason = o.reason || ""
            backgrounds = o.backgrounds || ""
            surgicalBackgrounds = o.surgicalBackgrounds || ""
            familyBackgrounds = o.familyBackgrounds || ""
            treatment = o.treatment || ""
            wayOfLife = o.wayOfLife || ""
            evolution = o.evolution || ""
            historyOfDisease = o.historyOfDisease || ""
            clinicalExamination = o.clinicalExamination || ""
            diagnosticHypothesis = o.diagnosticHypothesis || ""
            initialSupport = o.initialSupport || ""
            biologicalAssessment = o.biologicalAssessment || ""
            imaging = o.imaging || ""
            showSurgical = !!o.surgicalBackgrounds
            showFamily = !!o.familyBackgrounds
        } catch (e) {
            console.warn("Hospitalization load error:", e)
        }
    }
}
