import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    // === Signaux pour intégration backend ===
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
    property string reason: ""
    property string diagnosis: ""
    property string treatment: ""
    property string evolution: ""

    // === Fonction utilitaire pour générer le JSON ===
    function buildJson() {
        var data = {
            patientName: patientName,
            patientId: patientId,
            service: service,
            roomNumber: roomNumber,
            admissionDate: admissionDate.toISOString(),
            dischargeDate: dischargeDate.toISOString(),
            responsibleDoctor: responsibleDoctor,
            reason: reason,
            diagnosis: diagnosis,
            treatment: treatment,
            evolution: evolution
        }
        return JSON.stringify(data)
    }

    // === Layout principal ===
    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 14
            //padding: 20

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
                }
            }

            // === Contenu médical ===
            GroupBox {
                title: qsTr("Compte rendu médical")
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 12

                    Label { text: qsTr("Motif d'admission :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        text: root.reason
                        wrapMode: Text.Wrap
                        onTextChanged: root.reason = text
                    }

                    Label { text: qsTr("Diagnostic :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        text: root.diagnosis
                        wrapMode: Text.Wrap
                        onTextChanged: root.diagnosis = text
                    }

                    Label { text: qsTr("Traitement :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        text: root.treatment
                        wrapMode: Text.Wrap
                        onTextChanged: root.treatment = text
                    }

                    Label { text: qsTr("Évolution / Observations :") }
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        text: root.evolution
                        wrapMode: Text.Wrap
                        onTextChanged: root.evolution = text
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
        //contentItem: CalendarView { id: admissionCalendar; selectedDate: root.admissionDate }
        onAccepted: root.admissionDate = admissionCalendar.selectedDate
    }

    Dialog {
        id: dischargeDialog
        modal: true
        title: qsTr("Sélectionner la date de sortie")
        standardButtons: Dialog.Ok | Dialog.Cancel
        //contentItem: CalendarView { id: dischargeCalendar; selectedDate: root.dischargeDate }
        onAccepted: root.dischargeDate = dischargeCalendar.selectedDate
    }

    // === Fonction utilitaire pour charger depuis JSON ===
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
            reason = o.reason || ""
            diagnosis = o.diagnosis || ""
            treatment = o.treatment || ""
            evolution = o.evolution || ""
        } catch (e) {
            console.warn("Hospitalization load error:", e)
        }
    }
}
