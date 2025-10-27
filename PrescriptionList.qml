import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: prescriptionPage
    title: "Liste des ordonnances"

    // --- Propriétés externes ---
    property string patientName: ""
    property var prescriptions: [] // tableau d’ordonnances passé depuis l’extérieur

    // --- Apparence générale ---
    background: Rectangle {
        color: "white"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // En-tête patient
        RowLayout {
            spacing: 8
            Label {
                text: "Patient :"
                font.bold: true
            }
            Label {
                text: patientName
                font.pointSize: 14
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Nouvelle ordonnance"
                icon.name: "add"
                onClicked: addPrescriptionDialog.open()
            }
        }

        // Liste des ordonnances
        ListView {
            id: prescriptionList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: prescriptions

            delegate: Rectangle {
                width: parent.width
                height: 70
                radius: 8
                color: "#ffffff"
                border.color: "#cccccc"
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    ColumnLayout {
                        Label {
                            text: modelData.medication
                            font.bold: true
                            font.pointSize: 14
                        }
                        Label {
                            text: "Dosage : " + modelData.dosage
                            font.pointSize: 12
                            color: "#555"
                        }
                        Label {
                            text: "Durée : " + modelData.duration
                            font.pointSize: 12
                            color: "#777"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Supprimer"
                        onClicked: {
                            prescriptions.splice(index, 1)
                            prescriptionList.model = prescriptions // met à jour la vue
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        // Boîte de dialogue pour ajouter une ordonnance
        Dialog {
            id: addPrescriptionDialog
            modal: true
            title: "Ajouter une ordonnance"
            standardButtons: Dialog.Ok | Dialog.Cancel

            ColumnLayout {
                anchors.margins: 10
                spacing: 8

                TextField {
                    id: medInput
                    placeholderText: "Médicament"
                }
                TextField {
                    id: dosageInput
                    placeholderText: "Dosage (ex: 2x/jour)"
                }
                TextField {
                    id: durationInput
                    placeholderText: "Durée (ex: 7 jours)"
                }
            }

            onAccepted: {
                if (medInput.text !== "") {
                    prescriptions.push({
                        medication: medInput.text,
                        dosage: dosageInput.text,
                        duration: durationInput.text
                    })
                    prescriptionList.model = prescriptions
                }
                medInput.text = dosageInput.text = durationInput.text = ""
            }
        }
    }
}
