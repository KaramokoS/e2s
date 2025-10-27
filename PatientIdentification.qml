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
                            root.patientIdentified(root.buildJson())
                        } else {
                            messageDialog.text = qsTr("Veuillez saisir un identifiant.")
                            messageDialog.open()
                        }
                    }
                }
            }
        }

        // === OU ===
        Label {
            text: qsTr("— OU —")
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            color: "#666"
        }

        // === Bloc de recherche par nom + prénom + date de naissance ===
        GroupBox {
            title: qsTr("Recherche par nom, prénom et date de naissance")
            Layout.fillWidth: true

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 10

                Label { text: qsTr("Nom :") }
                TextField {
                    text: root.lastName
                    onTextChanged: root.lastName = text
                    placeholderText: qsTr("Ex: Dupont")
                }

                Label { text: qsTr("Prénom :") }
                TextField {
                    text: root.firstName
                    onTextChanged: root.firstName = text
                    placeholderText: qsTr("Ex: Marie")
                }

                Label { text: qsTr("Date de naissance :") }
                RowLayout {
                    spacing: 6
                    TextField {
                        placeholderText: qsTr("Date (JJ/MM/AAAA)")
                        text: Qt.formatDate(root.birthDate, "dd/MM/yyyy")
                        onEditingFinished: {
                            var parts = text.split("/");
                            if (parts.length === 3) {
                                var d = new Date(parts[2], parts[1]-1, parts[0]);
                                if (!isNaN(d)) root.birthDate = d;
                            }
                        }
                        width: 120
                    }
                    Button {
                        text: "📅"
                        onClicked: birthDialog.open()
                    }
                }
            }
        }

        // === Bouton de validation ===
        Button {
            text: qsTr("Valider l'identification")
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 220
            onClicked: {
                if ((root.firstName.trim() !== "" && root.lastName.trim() !== "")
                        || root.patientId.trim() !== "") {
                    root.patientIdentified(root.buildJson())
                } else {
                    messageDialog.text = qsTr("Veuillez renseigner un identifiant ou les informations du patient.")
                    messageDialog.open()
                }
            }
        }
    }

    // === Sélecteur de date ===
    Dialog {
        id: birthDialog
        modal: true
        title: qsTr("Sélectionner la date de naissance")
        standardButtons: Dialog.Ok | Dialog.Cancel
        // solve this to have a calendar view
        //contentItem: CalendarView {
        //    id: birthCalendar
        //    selectedDate: root.birthDate
        //}

        onAccepted: root.birthDate = birthCalendar.selectedDate
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
}
