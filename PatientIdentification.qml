import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 40

    // --- Signal envoyé lorsqu’on identifie un patient ---
    signal patientIdentified(string patientJson)

    // config

    property string buttonName: ""

    // --- Données du patient ---
    property string patientId: ""
    property string firstName: ""
    property string lastName: ""
    property date birthDate: new Date()

    // --- Génération du JSON d’identification ---
    function buildJson() {
        var obj = {
            patientId: patientId,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate.toISOString()
        }
        return JSON.stringify(obj)
    }

    Rectangle {
        anchors.fill: parent
        color: "#f7f9fb"
        radius: 10
        border.color: "#ddd"
        border.width: 1
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: Math.min(parent.width * 0.6, 480)

        Label {
            text: qsTr("Identification du patient")
            font.pixelSize: 26
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#ccc" }

        // === Bloc de recherche par identifiant ===
        GroupBox {
            title: qsTr("Recherche par identifiant unique")
            Layout.fillWidth: true

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                TextField {
                    id: idField
                    placeholderText: qsTr("Identifiant patient (ex: P12345)")
                    text: root.patientId
                    Layout.fillWidth: true
                    onTextChanged: root.patientId = text
                }

                Button {
                    text: qsTr("Rechercher")
                    onClicked: {
                        if (root.patientId.trim().length > 0) {
                            PatientBackend.search_patient_by_id(root.buildJson())
                            root.patientIdentified(patientJson)
                        } else {
                            messageDialog.text = qsTr("Veuillez saisir un identifiant.")
                            messageDialog.open()
                        }
                    }
                }
            }
        }
    }

    // === Message d’erreur ===
    Dialog {
        id: messageDialog
        title: qsTr("Information")
        property string text:""
        contentItem: Text {
            text: messageDialog.text
        }
        standardButtons: Dialog.Ok
    }

    onPatientIdentified: {
        var patient = JSON.parse(patientJson)
        console.log("New patient identified:", patient.firstName, "Buton name ::", root.buttonName)
        if (root.buttonName == "FollowUpButton") {
            stack.push("HospitalizationFollowUp.qml")
        } else if (root.buttonName == "DischargeButton") {
            stack.push("HospitalizationDischarge.qml")
        } else if (root.buttonName == "prescriptionButton") {
            stack.push("PrescriptionList.qml")
        }
    }

    Connections {
        target: backend

        function onPatientFound(patientJson) {
            var patient = JSON.parse(patientJson)
            root.firstName = patient.firstName
            root.lastName = patient.lastName
            root.birthDate = new Date(patient.birthDate)

            console.log("✅ Patient identifié :", patient.firstName, patient.lastName)
            root.patientIdentified(patientJson)
        }

        function onPatientNotFound(patientId) {
            messageDialog.text = qsTr("Aucun patient trouvé avec l'identifiant : ") + patientId
            messageDialog.open()
        }
    }

}
